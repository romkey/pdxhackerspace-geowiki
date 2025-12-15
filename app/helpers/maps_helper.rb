# frozen_string_literal: true

module MapsHelper
  def format_slack_channel(channel)
    return nil if channel.blank?

    channel.start_with?("#") ? channel : "##{channel}"
  end
end
