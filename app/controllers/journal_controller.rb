# frozen_string_literal: true

class JournalController < ApplicationController
  before_action :require_admin!

  def index
    @entries = JournalEntry.includes(:user, :journable)
      .recent
      .limit(100)
  end
end
