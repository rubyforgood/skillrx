module Beacons
  class ManifestBuilder
    def initialize(beacon)
      @beacon = beacon
    end

    def call
      content = build_content
      checksum = "sha256:#{compute_checksum(content)}"
      version = resolve_version(checksum, content)

      content.merge(
        manifest_version: "v#{version}",
        manifest_checksum: checksum,
        generated_at: Time.current.iso8601,
      )
    end

    private

    attr_reader :beacon

    def resolve_version(checksum, content)
      return beacon.manifest_version if beacon.manifest_checksum == checksum

      beacon.update!(
        manifest_version: beacon.manifest_version + 1,
        manifest_checksum: checksum,
        manifest_data: content,
      )

      beacon.manifest_version
    end

    def build_content
      providers_data = build_providers

      {
        language: build_language,
        region: build_region,
        tags: build_tags,
        providers: providers_data,
        total_size_bytes: compute_total_size(providers_data),
        total_files: compute_total_files(providers_data),
      }
    end

    def build_language
      language = beacon.language

      {
        id: language.id,
        code: language.code,
        name: language.name,
      }
    end

    def build_region
      region = beacon.region

      {
        id: region.id,
        name: region.name,
      }
    end

    def build_tags
      topics
        .flat_map(&:tags)
        .uniq(&:id)
        .sort_by(&:id)
        .map { |tag| { id: tag.id, name: tag.name } }
    end

    def build_providers
      topics_by_provider = topics.group_by(&:provider_id)

      beacon.providers.sort_by(&:id).map do |provider|
        provider_topics = (topics_by_provider[provider.id] || []).sort_by(&:id)

        {
          id: provider.id,
          name: provider.name,
          topics: provider_topics.map { |topic| build_topic(topic) },
        }
      end
    end

    def build_topic(topic)
      {
        id: topic.id,
        name: topic.title,
        tag_ids: topic.tags.map(&:id).sort,
        files: topic.documents.sort_by { |d| d.blob.id }.map { |doc| build_file(topic, doc) },
      }
    end

    def build_file(topic, document)
      blob = document.blob
      filename = topic.custom_file_name(document)

      {
        id: blob.id,
        filename: filename,
        path: "providers/#{topic.provider_id}/topics/#{topic.id}/#{filename}",
        checksum: blob.checksum,
        size_bytes: blob.byte_size,
        content_type: blob.content_type,
        updated_at: blob.created_at.iso8601,
      }
    end

    def topics
      @topics ||= beacon.topics.active.includes(:tags, :provider, documents_attachments: :blob)
    end

    def compute_total_size(providers_data)
      providers_data.sum do |provider|
        provider[:topics].sum do |topic|
          topic[:files].sum { |file| file[:size_bytes] }
        end
      end
    end

    def compute_total_files(providers_data)
      providers_data.sum do |provider|
        provider[:topics].sum { |topic| topic[:files].size }
      end
    end

    def compute_checksum(content)
      OpenSSL::Digest::SHA256.hexdigest(content.to_json)
    end
  end
end
