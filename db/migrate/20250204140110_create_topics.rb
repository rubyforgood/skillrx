class CreateTopics < ActiveRecord::Migration[8.0]
  def change
    create_table :topics do |t|
      t.references :provider
      t.references :language
      t.string :title, null: false
      t.text :description, null: false
      t.uuid :uid, default: 'gen_random_uuid()', null: false
      t.integer :state, default: 0, null: false

      t.timestamps
    end
  end
end
