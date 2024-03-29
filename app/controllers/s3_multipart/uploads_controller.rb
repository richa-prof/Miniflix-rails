module S3Multipart
  class UploadsController < ApplicationController

    def create
      begin
        upload = Upload.create(upload_params)
        upload.execute_callback(:begin, session)  # on_begin_callback
        response = upload.to_json
      rescue FileTypeError, FileSizeError => e
        response = {error: e.message}
      rescue => e
        Rails.logger.error "EXC: #{e.message}"
        Rails.logger.error e.backtrace.join("\n\t")
        response = { error: t("s3_multipart.errors.create") }
      ensure
        render :json => response
      end
    end

    def update
      return complete_upload if params[:parts]
      return sign_batch if params[:content_lengths]
      return sign_part if params[:content_length]
    end

    private

      def sign_batch
        begin
          response = Upload.sign_batch(params)
        rescue => e
          logger.error "EXC: #{e.message}"
          response = {error: t("s3_multipart.errors.update")}
        ensure
          render :json => response
        end
      end

      def sign_part
        begin
          response = Upload.sign_part(params)
        rescue => e
          logger.error "EXC: #{e.message}"
          response = {error: t("s3_multipart.errors.update")}
        ensure
          render :json => response
        end
      end

      def complete_upload
        begin
          response = Upload.complete(params)
          upload = Upload.find_by_upload_id(params[:upload_id])
          upload.update_attributes(location: response[:location])
          upload.execute_callback(:complete, session) # on_complete_callback
        rescue => e 
          logger.error "EXC: #{e.message}"
          response = {error: t("s3_multipart.errors.complete")}
        ensure
          render :json => response
        end
      end

      def upload_params
        params.permit(:object_name, :content_type, :content_size, :uploader, headers: {},  upload: {})
      end

  end
end
