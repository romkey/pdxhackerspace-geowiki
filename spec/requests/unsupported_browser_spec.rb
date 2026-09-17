# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Unsupported browsers" do
  it "renders the 406 page for browsers that fail allow_browser" do
    old_safari = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 " \
                 "(KHTML, like Gecko) Version/15.0 Safari/605.1.15"

    get root_path, headers: { "User-Agent" => old_safari }

    expect(response).to have_http_status(:not_acceptable)
    expect(response.body).to include("Your browser is not supported")
  end
end
