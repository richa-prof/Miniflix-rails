class Admin::MarketingStaffsController < ApplicationController

  before_action :authenticate_admin_user!

  def index
    @staff_members = User.marketing_staff
  end

  # GET /admin/staff_members/new
  def new
    @staff_member = User.new
  end

  # POST /admin/staff_members
  # POST /admin/staff_members.json
  def create
    @staff_member = User.new(admin_staff_member_params)
    @staff_member.role = User.roles[:marketing_staff]
    temp_password = SecureRandom.hex(8)
    @staff_member.password = temp_password
    @staff_member.temp_password = temp_password

    if @staff_member.save
      SendWelcomeStaffMailJob.perform_later(@staff_member.id)
      redirect_to admin_marketing_staffs_path
    else
      render :new
    end
  end

  def destroy
    staff = User.friendly.find(params[:id])
    if staff.destroy
      redirect_to admin_marketing_staffs_path, notice: I18n.t('flash.marketing_staff.successfully_deleted')
    end
  end

  # Email already exist validation.
  def check_email
    if params[:user][:email].present?
      @user = User.find_by_email(params[:user][:email]) || User.find_by_email(params[:user][:email])
    else  
    end
    respond_to do |format|
      format.json { render :json => !@user }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def admin_staff_member_params
    params.require(:user).permit(:email, :name)
  end
end
