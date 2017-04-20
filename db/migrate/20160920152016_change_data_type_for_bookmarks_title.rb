class ChangeDataTypeForBookmarksTitle < ActiveRecord::Migration
  def up
      change_column :bookmarks, :title, :binary
  end

  def down
      change_column :bookmarks, :title, :string
  end
end
