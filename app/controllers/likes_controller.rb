class LikesController < ApplicationController

  def create
    @blog = Blog.find(params[:blog_id])
    like = @blog.likes.new
    like.user_id = current_staff_user.id
    like.save
    # redirect_to blog
  end

  def destroy
    @blog = Blog.find(params[:blog_id])
    like = @blog.likes.find_by(user_id: current_staff_user.id)
    like.destroy
    # redirect_to blog
  end
end
