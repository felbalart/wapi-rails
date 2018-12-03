FactoryBot.define do
  factory :outbox_message do
    account { nil }
    destinatary { "MyString" }
    msg_type { "MyString" }
    content { "MyString" }
    message { nil }
    outbox_status { "MyString" }
  end
end
