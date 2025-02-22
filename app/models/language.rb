class Language < ApplicationRecord
  has_many :topics, dependent: :destroy
  validates :name, presence: true, uniqueness: true, length: { minimum: 2 }

  def file_storage_prefix
    return "" if name.downcase == "english" || name.nil?

    "#{name.first(2).upcase}_"
  end
end
