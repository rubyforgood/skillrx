ActsAsTaggableOn::Tag.class_eval do
  has_many :tag_cognates, dependent: :destroy
  # Reverse relationship for cognates referencing this tag
  has_many :reverse_tag_cognates, class_name: "TagCognate", foreign_key: :cognate_id, dependent: :destroy
end

ActsAsTaggableOn.remove_unused_tags = true
