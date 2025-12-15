class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create, :omniauth, :failure]

  def new
    @user = User.new
  end

  def create
    email = params[:email]
    password = params[:password]

    # Local admin login (environment variable based)
    if ENV["LOCAL_ADMIN_EMAIL"].present? && ENV["LOCAL_ADMIN_PASSWORD"].present?
      if email == ENV["LOCAL_ADMIN_EMAIL"] && password == ENV["LOCAL_ADMIN_PASSWORD"]
        user = User.find_or_initialize_by(email: email)
        user.name = ENV["LOCAL_ADMIN_NAME"].presence || "Local Admin"
        user.is_admin = true
        user.password = password
        user.provider = nil
        user.uid = nil
        user.save!

        session[:user_id] = user.id
        redirect_to root_path, notice: "Logged in as admin."
        return
      end
    end

    # Local user login (environment variable based, non-admin)
    if ENV["LOCAL_USER_EMAIL"].present? && ENV["LOCAL_USER_PASSWORD"].present?
      if email == ENV["LOCAL_USER_EMAIL"] && password == ENV["LOCAL_USER_PASSWORD"]
        user = User.find_or_initialize_by(email: email)
        user.name = ENV["LOCAL_USER_NAME"].presence || "Local User"
        user.is_admin = false
        user.password = password
        user.provider = nil
        user.uid = nil
        user.save!

        session[:user_id] = user.id
        redirect_to root_path, notice: "Logged in successfully."
        return
      end
    end

    # Regular database user login (if password is set)
    user = User.find_by(email: email)
    if user&.authenticate(password)
      session[:user_id] = user.id
      redirect_to root_path, notice: "Logged in successfully."
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
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
end

