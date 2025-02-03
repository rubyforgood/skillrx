class CreateLanguages < ActiveRecord::Migration[8.0]
  def change
    create_table :languages do |t|
      t.string :name
      t.string :file_share_folder

      t.timestamps
    end
  end
end
