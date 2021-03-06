module Parsers
  class BaseParser
    def parse_message(msg_div, time = nil)
      msg_type = find_msg_type(msg_div)
      case msg_type
        when :ignorable_tag
          return
        when :deleted
          return puts("Skiped delete message #{msg_div.try(:text)}")
        when :date_tag
          return DateTagParser.new.parse(msg_div)
        else
        parser_klass = Object.const_get "Parsers::#{msg_type.to_s.classify}Parser"
        msg = parser_klass.new.parse(msg_div) # Warning:  might be nil as some parsers are pending TODO
        return msg
      end
    end

    def find_msg_type(msg_div)
      if msg_div.search('.message-in,.message-out').empty?
        # Tag
        if msg_div.search("span[dir='auto']").any?
          return :date_tag # TODO handle weird blank-text date tag found at the top of a conv
        else
          return :ignorable_tag
        end
      else
        # Message
        if msg_div.search('audio').any?
          return :audio
        elsif msg_div.search('.video-thumb').any?
          return :video
        elsif msg_div.search("img[style='width: 100%;']").any? || msg_div.search("img[style='height: 100%;']").any?
          return :image # TODO check GIFs and multiple-images package compatibility
        elsif msg_div.search('span[dir=auto]').any? && msg_div.search("a[rel='noopener noreferrer']").any?
          return :link
        elsif msg_div.search("span[data-icon='recalled-in']").any?
          return :deleted
        elsif msg_div.search("img[draggable='false'][style='visibility: visible;']").any?
          return :giant_emoji
        elsif msg_div.search('span[dir=ltr]').any? || msg_div.search('span[dir=auto]').any?
          return :plain_text
        else
          # raise "Unhandled msg_type #{msg_div.try(:text)}"
          return "Unhandled msg_type #{msg_div.try(:text)}"
        end
      end
    end
  end
end