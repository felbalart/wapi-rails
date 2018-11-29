class Message < ApplicationRecord
  belongs_to :account
  before_save :set_digest_if_blank
  extend Enumerize
  enumerize :conv_type, in: [:direct, :group]
  enumerize :direction, in: [:sent, :received]
  enumerize :status, in: [:clock, :check, :double_check, :double_check_ack, :not_available]

  def set_digest_if_blank
    set_digest if digest.blank?
  end

  def set_digest
    self.digest = build_digest
  end

  def build_digest
    Digest::MD5.hexdigest(
      [msg_type, sender, destinatary, text, blob_url, time, duration,
       auto_text, background_image].join('$;')
    )
  end
end

# == Schema Information
#
# Table name: messages
#
#  id               :bigint(8)        not null, primary key
#  msg_type         :string(255)
#  sender           :string(255)
#  destinatary      :string(255)
#  text             :string(255)
#  blob_url         :string(255)
#  time             :datetime
#  duration         :integer
#  status           :string(255)
#  auto_text        :string(255)
#  background_image :text(65535)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  digest           :string(255)
#  direction        :string(255)
#  account_id       :bigint(8)
#  conv_type        :string(255)
#  conv_title       :string(255)
#
# Indexes
#
#  index_messages_on_account_id  (account_id)
#  index_messages_on_digest      (digest)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
