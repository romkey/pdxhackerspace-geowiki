# frozen_string_literal: true

namespace :resources do
  desc "Export all internal resources with textual positions to JSON"
  task export_json: :environment do
    output_path = ENV.fetch("OUTPUT_PATH", "public/resources.json")

    resources = Resource.internal.includes(:parent, :resource_urls, resource_locations: :map)

    export_data = {
      generated_at: Time.current.iso8601,
      count: resources.count,
      resources: resources.map { |r| r.to_export_hash(include_distance: true) }
    }

    File.write(output_path, JSON.pretty_generate(export_data))
    puts "Exported #{resources.count} resources to #{output_path}"
  end

  desc "Export public resources only (excludes admin_only)"
  task export_public_json: :environment do
    output_path = ENV.fetch("OUTPUT_PATH", "public/resources.json")

    resources = Resource.internal.where(admin_only: false)
                        .includes(:parent, :resource_urls, resource_locations: :map)

    export_data = {
      generated_at: Time.current.iso8601,
      count: resources.count,
      resources: resources.map { |r| r.to_export_hash(include_distance: true) }
    }

    File.write(output_path, JSON.pretty_generate(export_data))
    puts "Exported #{resources.count} public resources to #{output_path}"
  end
end
