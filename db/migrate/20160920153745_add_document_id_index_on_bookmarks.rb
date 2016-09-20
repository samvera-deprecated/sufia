class AddDocumentIdIndexOnBookmarks < ActiveRecord::Migration
  def change
    add_index :bookmarks, :document_id
  end
end
