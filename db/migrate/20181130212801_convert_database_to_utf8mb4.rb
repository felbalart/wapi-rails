class ConvertDatabaseToUtf8mb4 < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      execute "ALTER TABLE messages CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
      execute "ALTER TABLE messages CHANGE text text TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    end
  end
end
