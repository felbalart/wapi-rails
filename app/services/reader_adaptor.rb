class ReaderAdaptor
  def initialize(account, browser: nil, driver: :chrome)
    @browser = browser || Pincers.for_webdriver(driver)
    @account = account
    @messages = []
  end


  def read(since)
    start_time = Time.current
    puts "Starting to read for account #{@account.name} at #{start_time} messages since #{since}"
    msgs = Reader.new(@account, browser: @browser).read(since)
    process_messages(msgs)
    novelties = msgs.select(&:novelty)
    puts("Finished reading for #{@account.name} since #{since} captured #{msgs.count} (#{novelties.count} novelties)" +
    " ending at #{Time.current} (spent #{Time.current - start_time} secs)")
    { all: msgs, novelties: novelties}
  end

  def process_messages(msgs)
    msgs.each(&:set_digest_if_blank)
    already_existing = Message.includes(:account).where(digest: msgs.map(&:digest))
    msgs_hash = msgs.map {|msg| [msg.digest, msg] }.to_h
    status_hash = msgs.map {|msg| [msg.digest, msg.status] }.to_h
    already_existing.each { |aemsg| msgs_hash[aemsg.digest] = aemsg }
    msgs_hash.values.each do |msg|
      if msg.persisted?
        msg.update(status: status_hash[msg.digest]) if msg.status != status_hash[msg.digest]
      else # new message
        msg.novelty = true
        msg.save!
      end
    end
  end
end
