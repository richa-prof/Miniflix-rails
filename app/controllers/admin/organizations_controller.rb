class Admin::OrganizationsController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :set_organization, only: [:edit, :update, :destroy]

  layout "admin"

  def index
    @organizations = Organization.all
  end

  # GET /admin/organizations/new
  def new
    @organization = Organization.new
  end

  # POST /admin/organizations
  # POST /admin/organizations.json
  def create
    @organization = Organization.new(organization_params)
    student_user = User.new(student_params)
    professor_user = User.new(professor_params)
    respond_to do |format|
      if @organization.save && student_user.save && professor_user.save
        OrganizationsUsersInfo.create(user_id: student_user.id, organization_id: @organization.id, role: params[:student][:role])
        OrganizationsUsersInfo.create(user_id: professor_user.id, organization_id: @organization.id, role: params[:professor][:role])
        format.html { redirect_to admin_organizations_path,
                      notice: I18n.t('flash.organization.successfully_created')  }
      else
        format.html { render :new }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /admin/organizations/1/edit
  def edit
  end

  # PATCH/PUT /admin/organizations/1
  # PATCH/PUT /admin/organizations/1.json
  def update
    respond_to do |format|
      if @organization.update(organization_params)
        format.html { redirect_to admin_organizations_path,
                      notice: I18n.t('flash.organization.successfully_updated') }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /admin/organizations/1
  # DELETE /admin/organizations/1.json
  def destroy
    @organization.users.each do |user|
      user.destroy
    end
    @organization.destroy

    respond_to do |format|
      format.html { redirect_to admin_organizations_path,
                    notice: I18n.t('flash.organization.successfully_deleted') }
      format.json { head :no_content }
    end
  end

  # Email already exist validation.
  def check_email
    target_email = params[:for_admin] == 'true' ? params[:professor][:email] : params[:student][:email]

    if target_email.present?
      @user = User.find_by_email(target_email)
    end

    respond_to do |format|
      format.json { render :json => !@user }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_organization
      @organization = Organization.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def organization_params
      params.require(:organization).permit(:org_name, :no_of_students)
    end

    def student_params
      params.require(:student).permit(:email, :password, :registration_plan, :subscription_plan_status)
    end

    def professor_params
      params.require(:professor).permit(:email, :password, :registration_plan, :subscription_plan_status)
    end
end
