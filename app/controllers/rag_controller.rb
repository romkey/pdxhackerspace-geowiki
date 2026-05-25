# frozen_string_literal: true

class RagController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    resources = Resource.includes(
      :parent, :children, :resource_urls,
      resource_locations: { map: :rooms },
      resource_external_locations: []
    ).where(admin_only: false)

    export_data = {
      generated_at: Time.current.iso8601,
      count: resources.count,
      resources: resources.map { |r| resource_to_rag(r) },
    }

    render json: export_data
  end

  private

  def resource_to_rag(resource)
    base = {
      id: resource.id,
      name: resource.name,
      description: resource.description,
      type: resource.internal? ? "internal" : "external",
      added_at: resource.created_at.iso8601,
      updated_at: resource.updated_at.iso8601,
    }

    if resource.parent && !resource.parent.admin_only?
      base[:parent] = { id: resource.parent_id, name: resource.parent.name }
    end

    public_children = resource.children.where(admin_only: false)
    base[:children] = public_children.map { |c| { id: c.id, name: c.name } } if public_children.any?

    if resource.resource_urls.any?
      base[:web_links] = resource.resource_urls.map do |url|
        { label: url.label, url: url.url }
      end
    end

    base[:locations] = if resource.internal?
                         resource.resource_locations.map { |loc| internal_location(loc) }
                       else
                         resource.resource_external_locations.map { |loc| external_location(loc) }
                       end

    base
  end

  def internal_location(location)
    result = {
      map: location.map.name,
    }

    room = location.room
    if room
      result[:room] = room.name
      result[:room_height_inches] = room.height.to_f if room.height.present?

      if location.map.has_scale?
        rel_x_percent = location.x - room.left
        rel_y_percent = location.y - room.top

        rel_x_units = location.map.percent_to_real_distance(rel_x_percent)
        rel_y_units = location.map.percent_to_real_distance(rel_y_percent)

        result[:position_in_room] = {
          x: rel_x_units&.round(1),
          y: rel_y_units&.round(1),
          unit: location.map.scale_unit,
        }

        result[:position_description] = location.position_description(include_distance: true)
      else
        result[:position_percent] = { x: location.x.to_f.round(2), y: location.y.to_f.round(2) }
        result[:position_description] = location.position_description(include_distance: false)
      end
    else
      result[:position_percent] = { x: location.x.to_f.round(2), y: location.y.to_f.round(2) }
    end

    result[:elevation_inches] = location.elevation.to_f if location.elevation.present?

    result
  end

  def external_location(location)
    result = {
      coordinates: {
        latitude: location.latitude.to_f,
        longitude: location.longitude.to_f,
      },
    }

    result[:address] = location.address if location.address.present?
    result[:website] = location.url if location.url.present?
    result[:label] = location.label if location.label.present?

    result
  end
end
