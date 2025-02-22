class Language < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  def file_storage_prefix
    return "" if name == "English" || name.nil?

    "#{name.first(2).upcase}_"
  end
end
