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

  # Sets cognate relationships based on a list of tag names
  #
  # @param str_list [Array<String>] list of tag names to set as cognates
  def cognates_list=(str_list)
    if persisted?
      remove_cognates(str_list)
      create_cognates(str_list)
    else
      self.tag_cognates_attributes = str_list.filter_map do |name|
        next if name.blank?

        cognate = Tag.find_or_create_with_like_by_name(name)
        { cognate_id: cognate.id } if cognate.id != id
      end
    end
  end

  # Returns tags that are available to be set as cognates
  #
  # @return [ActiveRecord::Relation] collection of Tag records excluding self
  def all_available_tags
    Tag.where.not(id: id)
  end

  private

  def create_cognates(str_list)
    str_list.filter_map do |name|
      next if name.blank?

      Tag.find_or_create_with_like_by_name(name).then do |tag|
        tag_cognates.create(cognate: tag)
      end
    end
  end

  def remove_cognates(str_list)
    tag_cognates.where.not(cognate_id: Tag.where(name: str_list).pluck(:id)).destroy_all
  end
end
