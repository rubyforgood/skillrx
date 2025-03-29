class Tag < ActsAsTaggableOn::Tag
  has_many :tag_cognates
  has_many :cognates, through: :tag_cognates

  # Reverse relationship for cognates referencing this tag
  has_many :reverse_tag_cognates, class_name: "TagCognate", foreign_key: :cognate_id
  has_many :reverse_cognates, through: :reverse_tag_cognates, source: :tag

  def cognates_list
    cognates.pluck(:name) + reverse_cognates.pluck(:name)
  end

  def cognates_list=(cognates_list_str)
    self.cognates = Tag.where(name: cognates_list_str)
  end

  def available_cognates
    Tag.all - [ cognates, self ]
  end
end
