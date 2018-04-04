class BlogsController < ApplicationController
  layout 'blog'
  before_action :authenticate_staff_user!

  def new
    @staff = current_staff_user
    @blog = current_staff_user.blogs.new
  end

  def create
    @blog = Blog.new(blog_params)
    @blog.user = current_staff_user
    if @blog.save
      redirect_to @blog
    else
      render :new
    end
  end

  def show
    @staff = current_staff_user
    @blog = Blog.find(params[:id])
  end

  def edit
    @blog = Blog.find(params[:id])
  end

  def update
    @staff = current_staff_user
    @blog = Blog.find(params[:id])
    if @blog.update(blog_params)
      redirect_to @blog
    else
      render :edit
    end
  end

  def destroy
    @staff = current_staff_user
    @blog = Blog.find(params[:id])
    @blog.destroy
    redirect_to root_path
  end

  def blog_profile
    set_staff
    @staff_blogs = @staff.blogs
    @own_profile = current_staff_user == @staff
  end

  def dashboard
    @staff_blogs = current_staff_user.blogs
    @own_profile = true
  end

  private

  def blog_params
    params.require(:blog).permit(:title, :body, :featured_image)
  end

  def set_staff
    @staff = User.staff.find(params[:id])
  end
end
