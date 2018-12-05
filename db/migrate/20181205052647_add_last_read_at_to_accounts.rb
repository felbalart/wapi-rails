class AddLastReadAtToAccounts < ActiveRecord::Migration[5.2]
  def up
    add_column :accounts, :last_read_at, :datetime
    change_column_default :accounts, :last_read_at, '2010-01-01 00:00:00'
  end

  def down
    remove_column :accounts, :last_read_at
  end
end
