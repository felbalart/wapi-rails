FactoryBot.define do
  factory :message do
    msg_type { "MyString" }
    sender { "MyString" }
    destinatary { "MyString" }
    text { "MyString" }
    blob_url { "MyString" }
    time { "2018-11-27 15:50:37" }
    duration { 1 }
    status { "MyString" }
    auto_text { "MyString" }
    background_image { "MyText" }
  end
end
