class CreateTopics < ActiveRecord::Migration[8.0]
  def change
    create_table :topics do |t|
      t.string :title, null: false
      t.text :description
      t.references :language, null: false, foreign_key: true
      t.references :provider, null: false, foreign_key: true
      t.boolean :archived, default: false
      t.timestamps
    end
  end
end
