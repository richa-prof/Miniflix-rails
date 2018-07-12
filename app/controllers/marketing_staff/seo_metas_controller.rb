class MarketingStaff::SeoMetasController < ApplicationController
  before_action :authenticate_marketing_staff_user!
  layout 'admin'

  def index
    @seo_metas = SeoMetum.static_seo_metas
  end

  def new
    @seo_meta = SeoMetum.new
  end

  def create
    @seo_meta = SeoMetum.new(seo_meta_params)

    if @seo_meta.save
      flash[:notice] = I18n.t('flash.seo_meta.successfully_created')
      redirect_to marketing_staff_seo_metas_path
    else
      flash[:notice] = @seo_meta.errors.full_messages[0]
      render :new
    end
  end

  def show
    @seo_meta = SeoMetum.static_seo_metas.find(params[:id])
  end

  def edit
    @seo_meta = SeoMetum.static_seo_metas.find(params[:id])
  end

  def update
    @seo_meta = SeoMetum.static_seo_metas.find(params[:id])

    if @seo_meta.update_attributes(seo_meta_params)
      flash[:notice] = I18n.t('flash.seo_meta.successfully_updated')
      redirect_to marketing_staff_seo_metas_path
    else
      flash[:notice] = @seo_meta.errors.full_messages[0]
      render :edit
    end
  end

  def destroy
    @seo_meta = SeoMetum.static_seo_metas.find(params[:id])

    @seo_meta.destroy
    flash[:notice] = I18n.t('flash.seo_meta.successfully_deleted')
    redirect_to marketing_staff_seo_metas_path
  end

  private
    def seo_meta_params
      params.require(:seo_metum).permit(:page_name, :browser_title, :meta_keywords, :meta_description)
    end
end
