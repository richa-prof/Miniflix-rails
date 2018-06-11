class MovieTrailerUploader < ApplicationController
  extend S3Multipart::Uploader::Core

  # Attaches the specified model to the uploader, creating a "has_one" 
  # relationship between the internal upload model and the given model.
  attach :movie_trailer

  # Only accept certain file types. Expects an array of valid extensions.
  accept %w(webm wmv avi mp4 mkv mov mpeg)

  # Define the minimum and maximum allowed file sizes (in bytes)
  limit min: 5*1000*1000, max: 2*1000*1000*1000

  # Takes in a block that will be evaluated when the upload has been 
  # successfully initiated. The block will be passed an instance of 
  # the upload object as well as the session hashwhen the callback is made. 
  # 
  # The following attributes are available on the upload object:
  # - key:       A randomly generated unique key to replace the file
  #              name provided by the client
  # - upload_id: A hash generated by Amazon to identify the multipart upload
  # - name:      The name of the file (including extensions)
  # - location:  The location of the file on S3. Available only to the
  #              upload object passed into the on_complete callback
  #
  on_begin do |upload, session|
    # Code to be evaluated when upload begins.

    puts "<<<<< MovieTrailerUploader::on_begin upload ---> #{upload.to_json} <<<<<"
    Rails.logger.debug "<<<<< MovieTrailerUploader::on_begin upload ---> #{upload.to_json} <<<<<"
  end

  # See above comment. Called when the upload has successfully completed
  on_complete do |upload, session|
    # Code to be evaluated when upload completes
    puts "<<<<< MovieTrailerUploader::on_complete upload ---> #{upload.to_json} <<<<<"
    Rails.logger.debug "<<<<< MovieTrailerUploader::on_complete upload ---> #{upload.to_json} <<<<<"
  end

end
