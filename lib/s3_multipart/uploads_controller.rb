module S3Multipart
  class UploadsController

    def create
      begin
        upload = Upload.create(upload_params)
        upload.execute_callback(:begin, session)
        response = upload.to_json
      rescue FileTypeError, FileSizeError => e
        response = {error: e.message}
      rescue => e
        logger.error "EXC: #{e.message}"
        response = { error: t("s3_multipart.errors.create") }
      ensure
        render :json => response
      end
    end

    private

      def upload_params
        params.permit(:object_name, :content_type, :content_size, :uploader, headers: {},  upload: {})
      end
  end
end
