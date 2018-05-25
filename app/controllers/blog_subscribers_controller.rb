class BlogSubscribersController < ApplicationController

  def new
  end

  def create
    @blog_subscriber = BlogSubscriber.new(blog_subscriber_params)
    @blog_subscriber.save
  end

  private

  def blog_subscriber_params
    params.require(:blog_subscriber).permit(:email)
  end

end
