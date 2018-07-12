class RobotsController < ApplicationController
  layout false

  def index
    if canonical_host?
      render 'allow'
    else
      render 'disallow'
    end
  end

  private

  def canonical_host?
    Rails.logger.debug "<<<< RobotsController::request.host : #{request.host} <<<<"

    request.host == 'blog.miniflix.tv'
  end
end