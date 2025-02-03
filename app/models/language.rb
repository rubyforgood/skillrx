class Language < ApplicationRecord
  validates :name, :file_share_folder, presence: true, uniqueness: true
end
