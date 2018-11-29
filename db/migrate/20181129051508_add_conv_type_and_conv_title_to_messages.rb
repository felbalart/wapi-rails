class AddConvTypeAndConvTitleToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :conv_type, :string
    add_column :messages, :conv_title, :string
  end
end
