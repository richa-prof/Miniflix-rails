class Admin::MailchimpGroupsController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :set_mailchimp_group, only: [:show, :edit, :update, :destroy]

  def index
    @mailchimp_groups = MailchimpGroup.all
  end

  def new
    @mailchimp_group = MailchimpGroup.new
  end

  def create
    @mailchimp_group = MailchimpGroup.new(mailchimp_group_params)

    respond_to do |format|
      if @mailchimp_group.save
        format.html { redirect_to admin_mailchimp_groups_url,
                      notice: I18n.t('flash.mailchimp_group.successfully_saved') }
      else
        format.html { render :new, notice: @mailchimp_group.errors.full_messages[0] }
      end
    end
  end

  def show
  end

  def edit
  end

  def update
    respond_to do |format|
      if @mailchimp_group.update(mailchimp_group_params)
        format.html { redirect_to admin_mailchimp_groups_url,
                      notice: I18n.t('flash.mailchimp_group.successfully_updated') }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    if @mailchimp_group
      if @mailchimp_group.destroy
        redirect_to admin_mailchimp_groups_path, notice: I18n.t('flash.mailchimp_group.successfully_deleted')
      else
        redirect_to admin_mailchimp_groups_path, notice: @mailchimp_group.errors.full_messages[0]
      end
    else
      redirect_to admin_mailchimp_groups_path, notice: I18n.t('flash.mailchimp_group.not_found', id: params[:id])
    end
  end

  private

  def mailchimp_group_params
    params.require(:mailchimp_group).permit(:list_id, :name)
  end

  def set_mailchimp_group
    begin
      @mailchimp_group = MailchimpGroup.friendly.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      redirect_to admin_mailchimp_groups_path, notice: I18n.t('flash.mailchimp_group.not_found', id: params[:id])
    end
  end
end
