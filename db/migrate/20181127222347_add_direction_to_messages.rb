class AddDirectionToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :direction, :string
  end
end
