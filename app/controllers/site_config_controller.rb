# frozen_string_literal: true

class SiteConfigController < ApplicationController
  before_action :require_admin!
  before_action :set_site_config

  def show
    redirect_to edit_site_config_path
  end

  def edit; end

  def update
    if @site_config.update(site_config_params)
      redirect_to edit_site_config_path, notice: "Site configuration updated successfully."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_site_config
    @site_config = SiteConfig.instance
  end

  def site_config_params
    params.expect(site_config: [:organization_name, :address, :latitude, :longitude])
  end
end
