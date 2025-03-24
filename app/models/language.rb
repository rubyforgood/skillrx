# == Schema Information
#
# Table name: languages
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Language < ApplicationRecord
  has_many :topics, dependent: :destroy
  validates :name, presence: true, uniqueness: true, length: { minimum: 2 }

  def file_storage_prefix
    return "" if name.downcase == "english" || name.nil?

    "#{code.upcase}_"
  end

  def code
    name.first(2).downcase
  end

  def tags
    topics
      .flat_map do |topic|
        topic.current_tags_for_language(id).map { |tag| tag.name }
      end
      .uniq
  end
end
