module Parsers
  class BaseParser
    def parse_message(msg_div, sender, destinatary, time = nil)
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
      msg = parser_klass.new.parse(msg_div)
      return unless msg # temp!
      return puts(msg.attributes) # temp
      msg.sender = sender
      msg.destinatary = destinatary
      msg.time ||= time
      process_read_message(msg)
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
        # TODO handle deleted messages!
        else
          # raise "Unhandled msg_type #{msg_div.try(:text)}"
          return "Unhandled msg_type #{msg_div.try(:text)}"
        end
      end
    end

    def process_read_message(msg)
      # TODO move this out of here (not client's responsibility)
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
end