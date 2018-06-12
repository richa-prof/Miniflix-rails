class Admin::BlogSubscribersController < ApplicationController
  before_action :authenticate_admin_user!

  def index
    @blog_subscribers = BlogSubscriber.all
  end

  def destroy
    @blog_subscriber = BlogSubscriber.find_by_id(params[:id])

    if @blog_subscriber
      if @blog_subscriber.destroy
        redirect_to admin_blog_subscribers_path, notice: I18n.t('flash.blog_subscriber.successfully_deleted')
      else
        redirect_to admin_blog_subscribers_path, notice: @blog_subscriber.errors.full_messages[0]
      end
    else
      redirect_to admin_blog_subscribers_path, notice: I18n.t('flash.blog_subscriber.not_found', id: params[:id])
    end
  end

end
