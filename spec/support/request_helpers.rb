# frozen_string_literal: true

module RequestHelpers
  # ApplicationController uses `allow_browser versions: :modern`, which rejects
  # requests without a modern User-Agent.
  MODERN_USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 " \
                      "(KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

  def browser_headers
    { "User-Agent" => MODERN_USER_AGENT }
  end

  def log_in_as(user, password: user.password)
    post login_path, params: { email: user.email, password: password }, headers: browser_headers
  end
end
