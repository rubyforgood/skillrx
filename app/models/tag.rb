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

  scope :search_with_params, ->(params) do
    self
      .then { |scope| params[:name].present? ? scope.where("tags.name ILIKE ?", "%#{params[:name]}%") : scope }
      .then do |scope|
        if params[:order].in?([ "asc", "desc" ])
          scope.order(created_at: params[:order]&.to_sym)
        elsif params[:order] == "most_tagged"
          scope.order(taggings_count: :desc)
        elsif params[:order] == "least_tagged"
          scope.order(taggings_count: :asc)
        else
          scope.order(name: :asc)
        end
      end
  end

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
    names = str_list.compact_blank.uniq.reject { _1 == name }
    remove_cognates(names) if persisted?
    return if names.empty?
    new_names_to_associate = create_cognates(names)
    associate_cognates(new_names_to_associate)
  end

  # Returns tags that are available to be set as cognates
  #
  # @return [ActiveRecord::Relation] collection of Tag records excluding self
  def all_available_tags
    Tag.where.not(id: id)
  end

  private

  def create_cognates(names)
    names
      .map { |name| [ name, Tag.find_or_initialize_by(name: name) ] }
      .each_with_object([]) do |(name, tag), new_names|
        new_names << name unless tag.in?(cognates_tags)
        tag.save
        new_names
      end
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
    related_tags = tags_for_passed_names.excluding(self).or(Tag.where(id: tags_for_passed_names.flat_map(&:cognates_tags).pluck(:id))).uniq
    related_tags.each_with_index do |tag, index|
      related_tags[index + 1..].each do |cognate|
        tag.tag_cognates.create(cognate: cognate)
      end
    end
    self.tag_cognates_attributes = related_tags.filter_map do |tag|
      { cognate_id: tag.id } if !tag_cognates.find_by(cognate_id: tag.id)
    end
  end
end
