class OutboxMessage < ApplicationRecord
  belongs_to :account
  belongs_to :message, optional: true
end

# == Schema Information
#
# Table name: outbox_messages
#
#  id            :bigint(8)        not null, primary key
#  account_id    :bigint(8)
#  destinatary   :string(191)
#  msg_type      :string(191)
#  content       :string(191)
#  message_id    :bigint(8)
#  outbox_status :string(191)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_outbox_messages_on_account_id  (account_id)
#  index_outbox_messages_on_message_id  (message_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (message_id => messages.id)
#
