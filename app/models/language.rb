class Language < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  def file_storage_prefix
    return "" if name.downcase == "english" || name.nil?

    "#{name.first(2).upcase}_"
  end
end
