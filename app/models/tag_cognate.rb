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
  belongs_to :tag, class_name: "ActsAsTaggableOn::Tag"
  belongs_to :cognate, class_name: "ActsAsTaggableOn::Tag"

  validates :tag_id, uniqueness: { scope: :cognate_id }
end
