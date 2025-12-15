# frozen_string_literal: true

module Journable
  extend ActiveSupport::Concern

  included do
    has_many :journal_entries, as: :journable, dependent: :destroy

    # Track nested changes before save
    attr_accessor :_nested_changes

    before_save :capture_nested_changes
    after_save :journal_save
    before_destroy :journal_destroy
  end

  class_methods do
    # Store current user in thread-local variable for callbacks
    def current_user=(user)
      Thread.current[:journable_current_user] = user
    end

    def current_user
      Thread.current[:journable_current_user]
    end
  end

  private

  def capture_nested_changes
    @_nested_changes = {}
    @_was_new_record = new_record?
    
    # Capture nested changes for Resource associations
    if respond_to?(:resource_locations)
      count = count_pending_nested_changes(:resource_locations)
      @_nested_changes["locations"] = count if count > 0
    end
    
    if respond_to?(:resource_urls)
      count = count_pending_nested_changes(:resource_urls)
      @_nested_changes["urls"] = count if count > 0
    end
    
    if respond_to?(:resource_external_locations)
      count = count_pending_nested_changes(:resource_external_locations)
      @_nested_changes["external_locations"] = count if count > 0
    end
    
    # Capture nested changes for Map associations
    if respond_to?(:map_maintainers)
      count = count_pending_nested_changes(:map_maintainers)
      @_nested_changes["maintainers"] = count if count > 0
    end
  end

  def count_pending_nested_changes(association_name)
    association = send(association_name)
    count = 0
    
    association.each do |record|
      if record.new_record?
        count += 1
      elsif record.marked_for_destruction?
        count += 1
      elsif record.changed?
        count += 1
      end
    end
    
    count
  end

  def journal_save
    if @_was_new_record
      journal_create
    else
      journal_update
    end
  end

  def journal_create
    changes = saved_changes.except("id", "created_at", "updated_at")
    
    # Add nested changes
    @_nested_changes.each do |key, count|
      changes[key] = "#{count} added"
    end
    
    journal_entries.create!(
      user: self.class.current_user,
      action: "created",
      details: name,
      changes_made: changes
    )
  end

  def journal_update
    direct_changes = saved_changes.except("updated_at", "view_count")
    
    # Build a summary of what changed
    changes_summary = {}
    
    # Add direct attribute changes
    direct_changes.each do |attr, values|
      changes_summary[attr] = values
    end
    
    # Add nested changes captured before save
    @_nested_changes.each do |key, count|
      changes_summary[key] = "#{count} modified"
    end
    
    # Only create journal entry if something actually changed
    return if changes_summary.empty?

    journal_entries.create!(
      user: self.class.current_user,
      action: "updated",
      details: name,
      changes_made: changes_summary
    )
  end

  def journal_destroy
    # Create a journal entry that will survive the deletion
    JournalEntry.create!(
      journable_type: self.class.name,
      journable_id: id,
      user: self.class.current_user,
      action: "deleted",
      details: name,
      changes_made: attributes.except("created_at", "updated_at")
    )
  end
end
