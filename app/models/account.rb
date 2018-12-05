class Account < ApplicationRecord
  has_many :messages
  has_many :outbox_messages

  def touch_last_read_at
    update(last_read_at: Time.current)
  end
end

# == Schema Information
#
# Table name: accounts
#
#  id           :bigint(8)        not null, primary key
#  name         :string(191)
#  phone_number :string(191)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  last_read_at :datetime         default(Thu, 31 Dec 2009 21:00:00 -03 -03:00)
#
