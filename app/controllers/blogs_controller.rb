class BlogsController < ApplicationController
  before_action :authenticate_staff_user!, except: [:blog_profile, :show, :index]

  def index
    @blogs = Blog.order('created_at DESC').paginate(:page => params[:page], :per_page => 4)
  end

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
    @blog_user = @blog.user
    @comments = @blog.comments.order('created_at DESC').paginate(:page => params[:page], :per_page => 3)
    @comment = Comment.new
  end

  def edit
    @blog = current_staff_user.blogs.find(params[:id])
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
    @own_profile = current_staff_user == @staff
    redirect_to root_path if @own_profile
    @staff_blogs = @staff.blogs
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
