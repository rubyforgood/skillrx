class AddFileNamePrefixToProviders < ActiveRecord::Migration[8.0]
  def change
    add_column :providers, :file_name_prefix, :string
  end
end
