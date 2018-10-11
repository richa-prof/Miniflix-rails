class WelcomeController < ApplicationController

  def index
    render json: { success: true }
  end

  def api_help
    @target_host = "#{ENV['RAILS_API_HOST']}/api/vm1/"
  end
end
