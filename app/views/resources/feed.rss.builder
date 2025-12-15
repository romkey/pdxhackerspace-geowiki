xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "Geowiki Resources"
    xml.description "Recent resources from Geowiki"
    xml.link resources_url
    xml.language "en"
    xml.lastBuildDate @resources.first&.created_at&.rfc2822 || Time.current.rfc2822
    xml.tag! "atom:link", href: feed_resources_url(format: :rss), rel: "self", type: "application/rss+xml"

    @resources.each do |resource|
      xml.item do
        xml.title resource.name
        xml.link resource_url(resource)
        xml.guid resource_url(resource), isPermaLink: true
        xml.pubDate resource.created_at.rfc2822

        description = []
        description << (resource.internal? ? "Internal resource" : "External resource")
        
        if resource.internal? && resource.resource_locations.any?
          maps = resource.resource_locations.map { |loc| loc.map.name }.uniq
          description << "Located on: #{maps.join(', ')}"
        elsif resource.external? && resource.resource_external_locations.any?
          description << "#{resource.resource_external_locations.count} geographic location(s)"
        end

        if resource.resource_urls.any?
          description << "#{resource.resource_urls.count} source URL(s)"
        end

        if resource.parent
          description << "Child of: #{resource.parent.name}"
        end

        xml.description description.join(" • ")
      end
    end
  end
end

