class AddDigestToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :digest, :string
    add_index :messages, :digest
  end
end
