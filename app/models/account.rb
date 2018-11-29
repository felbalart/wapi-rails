class Account < ApplicationRecord
  has_many :messages
end

# == Schema Information
#
# Table name: accounts
#
#  id           :bigint(8)        not null, primary key
#  name         :string(255)
#  phone_number :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
