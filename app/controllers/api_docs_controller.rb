class ApiDocsController < ApplicationController
  layout false

  def v1
    spec_url = url_for(:controller => :api_docs, :action => :v1)  + '/api_v1.json'
    respond_template(spec_url)
  end

  def vm1
    spec_url = url_for(:controller => :api_docs, :action => :vm1)  + '/api_vm1.json'
    respond_template(spec_url)
  end

  def api_v1
  end

  def api_vm1
  end

  protected  
    def respond_template( spec_url)
      respond_to do |format|
        format.html do
          @swagger_doc_url = spec_url
          render :template => "api_docs/spec_template" 
        end
        format.json do
          @api_host = Utils.server_url_without_protocol
          @api_schemes = ["http"]
        end
      end
    end
end