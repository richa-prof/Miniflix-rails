class LikesController < ApplicationController
  before_action :authenticate_staff_user!

  def create
    @blog = Blog.find(params[:blog_id])
    like = @blog.likes.new
    like.user_id = current_staff_user.id
    like.save
  end

  def destroy
    @blog = Blog.find(params[:blog_id])
    like = @blog.likes.find_by(user_id: current_staff_user.id)
    like.destroy
  end
end
