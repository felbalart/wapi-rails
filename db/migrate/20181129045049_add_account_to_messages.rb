class AddAccountToMessages < ActiveRecord::Migration[5.2]
  def change
    add_reference :messages, :account, foreign_key: true, index: true
  end
end
