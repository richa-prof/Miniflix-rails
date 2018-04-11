class CommentsController < ApplicationController

  def create
    @blog = Blog.find(params[:blog_id])
    comment = @blog.comments.new(comment_params)
    comment.user_id = current_staff_user.id if current_staff_user
    comment.save
    @comments = @blog.comments.order('created_at DESC').paginate(:page => params[:page], :per_page => 3)
  end

  def index
    @blog = Blog.find(params[:blog_id])
    @comments = @blog.comments.order('created_at DESC').paginate(:page => params[:page], :per_page => 3)
  end

  private

  def comment_params
    params.require(:comment).permit(:commenter, :body)
  end
end
