class Admin::FreeMembersController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :set_free_member, only: [:edit, :update, :destroy]

  layout "admin"

  # GET /admin/free_members
  # GET /admin/free_members.json
  def index
    @free_members = FreeMember.all
  end

  # GET /admin/free_members/new
  def new
    @free_member = FreeMember.new
  end

  # POST /admin/free_members
  # POST /admin/free_members.json
  def create
    @free_member = FreeMember.new(admin_free_member_params)

    respond_to do |format|
      if @free_member.save
        UserNotifier.invite_free_member(@free_member).deliver
        format.html { redirect_to admin_free_members_url,
                      notice: I18n.t('flash.free_member.successfully_created')  }
      else
        format.html { render :new }
        format.json { render json: @free_member.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /admin/free_members/1/edit
  def edit
  end

  # PATCH/PUT /admin/free_members/1
  # PATCH/PUT /admin/free_members/1.json
  def update
    respond_to do |format|
      if @free_member.update(admin_free_member_params)
        format.html { redirect_to admin_free_members_url,
                      notice: I18n.t('flash.free_member.successfully_updated') }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /admin/free_members/1
  # DELETE /admin/free_members/1.json
  def destroy
    @free_member = FreeMember.find(params[:id])
    @user = User.find_by_email(@free_member.email)
    if @user
      @user.destroy
    end
    @free_member.destroy

    respond_to do |format|
      format.html { redirect_to admin_free_members_url,
                    notice: I18n.t('flash.free_member.successfully_deleted') }
      format.json { head :no_content }
    end
  end

  # Email already exist validation.
  def check_email
    target_email = params[:free_member][:email]

    if target_email.present?
      @user = FreeMember.find_by_email(target_email) || User.find_by_email(target_email)
    end

    respond_to do |format|
      format.json { render :json => !@user }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_free_member
      @free_member = FreeMember.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_free_member_params
      params.require(:free_member).permit(:email)
    end
end
