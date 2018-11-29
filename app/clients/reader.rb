class Reader
  def initialize(driver)
    @driver = driver
    @messages = []
  end

  def read(since)
    ensure_logged
    conv_divs_updated_since(since).each do |conv_div|
      read_conv(conv_div, since)
    end
  rescue StandardError => ex
    binding.pry
  end

  private

  def read_conv(conv_div, since)
    conv_div.click
    read_current_conv(since)
    binding.pry
  end

  def read_current_conv(since)
    sender = 'temp_send' # TODO read sender & destinatary name
    destinatary = 'temp_dest'
    msgs_divs = browser.search("[id='main'] .copyable-area [tabindex='0'] > div:last-child > div")
    # TODO scroll down and read according to 'since' param, instead of just all visible in not-scrolled view
    msgs = msgs_divs.map { |md| Parsers::BaseParser.new.parse_message(md, sender, destinatary) }.compact
    @messages += msgs
  end

  def conv_divs_updated_since(since)
    # TODO: scroll down to cover beyond the first 18 convs
    pane_side = browser.search("[id='pane-side']")
    conv_div = pane_side.search('div').find { |d| d.attribute('style').include?('z-index') }
    conv_div_class = conv_div.attribute('class')
    conv_divs = pane_side.search(".#{conv_div_class}")
    date_filtered_conv_divs = conv_divs.reject do |cd|
      date_data = cd.text.split("\n").second
      parse_conv_div_date(date_data) < since
    end
    temp_print(conv_divs, 'Todos')
    temp_print(date_filtered_conv_divs, "Filtrados con fecha #{since}")
  end

  def temp_print(cds, nombre)
    puts "nombre: #{nombre} tiene #{cds.count} elementos"
    cds.each_with_index {|eldiv, i| puts(i.to_s + ". " + eldiv.text) }
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

  def browser
    @browser ||= Pincers.for_webdriver @driver
  end
end