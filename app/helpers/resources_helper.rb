module ResourcesHelper
  def resource_type_badge(resource)
    if resource.internal?
      content_tag(:span, "Internal", class: "badge bg-primary")
    else
      content_tag(:span, "External", class: "badge bg-success")
    end
  end

  def format_coordinates(latitude, longitude)
    return nil unless latitude && longitude
    "#{latitude}, #{longitude}"
  end
end

