module Rails
  class PwaController < ActionController::Base
    def service_worker
      render file: Rails.root.join("app/views/pwa/service-worker.js"), content_type: "application/javascript"
    end

    def manifest
      render file: Rails.root.join("app/views/pwa/manifest.json"), content_type: "application/json"
    end
  end
end

