class Reader
  attr_accessor :browser
  def initialize(account, browser: nil, driver: :chrome)
    @browser = browser || Pincers.for_webdriver(driver)
    @account = account
    @messages = []
  end

  def read(since)
    ensure_logged
    # TODO ensure logged in correct account
    conv_divs_updated_since(since).each do |conv_div|
      read_conv(conv_div, since)
    end
    @messages
  rescue StandardError => ex
    binding.pry
  end

  private

  def read_conv(conv_div, since)
    conv_div.click
    msgs = read_current_conv(since)
    @messages += msgs
  end

  def read_current_conv(since)
    # TODO scroll down and read according to 'since' param, instead of just all visible in not-scrolled view
    conv_type, conv_title = extract_current_conv_data
    msgs_divs = browser.search("[id='main'] .copyable-area [tabindex='0'] > div:last-child > div")
    msgs_divs.map { |md| build_msg_from_div(conv_type, conv_title, md) }.compact
  end

  def build_msg_from_div(conv_type, conv_title, msg_div)
    msg = Parsers::BaseParser.new.parse_message(msg_div)
    return unless msg
    msg.conv_type = conv_type
    msg.conv_title = conv_title
    if conv_type == :group
      msg.sender ||= @account.name if msg.direction.sent?
      msg.destinatary = conv_title
    elsif conv_type == :direct
      if msg.direction.received?
        msg.sender ||= conv_title
        msg.destinatary = @account.name
      elsif msg.direction.sent?
        msg.sender ||= @account.name
        msg.destinatary = conv_title
      else
        raise "Unexpected msg direction '#{msg.direction}'"
      end
    else
      raise "Unexpected msg conv_type '#{conv_type}'"
    end
    msg
  end

  def extract_current_conv_data
    conv_data_div = browser.search("[id='main'] > header > div[role='button'").last
    data = conv_data_div.text.split("\n")
    conv_title = data.first
    conv_type = data[1] ? :group : :direct
    [conv_type, conv_title]
  end

  def conv_divs_updated_since(since)
    # TODO: scroll down to cover beyond the first 18 convs
    pane_side = browser.search("[id='pane-side']")
    conv_div = pane_side.search('div').find { |d| d.attribute('style').include?('z-index') }
    conv_div_class = conv_div.attribute('class')
    conv_divs = pane_side.search(".#{conv_div_class}")
    conv_divs.reject do |cd| # filter by 'since' date
      date_data = cd.text.split("\n").second
      parse_conv_div_date(date_data) < since
    end
  end

  WHATSAPP_WEB_URL = 'http://web.whatsapp.com'
  def ensure_logged
    return true if logged?
    browser.goto WHATSAPP_WEB_URL
    # binding.pry # scan QR code
    browser.wait(timeout: 60) { logged? }
    # raise "Unable to login" unless logged?
    puts 'Logged succesfully! :)'
    true
  end

  def parse_conv_div_date(txt)
    if txt.match(/^\d{1,2}:\d{2} (A|P)M$/) # same-day time
      txt.to_time
    elsif txt == 'Yesterday'
      Date.yesterday.end_of_day
    elsif txt.match(/^\d{1,2}\/\d{1,2}\/\d{4}$/) # date
      Date.strptime(txt, '%m/%d/%Y').end_of_day
    else
      days_hash = (1..7).map {|num| num.days.ago.end_of_day }.map { |day| [day.strftime('%A'), day] }.to_h
      if days_hash.keys.include?(txt) # Monday, Tuesday, Wednesday etc...
        days_hash[txt]
      else
        raise "Unhandled conv_div date format: '#{txt}'"
      end
    end
  end

  def logged?
    browser.search('span[data-icon=chat]').present?
  end
end