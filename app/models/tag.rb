# == Schema Information
#
# Table name: tags
#
#  id             :bigint           not null, primary key
#  name           :string
#  taggings_count :integer          default(0)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_tags_on_name  (name) UNIQUE
#
class Tag < ActsAsTaggableOn::Tag
  has_many :tag_cognates, dependent: :destroy
  has_many :cognates, through: :tag_cognates
  accepts_nested_attributes_for :tag_cognates, allow_destroy: true

  # Reverse relationship for cognates referencing this tag
  has_many :reverse_tag_cognates, class_name: "TagCognate", foreign_key: :cognate_id, dependent: :destroy
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

  # Sets cognate relationships based on a list of tag names
  #
  # @param str_list [Array<String>] list of tag names to set as cognates
  def cognates_list=(str_list)
    names = str_list.compact_blank.uniq.reject { |name| name == self.name }
    remove_cognates(names) if persisted?
    return if names.empty?
    create_cognates(names)
    associate_cognates(names)
  end

  # Returns tags that are available to be set as cognates
  #
  # @return [ActiveRecord::Relation] collection of Tag records excluding self
  def all_available_tags
    Tag.where.not(id: id)
  end

  private

  def create_cognates(names)
    names.each { |name| Tag.find_or_create_by(name: name) }
  end

  def remove_cognates(names)
    cognates_to_remove = cognates_tags.excluding(Tag.where(name: names))
    cognates_to_remove.each do |cognate|
      cognate.tag_cognates.destroy_all
      cognate.reverse_tag_cognates.destroy_all
    end
  end

  def associate_cognates(names)
    tags_for_passed_names = Tag.where(name: names)
    related_tags = tags_for_passed_names.or(Tag.where(id: tags_for_passed_names.flat_map(&:cognates_tags).pluck(:id))).uniq
    related_tags.each_with_index do |tag, index|
      related_tags[index + 1..].each do |cognate|
        tag.tag_cognates.create(cognate: cognate)
      end
    end
    self.tag_cognates_attributes = related_tags.filter_map do |tag|
      cognate = Tag.find_by(name: tag.name)
      { cognate_id: cognate.id } if cognate.id != id && !tag_cognates.find_by(cognate_id: cognate.id)
    end
  end
end
