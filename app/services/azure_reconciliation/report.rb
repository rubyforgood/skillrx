# Compares topics, their documents, ActiveStorage and the Azure File Share,
# and returns one Row per discrepancy. Read only: it changes nothing.
#
# Expected Azure locations mirror FileManager: regular files go to the Pi and
# v2 Content folders, videos to v2 VideoContent, and archived topics' files to
# the matching _Archive folder. Shadow-copy topics hold documents waiting to be
# deleted from Azure, so their files should be gone.
module AzureReconciliation
  class Report
    Row = Struct.new(
      :category, :language, :topic_id, :title, :document_id, :directory,
      :file_name, :expected_size, :azure_size, :note,
      keyword_init: true,
    )

    def initialize(lister:, languages: Language.all, check_blobs: true)
      @lister = lister
      @languages = languages
      @check_blobs = check_blobs
    end

    def rows
      @rows ||= languages.flat_map { |language| LanguageCheck.new(language, lister, check_blobs).rows }
    end

    def to_csv
      CSV.generate do |csv|
        csv << Row.members
        rows.each { |row| csv << row.to_a }
      end
    end

    # { [language, category] => count }
    def summary
      rows.group_by { |row| [ row.language, row.category ] }.transform_values(&:size).sort.to_h
    end

    private

    attr_reader :lister, :languages, :check_blobs

    class LanguageCheck
      def initialize(language, lister, check_blobs)
        @language = language
        @lister = lister
        @check_blobs = check_blobs
        @rows = []
        @claimed = Set.new
        @live_names = {}
      end

      def rows
        load_azure
        topics = Topic.unscoped.where(language:).includes(:provider, documents_attachments: :blob).to_a
        live, shadows = topics.partition { |topic| !topic.shadow_copy? }

        live.each { |topic| check_live_topic(topic) }
        shadows.each { |topic| check_shadow_topic(topic) }
        report_orphans(live)
        report_duplicates(live)

        @rows
      end

      private

      attr_reader :language, :lister, :check_blobs, :azure, :claimed, :live_names

      def prefix
        language.file_storage_prefix
      end

      def pi = "#{prefix}CMES-Pi/assets/Content"
      def v2 = "#{prefix}CMES-v2/assets/Content"
      def video = "#{prefix}CMES-v2/assets/VideoContent"
      def pi_archive = "#{prefix}CMES-Pi_Archive"
      def v2_archive = "#{prefix}CMES-v2_Archive"

      def directories
        [ pi, v2, video, pi_archive, v2_archive ]
      end

      # [active folder, archive folder] for each copy of a document.
      def folder_pairs(document)
        return [ [ video, v2_archive ] ] if document.content_type == "video/mp4"

        [ [ pi, pi_archive ], [ v2, v2_archive ] ]
      end

      def load_azure
        @azure = directories.index_with do |directory|
          files = lister.files_in(directory)
          add(category: "missing_directory", directory:) if files.nil?
          files || {}
        end
      end

      def check_live_topic(topic)
        if topic.documents_attachments.empty?
          add(category: "topic_without_documents", topic:, note: topic.state)
          return
        end

        topic.documents_attachments.each do |document|
          name = file_name(topic, document) or next
          live_names[name] ||= topic

          if check_blobs && !document.blob.service.exist?(document.blob.key)
            add(category: "missing_in_storage", topic:, document:, file_name: name, expected_size: document.byte_size)
          end

          if document.byte_size.zero?
            add(category: "empty_document", topic:, document:, file_name: name, expected_size: 0)
            next
          end

          folder_pairs(document).each do |active, archive|
            expected, other = topic.archived? ? [ archive, active ] : [ active, archive ]
            check_location(topic, document, name, expected, other)
          end
        end
      end

      def check_location(topic, document, name, expected, other)
        attrs = { topic:, document:, file_name: name, directory: expected, expected_size: document.byte_size }

        if azure[expected].key?(name)
          claimed << [ expected, name ]
          size = azure[expected][name]
          add(category: "size_mismatch", azure_size: size, **attrs) if size != document.byte_size
        elsif azure[other].key?(name)
          claimed << [ other, name ]
          add(category: "wrong_folder", azure_size: azure[other][name], note: "found in #{other}", **attrs)
        else
          add(category: "missing_in_azure", **attrs)
        end
      end

      # A shadow copy's file sharing a name with a current document is that
      # document's file, so only unclaimed files count as failed deletes.
      def check_shadow_topic(shadow)
        shadow.documents_attachments.each do |document|
          name = file_name(shadow, document) or next

          folder_pairs(document).flatten.each do |directory|
            next unless azure[directory].key?(name)
            next if claimed.include?([ directory, name ])

            claimed << [ directory, name ]
            add(
              category: "failed_delete", topic_id: shadow.document_prefix.presence&.to_i, title: shadow.title,
              document:, directory:, file_name: name, azure_size: azure[directory][name],
              note: "shadow topic #{shadow.id}",
            )
          end
        end
      end

      def report_orphans(live)
        topics_by_prefix = live.index_by { |topic| topic.doc_prefix.to_s }

        azure.each do |directory, files|
          files.each do |name, size|
            next if claimed.include?([ directory, name ])

            attrs = { directory:, file_name: name, azure_size: size }
            if (topic = live_names[name])
              add(category: "orphan_stale_copy", topic:, **attrs)
            elsif (topic = topic_for_name(name, topics_by_prefix))
              add(category: "orphan_unmatched_name", topic:, **attrs)
            else
              add(category: "orphan_no_topic", **attrs)
            end
          end
        end
      end

      # File names start with "<doc_prefix>_"; a prefix may itself contain underscores.
      def topic_for_name(name, topics_by_prefix)
        name.to_enum(:scan, "_").each do
          topic = topics_by_prefix[name[0...Regexp.last_match.begin(0)]]
          return topic if topic
        end
        nil
      end

      def report_duplicates(live)
        live
          .group_by { |topic| [ topic.provider_id, topic.title.to_s.squish.downcase, topic.published_at.to_date ] }
          .each_value do |group|
            next if group.size < 2

            ids = group.map(&:id).sort
            group.each do |topic|
              add(category: "duplicate_topic", topic:, note: "#{topic.state}; copies: #{ids.join(' ')}")
            end
          end
      end

      def file_name(topic, document)
        topic.custom_file_name(document)
      rescue StandardError => e
        add(category: "broken_topic", topic:, document:, note: "#{e.class}: #{e.message}")
        nil
      end

      def add(topic: nil, document: nil, **attrs)
        attrs[:topic_id] ||= topic&.id
        attrs[:title] ||= topic&.title
        attrs[:document_id] ||= document&.id
        @rows << Row.new(language: language.name, **attrs)
      end
    end
  end
end
