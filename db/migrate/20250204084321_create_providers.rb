class CreateProviders < ActiveRecord::Migration[8.0]
  def change
    create_table :providers do |t|
      t.string :name
      t.string :provider_type

      t.timestamps
    end

    create_table :branches do |t|
      t.belongs_to :provider
      t.belongs_to :region

      t.timestamps
    end
  end
end
