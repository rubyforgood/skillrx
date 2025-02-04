class DocumentValidator < ActiveModel::Validator
  VALID_TYPES = %w[image/jpeg image/jpg image/png image/svg image/webp image/avif image/gif videos/mp4 ].freeze
  def validate(record)
    return unless record.document.attached?

    unless record.document.blob.content_type.in?(VALID_TYPES)
      record.errors.add(:document, "Document has an invalid content type (authorized content type is JPG,PNG)")
    end
  end
end
