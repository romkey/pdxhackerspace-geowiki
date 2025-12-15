# frozen_string_literal: true

class JournalEntry < ApplicationRecord
  belongs_to :journable, polymorphic: true
  belongs_to :user, optional: true

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for_resources, -> { where(journable_type: "Resource") }
  scope :for_maps, -> { where(journable_type: "Map") }

  def action_icon
    case action
    when "created" then "plus-circle"
    when "updated" then "pencil"
    when "deleted" then "trash"
    else "journal"
    end
  end

  def action_color
    case action
    when "created" then "success"
    when "updated" then "primary"
    when "deleted" then "danger"
    else "secondary"
    end
  end

  def user_name
    user&.name || user&.email || "System"
  end

  def summary
    case action
    when "created"
      "created #{journable_type.downcase} \"#{journable_name}\""
    when "updated"
      "updated #{journable_type.downcase} \"#{journable_name}\""
    when "deleted"
      "deleted #{journable_type.downcase} \"#{details}\""
    else
      "#{action} #{journable_type.downcase}"
    end
  end

  def journable_name
    journable&.name || details || "Unknown"
  end
end
