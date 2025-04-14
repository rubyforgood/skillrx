class CreateTagCognatesJoinTable < ActiveRecord::Migration[8.0]
  def change
    create_table :tag_cognates do |t|
      t.references :tag, foreign_key: true
      t.references :cognate, foreign_key: { to_table: :tags }
      t.timestamps
    end

    add_index :tag_cognates, [ :tag_id, :cognate_id ], unique: true
  end
end
