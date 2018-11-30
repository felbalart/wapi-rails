class ReaderAdaptor
  def initialize(account, browser: nil, driver: :chrome)
    @browser = browser || Pincers.for_webdriver(driver)
    @account = account
    @messages = []
  end


  def read(since)
    msgs = Reader.new(@account, browser: @browser).read(since)
    msgs.each { |msg| process_message(msg) }
  end

  def process_message(msg)
    msg.set_digest_if_blank
    persisted_msg = Message.find_by(digest: msg.digest)
    if persisted_msg # already existing message
      persisted_msg.status = msg.status
      persisted_msg.save!
    else # new message
      msg.save!
    end
  end
end
