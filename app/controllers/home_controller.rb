class HomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @map = Map.default_map
    @site_config = SiteConfig.instance
    
    # Get top 6 most viewed internal resources that have locations on the default map
    if @map
      @top_internal = Resource
        .visible_to(current_user)
        .internal
        .joins(:resource_locations)
        .where(resource_locations: { map_id: @map.id })
        .order(view_count: :desc)
        .distinct
        .limit(6)
        .includes(resource_locations: :map)
    else
      @top_internal = []
    end
    
    # Get top 6 most viewed external resources with locations
    @top_external = Resource
      .visible_to(current_user)
      .external
      .joins(:resource_external_locations)
      .order(view_count: :desc)
      .distinct
      .limit(6)
      .includes(:resource_external_locations)
    
    # For backwards compatibility
    @top_resources = @top_internal
  end
end
