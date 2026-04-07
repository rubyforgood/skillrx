# == Schema Information
#
# Table name: tags
# Database name: primary
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
  # Moved :tag_cognates and reverse_tag_cognates associations to acts_as_taggable initializer to ensure dependent: :destroy was run
  has_many :cognates, through: :tag_cognates
  has_many :reverse_cognates, through: :reverse_tag_cognates, source: :tag
  accepts_nested_attributes_for :tag_cognates, allow_destroy: true

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
  # @return [Collection<Tag>] unique collection of associated cognate tags
  def cognates_tags
     Tag.where(id: [ cognate_ids, reverse_cognate_ids ].flatten)
  end

  # Returns a list of all cognate tag names
  #
  # @return [Array<String>] array of cognate tag names
  def cognates_list
    cognates_tags.pluck(:name)
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
    Tag.excluding(self).order(name: :asc)
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
    new_cognates = Tag.where(name: names)
    new_cognates_cognates_ids = new_cognates.flat_map(&:cognates_tags).pluck(:id)
    current_tag_cognates_ids = TagCognate.where(tag_id: id).pluck(:cognate_id) + TagCognate.where(cognate_id: id).pluck(:tag_id)
    related_tags = new_cognates
      .or(Tag.where(id: [ new_cognates_cognates_ids, current_tag_cognates_ids ].flatten))
      .excluding(self)
      .uniq
    related_tags.each_with_index do |tag, index|
      related_tags[index + 1..].each do |cognate|
        next if cognate.in?(tag.cognates_tags)
        tag.tag_cognates.create(cognate: cognate)
      end
    end
    self.tag_cognates_attributes = related_tags.filter_map do |tag|
      { cognate_id: tag.id } if !cognates_tags.find_by(id: tag.id)
    end
  end
end
