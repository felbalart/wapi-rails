class Message < ApplicationRecord
  before_save :set_digest_if_blank

  def set_digest_if_blank
    set_digest if digest.blank?
  end

  def set_digest
    self.digest = build_digest
  end

  def build_digest
    Digest::MD5.hexdigest(
      [msg_type, sender, destinatary, text, blob_url, time, duration, status,
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
#
# Indexes
#
#  index_messages_on_digest  (digest)
#
