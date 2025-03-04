class Tag < ActsAsTaggableOn::Tag
  has_many :tag_cognates
  has_many :cognates, through: :tag_cognates

  # Reverse relationship for cognates referencing this tag
  has_many :reverse_tag_cognates, class_name: "TagCognate", foreign_key: :cognate_id
  has_many :reverse_cognates, through: :reverse_tag_cognates, source: :tag

  # Returns a unique list of all cognate tags, including both direct and reverse relationships
  #
  # @return [Array<Tag>] unique array of associated cognate tags
  def cognates_tags
    (cognates + reverse_cognates).uniq
  end

  # Returns a list of all cognate tag names
  #
  # @return [Array<String>] array of cognate tag names
  def cognates_list
    cognates.pluck(:name) + reverse_cognates.pluck(:name)
  end

  # Returns tags that are available to be set as cognates
  #
  # @return [ActiveRecord::Relation] collection of Tag records excluding self and existing cognates
  def available_cognates
    Tag.where.not(id: cognates.pluck(:id)).where.not(id: id)
  end
end
