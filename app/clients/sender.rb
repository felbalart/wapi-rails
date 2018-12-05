class Sender < BaseClient
  def send_otbx_msg(otbx_msg)
    send_raw(otbx_msg.destinatary, otbx_msg.content)
    otbx_msg.update(outbox_status: :sent, sent_at: Time.current.change(sec: 0, usec: 0))
  end

  def send_raw(destinatary, msg)
    ensure_logged
    load_conv(destinatary)
    send_msg_in_current_conv(msg)
  end

  def send_msg_in_current_conv(msg)
    browser.document.execute_script send_msg_js(msg)
  end

  private

  def send_msg_js(msg)
    %Q{
      window.InputEvent = window.Event || window.InputEvent;
      var event = new InputEvent('input', {
        bubbles: true
      });
      var textbox = document.querySelector('div._2S1VP');
      textbox.textContent = "#{msg.html_safe}";
      textbox.dispatchEvent(event);

      document.querySelector("button._35EW6").click();
    }
  end

  def load_conv(destinatary)
    search_bar_div_selector = "#side > div[tabindex='-1']"
    search_input = browser.search("#{search_bar_div_selector} input.copyable-text.selectable-text[type='text']")
    search_input.set(destinatary)
    result = browser.search("#pane-side > div[tabindex='-1'] span.matched-text")
    result.wait(:present)
    raise "Search results count different than one for #{destinatary}" unless result.count == 1
    result.click
    close_search_button = browser.search("#{search_bar_div_selector} span[data-icon='x-alt']")
    close_search_button.wait(:present)
    close_search_button.click
  end
end