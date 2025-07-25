class AddDocumentPrefixForTopics < ActiveRecord::Migration[8.0]
  def change
    add_column :topics, :document_prefix, :string
  end
end
