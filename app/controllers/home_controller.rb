# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @map = Map.default_map
    @site_config = SiteConfig.instance

    # Get top 6 most viewed internal resources that have locations on the default map
    @top_internal = if @map
                      Resource
                        .visible_to(current_user)
                        .internal
                        .joins(:resource_locations)
                        .where(resource_locations: { map_id: @map.id })
                        .order(view_count: :desc)
                        .distinct
                        .limit(6)
                        .includes(resource_locations: :map)
                    else
                      []
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

    # Total counts for badges
    @internal_count = Resource.visible_to(current_user).internal.count
    @external_count = Resource.visible_to(current_user).external.count

    # For backwards compatibility
    @top_resources = @top_internal
  end
end
