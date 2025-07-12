# == Schema Information
#
# Table name: tag_cognates
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  cognate_id :bigint
#  tag_id     :bigint
#
# Indexes
#
#  index_tag_cognates_on_cognate_id             (cognate_id)
#  index_tag_cognates_on_tag_id                 (tag_id)
#  index_tag_cognates_on_tag_id_and_cognate_id  (tag_id,cognate_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (cognate_id => tags.id)
#  fk_rails_...  (tag_id => tags.id)
#
class TagCognate < ApplicationRecord
  belongs_to :tag, class_name: "Tag"
  belongs_to :cognate, class_name: "Tag"

  validates :tag_id, uniqueness: { scope: :cognate_id }
  validate :no_self_reference
  validate :no_similar_reverse_tag_cognate

  private

  def no_self_reference
    errors.add(:base, "Tag can't be its own cognate") if tag_id == cognate_id
  end

  def no_similar_reverse_tag_cognate
    if TagCognate.where(tag_id: cognate_id, cognate_id: tag_id).exists?
      errors.add(:base, "This cognate relationship already exists in reverse")
    end
  end
end
