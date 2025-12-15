# frozen_string_literal: true

require "omniauth/strategies/oauth2"

module OmniAuth
  module Strategies
    class Authentik < OmniAuth::Strategies::OAuth2
      option :name, :authentik

      option :client_options, {
        site: nil,
        authorize_url: "/application/o/authorize/",
        token_url: "/application/o/token/",
        userinfo_url: "/application/o/userinfo/",
      }

      uid { raw_info["sub"] || raw_info["email"] }

      info do
        {
          name: raw_info["name"] || raw_info["email"],
          email: raw_info["email"],
          nickname: raw_info["preferred_username"] || raw_info["email"],
        }
      end

      extra do
        {
          raw_info: raw_info,
        }
      end

      def raw_info
        @raw_info ||= access_token.get(userinfo_url).parsed
      end

      def userinfo_url
        path = options.client_options[:userinfo_url] || "/application/o/userinfo/"
        if path.start_with?("http")
          path
        else
          "#{options.client_options[:site]}#{path}"
        end
      end

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end
