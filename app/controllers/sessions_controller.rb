# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create, :omniauth, :failure]

  def new
    @user = User.new
  end

  def create
    email = params[:email]
    password = params[:password]

    user = authenticate_local_admin(email, password) ||
           authenticate_local_user(email, password) ||
           authenticate_database_user(email, password)

    if user
      session[:user_id] = user.id
      redirect_to root_path, notice: login_notice_for(user)
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_content
    end
  end

  def omniauth
    user = User.from_omniauth(request.env["omniauth.auth"])
    if user.save
      session[:user_id] = user.id
      redirect_to root_path, notice: "Logged in successfully."
    else
      redirect_to login_path, alert: "Authentication failed: #{user.errors.full_messages.join(', ')}"
    end
  end

  def failure
    redirect_to login_path, alert: "Authentication failed. Please try again."
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Logged out successfully."
  end

  private

  def authenticate_local_admin(email, password)
    return nil unless local_admin_credentials_match?(email, password)

    find_or_create_local_user(
      email: email,
      name: ENV.fetch("LOCAL_ADMIN_NAME", "Local Admin"),
      password: password,
      is_admin: true
    )
  end

  def authenticate_local_user(email, password)
    return nil unless local_user_credentials_match?(email, password)

    find_or_create_local_user(
      email: email,
      name: ENV.fetch("LOCAL_USER_NAME", "Local User"),
      password: password,
      is_admin: false
    )
  end

  def authenticate_database_user(email, password)
    user = User.find_by(email: email)
    user if user&.authenticate(password)
  end

  def local_admin_credentials_match?(email, password)
    admin_email = ENV.fetch("LOCAL_ADMIN_EMAIL", nil)
    admin_password = ENV.fetch("LOCAL_ADMIN_PASSWORD", nil)

    admin_email.present? && admin_password.present? &&
      email == admin_email && password == admin_password
  end

  def local_user_credentials_match?(email, password)
    user_email = ENV.fetch("LOCAL_USER_EMAIL", nil)
    user_password = ENV.fetch("LOCAL_USER_PASSWORD", nil)

    user_email.present? && user_password.present? &&
      email == user_email && password == user_password
  end

  def find_or_create_local_user(email:, name:, password:, is_admin:)
    user = User.find_or_initialize_by(email: email)
    user.name = name
    user.is_admin = is_admin
    user.password = password
    user.provider = nil
    user.uid = nil
    user.save!
    user
  end

  def login_notice_for(user)
    user.admin? ? "Logged in as admin." : "Logged in successfully."
  end
end
