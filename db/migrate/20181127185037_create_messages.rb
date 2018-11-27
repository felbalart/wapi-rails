class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.string :msg_type
      t.string :sender
      t.string :destinatary
      t.string :text
      t.string :blob_url
      t.datetime :time
      t.integer :duration
      t.string :status
      t.string :auto_text
      t.text :background_image

      t.timestamps
    end
  end
end
