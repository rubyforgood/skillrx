class CreateContributor < ActiveRecord::Migration[8.0]
  def change
    create_table :contributors do |t|
      t.belongs_to :provider
      t.belongs_to :user

      t.timestamps
    end
  end
end
