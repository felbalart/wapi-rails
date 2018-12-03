class Message < ApplicationRecord
  belongs_to :account
  has_one :outbox_message
  before_save :set_digest_if_blank
  extend Enumerize
  enumerize :conv_type, in: [:direct, :group]
  enumerize :direction, in: [:sent, :received]
  enumerize :status, in: [:clock, :check, :double_check, :double_check_ack, :not_available]
  validates_uniqueness_of :digest
  validates_presence_of :msg_type, :sender, :destinatary, :time, :status, :digest, :direction,
    :account_id, :conv_type, :conv_title

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
#  msg_type         :string(191)
#  sender           :string(191)
#  destinatary      :string(191)
#  text             :text(65535)
#  blob_url         :string(191)
#  time             :datetime
#  duration         :integer
#  status           :string(191)
#  auto_text        :string(191)
#  background_image :text(65535)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  digest           :string(191)
#  direction        :string(191)
#  account_id       :bigint(8)
#  conv_type        :string(191)
#  conv_title       :string(191)
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
