class AddSentAtToOutboxMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :outbox_messages, :sent_at, :datetime
  end
end
