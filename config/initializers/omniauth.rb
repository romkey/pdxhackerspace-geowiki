# Load custom Authentik strategy
require_relative "../../lib/omniauth/strategies/authentik"

Rails.application.config.middleware.use OmniAuth::Builder do
  if ENV["AUTHENTIK_CLIENT_ID"].present? && ENV["AUTHENTIK_CLIENT_SECRET"].present?
    provider :authentik,
      ENV["AUTHENTIK_CLIENT_ID"],
      ENV["AUTHENTIK_CLIENT_SECRET"],
      {
        client_options: {
          site: ENV.fetch("AUTHENTIK_SITE", "https://authentik.example.com"),
          authorize_url: "/application/o/authorize/",
          token_url: "/application/o/token/",
          userinfo_url: "/application/o/userinfo/"
        },
        scope: "openid email profile admin"
      }
  end
end

OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true

