# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Authentication" do
  describe "GET /" do
    it "renders the home page when logged out" do
      get root_path, headers: browser_headers

      expect(response).to have_http_status(:ok)
    end

    # Regression: json 3.x broke ActiveSupport's session cookie decoding, so any
    # request carrying a session cookie raised ArgumentError and returned 500.
    it "renders the home page after logging in with a database user" do
      user = create(:user)

      log_in_as(user)
      expect(response).to redirect_to(root_path)
      expect(cookies[Rails.application.config.session_options[:key]]).to be_present

      get root_path, headers: browser_headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /login" do
    it "rejects an invalid password" do
      user = create(:user)

      log_in_as(user, password: "wrong")

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "authenticated-only pages" do
    it "redirects to the login page when logged out" do
      get new_map_path, headers: browser_headers

      expect(response).to redirect_to(login_path)
    end

    it "is accessible when logged in" do
      log_in_as(create(:user))

      get new_map_path, headers: browser_headers

      expect(response).to have_http_status(:ok)
    end
  end

  describe "admin-only pages" do
    it "redirects logged-out users to the login page" do
      get journal_path, headers: browser_headers

      expect(response).to redirect_to(login_path)
    end

    it "redirects non-admin users to the home page" do
      log_in_as(create(:user))

      get journal_path, headers: browser_headers

      expect(response).to redirect_to(root_path)
    end

    it "is accessible to admins" do
      log_in_as(create(:user, :admin))

      get journal_path, headers: browser_headers

      expect(response).to have_http_status(:ok)
    end
  end
end
