class Admin::StaffsController < ApplicationController
  before_action :authenticate_admin_user!

  def index
    @staff_members = User.staff
  end

  # GET /admin/staff_members/new
  def new
    @staff_member = User.new
  end

  # POST /admin/staff_members
  # POST /admin/staff_members.json
  def create
    @staff_member = User.new(admin_staff_member_params)
    @staff_member.role = User.roles[:staff]
    @staff_member.sign_up_from = User.sign_up_froms[:Web]
    temp_password = SecureRandom.hex(8)
    @staff_member.password = temp_password
    @staff_member.temp_password = temp_password

    if @staff_member.save
      SendWelcomeStaffMailJob.perform_later(@staff_member.id)
      redirect_to admin_staffs_path
    else
      render :new
    end
  end

  def destroy
    staff = User.find(params[:id])
    if staff.destroy
      redirect_to admin_staffs_path
    end
  end

  # Email already exist validation.
  def check_email
    if params[:staff_member][:email].present?
      @user = User.find_by_email(params[:staff_member][:email]) || User.find_by_email(params[:staff_member][:email])
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
