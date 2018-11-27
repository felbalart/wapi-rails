class Message < ApplicationRecord
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
#
