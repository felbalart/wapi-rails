class Matcher
  def try_confirm(otbx_msg)
    raise "Cannot match outbox message with status != :sent #{otbx_msg.to_json}" unless otbx_msg.outbox_status&.sent?
    matching_msgs = matches_query(otbx_msg)
    case matching_msgs.count
      when 0
        return false
      when 1
        matching_msg = matching_msgs.first
        save_match(otbx_msg, matching_msg)
        matching_msg
      else
        raise "Multiple matching messages for Outbox Msg #{otbx_msg.to_json}"
    end
  end

  private

  def matches_query(otbx_msg)
    Message.where(
        account: otbx_msg.account,
        msg_type: otbx_msg.msg_type,
        destinatary: otbx_msg.destinatary,
        text: otbx_msg.content,
        time: otbx_msg.sent_at..(otbx_msg.sent_at + 1.minute),
        direction: :sent
    )
  end

  def save_match(otbx_msg, msg)
    otbx_msg.message = msg
    otbx_msg.outbox_status = :confirmed
    otbx_msg.save!
  end
end
