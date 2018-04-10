class BlogsController < ApplicationController
  before_action :authenticate_staff_user!, except: [:blog_profile, :show, :index]

  def index
    query = params[:blog_search_query]

    blogs = if query
              Blog.with_search_query(query)
            else
              Blog.all
            end

    @blogs = blogs.order('created_at DESC').paginate(:page => params[:page], :per_page => 4)
  end

  def new
    set_current_staff_user_as_instance
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
    set_current_staff_user_as_instance
    @blog = Blog.find(params[:id])
    @blog_user = @blog.user
    @comments = @blog.comments.order('created_at DESC').paginate(:page => params[:page], :per_page => 3)
    @comment = Comment.new
  end

  def edit
    @blog = current_staff_user.blogs.find(params[:id])
  end

  def update
    set_current_staff_user_as_instance
    @blog = Blog.find(params[:id])
    if @blog.update(blog_params)
      redirect_to @blog
    else
      render :edit
    end
  end

  def destroy
    set_current_staff_user_as_instance
    @blog = Blog.find(params[:id])
    @blog.destroy
    redirect_to root_path
  end

  def blog_profile
    @staff = User.staff.friendly.find(params[:id])
    @own_profile = current_staff_user == @staff
    redirect_to root_path if @own_profile

    fetch_and_set_blogs_for(@staff)
  end

  def dashboard
    fetch_and_set_blogs_for(current_staff_user)
    set_current_staff_user_as_instance
    @own_profile = true
  end

  private

  def blog_params
    params.require(:blog).permit(:title, :body, :featured_image)
  end

  def fetch_and_set_blogs_for(user)
    @staff_blogs = user.blogs.order('created_at DESC').paginate(:page => params[:page], :per_page => 6)
  end

  def set_current_staff_user_as_instance
    @staff = current_staff_user
  end
end
