# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!

  private

  def authenticate_user!
    return if current_user

    redirect_to login_path, alert: "Please log in to continue."
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def require_admin!
    return if current_user&.admin?

    redirect_to root_path, alert: "You must be an admin to access this page."
  end

  helper_method :current_user
end
