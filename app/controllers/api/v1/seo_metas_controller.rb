class Api::V1::SeoMetasController < Api::V1::ApplicationController
  before_action :set_seo_meta, only: [:index]

  def index
    response = if @seo_meta.present?
                  { success: true,
                    meta_data: serialize_seo_meta(@seo_meta) }
                else
                  { success: false,
                    message: I18n.t('flash.seo_meta.not_found', page_name: page_name) }
                end

    render json: response
  end

  private

  def serialize_seo_meta(seo_meta_obj)
    ActiveModelSerializers::SerializableResource.new(seo_meta_obj,
    each_serializer: Api::V1::SeoMetaSerializer)
  end

  def set_seo_meta
    @seo_meta = SeoMetum.static_seo_metas.find_by_page_name(page_name)
  end

  def page_name
    params[:page_name]
  end
end
