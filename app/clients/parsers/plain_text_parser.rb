module Parsers
  class PlainTextParser < BaseParser
    def parse(msg_div)
      msg = Message.new(msg_type: :plain_text)
      txt_span = msg_div.search('span.selectable-text.copyable-text')
      msg.text = clean_msg_text(txt_span.to_html)
      time_and_sender_data_str = msg_div.search('div.copyable-text').attribute('data-pre-plain-text')
      msg.time, msg.sender = extract_time_and_sender(time_and_sender_data_str)
      msg.direction = extract_direction(msg_div)
      msg.status = msg.direction.sent? ? extract_status(msg_div) : :not_available
      msg
    end

    private

    def extract_status(msg_div)
      data_icon = msg_div.search('div[role=button] > div > span').attribute('data-icon')
      case data_icon
      when 'msg-check'
        :check
      when 'msg-dblcheck-ack'
        :double_check_ack
      when 'msg-dblcheck'
        :double_check
      when 'msg-time'
        :clock
      else
        raise "Unhandled status data icon '#{data_icon}' in msg #{msg_div.try(:text)}"
      end
    end

    def extract_direction(msg_div)
      if msg_div.search('div.message-in').any?
        :received
      elsif msg_div.search('div.message-out').any?
        :sent
      else
        raise "No direction class found in msg div: #{msg_div.try(:text)}"
      end
    end

    def extract_time_and_sender(str)
      time_str = str[/\[.*?\]/]
      sender = str.gsub(time_str, '').delete(':').strip
      strp_format = '[%I:%M %p, %m/%e/%Y]'
      time = Time.strptime(time_str, strp_format)
      [time, sender]
    end

    def clean_msg_text(html_str)
      clean_span_tag clean_emojied_text clean_styled_text clean_link_text html_str
    end

    def clean_span_tag(html_str)
      html_str.gsub(initial_regex, '')
              .gsub(final_regex, '')
    end

    def clean_emojied_text(html_str)
      html_str.gsub(pre_emoji_regex, '')
              .gsub(post_emoji_regex, ' ') # deliberately gsubed for space
    end

    def clean_styled_text(html_str)
      html_str.gsub(pre_styled_text_regex, '')
              .gsub(post_styled_text_regex, '')
    end

    def clean_link_text(html_str)
      html_str.gsub(pre_link_regex, '')
              .gsub(post_link_regex, '')
    end

    def pre_emoji_regex
      /<img crossorigin="anonymous" src="data:image\/gif;base64,(\w|\/)*" alt=".{1,4}" draggable="false" class="b(\d{1,3}) emoji wa selectable-text invisible-space copyable-text" data-plain-text="/
    end

    def post_emoji_regex
      /" style="background-position: -?(\d{1,3})px -?(\d{1,3})px;">/
    end

    def pre_styled_text_regex
      /<(strong|em|code|del) class="selectable-text invisible-space copyable-text" data-app-text-template="(\*|_|```|~)\$\{appText\}(\*|_|```|~)">/
    end

    def post_styled_text_regex
      /<\/(?:strong|em|code|del)>/
    end

    # not in use
    def full_styled_text_regex
      /<(?:strong|em|code|del) class="selectable-text invisible-space copyable-text" data-app-text-template="(?:\*|_|```|~)\$\{appText\}(?:\*|_|```|~)">(.*)<\/(?:strong|em|code|del)>/
    end

    def pre_link_regex
      /<a href="[^>]*" title="[^>]*" target="_blank" rel="noopener noreferrer" class="selectable-text invisible-space copyable-text">/
    end

    def post_link_regex
      '</a>'
    end

    def initial_regex
      /\A<span dir="(ltr|auto)" class="selectable-text invisible-space copyable-text">/
    end

    def final_regex
      /<\/span>\z/
    end
  end
end