class Admin::SerialsController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :set_admin_serial, only: [:show, :edit, :update, :destroy]


  def index
    @admin_serials = Serial.all
  end

  def new
    @admin_serial = Serial.new
  end
  def show
  end

  def edit
    #code
  end

  def destroy
    @admin_serial.destroy
    redirect_to admin_serials_url, notice: I18n.t('flash.serial.successfully_deleted')
  end
  private

  def set_admin_serial
    @admin_serial = Serial.friendly.find(params[:id])
  end
end
