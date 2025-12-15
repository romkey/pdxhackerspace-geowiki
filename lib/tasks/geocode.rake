# frozen_string_literal: true

namespace :geocode do
  desc "Backfill addresses for external resource locations missing addresses (respects Nominatim rate limit)"
  task backfill_addresses: :environment do
    require "net/http"
    require "json"

    locations = ResourceExternalLocation.where(address: [nil, ""])
    total = locations.count

    if total.zero?
      puts "No external locations need address backfilling."
      exit
    end

    puts "Found #{total} external location(s) without addresses."
    puts "This will take at least #{total} seconds due to rate limiting."
    puts "Press Ctrl+C to cancel, or wait 5 seconds to continue..."
    sleep 5

    success = 0
    failed = 0

    locations.find_each.with_index do |location, index|
      print "[#{index + 1}/#{total}] Location ##{location.id} (#{location.latitude}, #{location.longitude})... "

      begin
        address = reverse_geocode(location.latitude, location.longitude)

        if address
          location.update!(address: address)
          puts "✓ #{address.truncate(60)}"
          success += 1
        else
          puts "✗ No address found"
          failed += 1
        end
      rescue StandardError => e
        puts "✗ Error: #{e.message}"
        failed += 1
      end

      # Nominatim requires max 1 request per second
      sleep 1.1 if index < total - 1
    end

    puts
    puts "Done! Successfully updated: #{success}, Failed: #{failed}"
  end

  def reverse_geocode(lat, lng)
    uri = URI("https://nominatim.openstreetmap.org/reverse")
    uri.query = URI.encode_www_form(lat: lat, lon: lng, format: "json")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 10

    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "Geowiki/#{Geowiki::VERSION} (geocode backfill task)"

    response = http.request(request)

    if response.code == "200"
      data = JSON.parse(response.body)
      if data["display_name"]
        # Shorten address - remove country
        parts = data["display_name"].split(", ")
        parts = parts[0..-2] if parts.length > 4
        parts.join(", ")
      end
    else
      raise "HTTP #{response.code}: #{response.message}"
    end
  end
end

