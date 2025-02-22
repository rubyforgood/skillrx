class RemoveFileShareFolderFromLanguages < ActiveRecord::Migration[8.0]
  def change
    remove_column :languages, :file_share_folder
  end
end
