module CountableDocuments
  extend ActiveSupport::Concern

  class ActiveStorage::Attachment
    require "active_record/counter_cache"

    after_create :increment_documents_count
    after_destroy :decrement_documents_count

    def increment_documents_count
      record.class.increment_counter(:documents_count, record_id, touch: true)
    end

    def decrement_documents_count
      record.class.decrement_counter(:documents_count, record_id, touch: true)
    end
  end
end
