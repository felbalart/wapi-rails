class BaseClient
  attr_accessor :browser
  def initialize(account, browser: nil, driver: :chrome)
    @browser = browser || Pincers.for_webdriver(driver)
    @account = account
  end

  WHATSAPP_WEB_URL = 'http://web.whatsapp.com'
  def ensure_logged
    return true if logged?
    browser.goto WHATSAPP_WEB_URL
    browser.wait(timeout: 60) { logged? }
    # TODO ensure that gets logged with the corresponding account
    puts 'Logged succesfully! :)'
    true
  end

  def logged?
    browser.search('span[data-icon=chat]').present?
  end
end