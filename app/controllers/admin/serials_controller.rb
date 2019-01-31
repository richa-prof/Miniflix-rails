class Admin::SerialsController < ApplicationController
  before_action :authenticate_admin_user!

  def index
    @admin_serials = Serial.all
  end
end
