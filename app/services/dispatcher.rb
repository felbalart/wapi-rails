class Dispatcher
  attr_accessor :browser
  def initialize(account, browser: nil, driver: :chrome)
    @browser = browser || Pincers.for_webdriver(driver)
    @account = account
  end

  def run(time_span)
    cycle = 0
    start_time = Time.current
    end_time = start_time + time_span
    while Time.current < end_time
      puts "[Dispatcher] Ready to run cycle nº #{cycle += 1} (will stop at #{end_time})"
      run_cycle
    end
  end

  def run_cycle
    cycle_start_time = Time.current
    puts "[Dispatcher] Starting cycle at #{cycle_start_time}"
    otbx_msgs = send_pending_outbox
    read_msgs_hash = read
    try_match(otbx_msgs)

    @account.touch_last_read_at
    puts("[Dispatcher] Finished cycle at #{Time.current} (spent #{Time.current - cycle_start_time} secs)." +
      "Sent: #{otbx_msgs.count}, Read Total: #{read_msgs_hash[:all].count}, Read Novelties: #{read_msgs_hash[:novelties].count}")
    { sent: otbx_msgs, read: read_msgs_hash }
  end

  def read
    read_since = @account.last_read_at - 1.minute
    reader_adaptor.read(read_since)
  end

  def send_pending_outbox
    otbx_msgs = @account.outbox_messages.with_outbox_status(:pending).to_a
    return [] if otbx_msgs.empty?
    otbx_msgs.each { |omsg| send_otbx_msg omsg}
  end

  def send_otbx_msg(otbx_msg)
    sender.send_otbx_msg(otbx_msg)
    otbx_msg.update(outbox_status: :sent)
  end

  def try_match(otbx_msgs)
    otbx_msgs.each do |omsg|
      match_result = matcher.try_confirm(omsg)
      raise "Unable to match Outbox Message #{omsg.to_json}" if match_result.blank?
    end
  end

  private

  def reader_adaptor
    @reader_adaptor ||= ReaderAdaptor.new(@account, browser: browser)
  end

  def sender
    @sender ||= Sender.new(@account, browser: browser)
  end

  def matcher
    @matcher ||= Matcher.new
  end
end