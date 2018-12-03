class CreateOutboxMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :outbox_messages do |t|
      t.references :account, foreign_key: true
      t.string :destinatary
      t.string :msg_type
      t.string :content
      t.references :message, foreign_key: true
      t.string :outbox_status

      t.timestamps
    end
  end
end
