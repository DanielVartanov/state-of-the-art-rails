class RenameUsersToAuthors < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      rename_table :users, :authors
      rename_column :messages, :user_id, :author_id
    end
  end
end
