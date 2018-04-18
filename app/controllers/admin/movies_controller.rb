require 'aws-sdk'
class Admin::MoviesController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :set_admin_movie, only: [:show, :edit, :update, :destroy]

  layout 'admin'

  # GET /admin/movies
  # GET /admin/movies.json
  def index
    @admin_movies = Movie.all
  end

  def download
    # TODO: Need to remove this.
    @admin_movie = Admin::Movie.find(params[:id])
    original_filename = @admin_movie.film_video.file.filename
    bucketName = "miniflix-film"
    key = @admin_movie.film_video.path
    s3 = AWS::S3.new( access_key_id: ENV['S3_KEY'],
                      secret_access_key: ENV['S3_SECRET'] )

    obj = s3.buckets[bucketName].objects[key]
    response.headers["Content-Type"] = obj.content_type
    send_data obj.read,filename: original_filename, type: obj.content_type
  end

  # GET /admin/movies/1
  # GET /admin/movies/1.json
  def show
    @movie_film_url = @admin_movie.film_video
  end

  # GET /admin/movies/new
  def new
    @admin_movie = Movie.new
    @admin_movie.build_movie_thumbnail
  end

  def add_movie_details
    @admin_movie = Movie.find_by_s3_multipart_upload_id(params[:id])
    @s3_multipart = S3Multipart::Upload.find(params[:id])
  end

  # GET /admin/movies/1/edit
  def edit
    @s3_multipart = S3Multipart::Upload.find(@admin_movie.s3_multipart_upload_id)
  end

  # POST /admin/movies
  # POST /admin/movies.json
  def create
    @released_date = Date.strptime(params[:admin_movie][:released_date], '%m/%d/%Y').to_date
    @posted_date = Date.strptime(params[:admin_movie][:posted_date], '%m/%d/%Y').to_date

    @admin_movie = Admin::Movie.find_by_s3_multipart_upload_id(params[:id])
    respond_to do |format|
      # if @admin_movie.save
      if @admin_movie.update(admin_movie_params.merge(released_date: @released_date,posted_date: @posted_date,is_featured_film: params[:admin_movie][:is_featured_film]))
        @admin_movie.build_admin_movie_thumbnail(movie_screenshot_1: params[:movie_screenshot_1],movie_screenshot_2: params[:movie_screenshot_2],movie_screenshot_3: params[:movie_screenshot_3],thumbnail_screenshot: params[:thumbnail_screenshot],thumbnail_640_screenshot: params[:thumbnail_640_screenshot])
        @admin_movie.save

        format.html { redirect_to @admin_movie,
                      notice: I18n.t('flash.movie.successfully_created') }
        format.json { render :show, status: :created, location: @admin_movie }
      else
        format.html { render :new }
        format.json { render json: @admin_movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/movies/1
  # PATCH/PUT /admin/movies/1.json
  def update
    respond_to do |format|
      @released_date = Date.strptime(params[:admin_movie][:released_date], '%m/%d/%Y').to_date
      @posted_date = Date.strptime(params[:admin_movie][:posted_date], '%m/%d/%Y').to_date
      if params[:admin_movie][:is_featured_film]
        puts "is_featured_film -->  #{params[:admin_movie][:is_featured_film]} "
        @get_featured_film = Admin::Movie.find_by_is_featured_film(true)
      end
      if @admin_movie.update(admin_movie_params.merge(released_date: @released_date,posted_date: @posted_date,is_featured_film: params[:admin_movie][:is_featured_film]))
        if params[:admin_movie][:is_featured_film]
          puts "is_featured_film --> update "
          if @get_featured_film.present?
            @get_featured_film.update(is_featured_film: false)
          end
        end
        if @admin_movie.admin_movie_thumbnail.present?
          @admin_movie.admin_movie_thumbnail.update(movie_screenshot_1: params[:movie_screenshot_1],movie_screenshot_2: params[:movie_screenshot_2],movie_screenshot_3: params[:movie_screenshot_3],thumbnail_screenshot: params[:thumbnail_screenshot],thumbnail_640_screenshot: params[:thumbnail_640_screenshot])
        else
          @admin_movie.build_admin_movie_thumbnail(movie_screenshot_1: params[:movie_screenshot_1],movie_screenshot_2: params[:movie_screenshot_2],movie_screenshot_3: params[:movie_screenshot_3],thumbnail_screenshot: params[:thumbnail_screenshot],thumbnail_640_screenshot: params[:thumbnail_640_screenshot])
          @admin_movie.save
        end
        format.html { redirect_to @admin_movie,
                      notice: I18n.t('flash.movie.successfully_updated') }
        format.json { render :show, status: :ok, location: @admin_movie }
      else
        format.html { render :edit }
        format.json { render json: @admin_movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/movies/1
  # DELETE /admin/movies/1.json
  def destroy
    s3_multipart = S3Multipart::Upload.find(@admin_movie.s3_multipart_upload_id)
    version_file = @admin_movie.version_file
    @admin_movie.destroy
    Movie.delete_movie_from_s3(s3_multipart, version_file)
    respond_to do |format|
      format.html { redirect_to admin_movies_url,
                    notice: I18n.t('flash.movie.successfully_deleted') }
      format.json { head :no_content }
    end
  end

  def write_file
    puts"===movie======#{@admin_movie.inspect}========"
    @admin_movie = Admin::Movie.find(@admin_movie.id)
    @admin_movie.movie_versions.present? ? '' : trancode_videos
    directory = "tmp"
    file_name = @admin_movie.name.to_s + ".smil"
    video_tag= ""
    @adminmovie_versions=@admin_movie.movie_versions.order(:resolution)
    video_tag += "\n<video src='#{@adminmovie_versions.first.film_video}' height='320' system-bitrate='400000' width='240' />\n"
    @adminmovie_versions.second.present? ? video_tag += "<video src='#{@adminmovie_versions.second.film_video}' height='480' system-bitrate='800000' width='640' />\n" : ''
    @adminmovie_versions.third.present? ? video_tag += "<video src='#{@adminmovie_versions.third.film_video}' height='720' system-bitrate='2000000' width='1080' />\n" : ''
    content = '<smil>
              <head>
                <meta base="rtmp://sz3va72fqkcyf.cloudfront.net/cfx/st" />
              </head>
              <body>
                <switch>'+video_tag+'</switch>
              </body>
            </smil>'
    File.open(File.join(directory, file_name), 'w') do |f|
      puts "file onject====open===#{f.inspect}===="
      f.write(content)
    end
    File.open(File.join(directory, file_name)) do |f|
      puts "file onject=======#{f.inspect}===="
      @admin_movie.version_file = f
      @admin_movie.save!
    end
    puts "created"
    File.delete(File.join(directory, file_name))
    puts "deleted"
  end

   def trancode_videos
    # This is the ID of the Elastic Transcoder pipeline that was created when
    # setting up your AWS environment:
    # http://docs.aws.amazon.com/elastictranscoder/latest/developerguide/sample-code.html#ruby-pipeline
    pipeline_id = '1479894850873-a7j2af'

    # This is the name of the input key that you would like to transcode.
    @s3_upload = S3Multipart::Upload.find(@admin_movie.s3_multipart_upload_id)
    input_key = @s3_upload.key

    # Region where the sample will be run
    region = 'us-west-1'

    # Generic Presets that will be used to create an adaptive bitrate playlist.
    generic_1080p_preset_id = '1351620000001-000001'
    generic_720p_preset_id = '1351620000001-000010'
    generic_480p_preset_id = '1351620000001-000020'
    generic_360p_preset_id = '1351620000001-000040'
    generic_320p_preset_id = '1351620000001-000061'

    #All outputs will have this prefix prepended to their output key.
    output_key_prefix = @admin_movie.id.to_s

    # Create the client for Elastic Transcoder.
    transcoder_client = AWS::ElasticTranscoder::Client.new(region: region)

    # Setup the job input using the provided input key.
    input = { key: input_key }

    generic_1080p = {
      key: 'generic_1080p/' + @s3_upload.name,
      preset_id: generic_1080p_preset_id
    }

    generic_720p = {
      key: 'generic_720p/' + @s3_upload.name,
      preset_id: generic_720p_preset_id
    }

    generic_480p = {
      key: 'generic_480p/'+@s3_upload.name,
      preset_id: generic_480p_preset_id
    }

    generic_360p = {
      key: 'generic_360p/'+@s3_upload.name,
      preset_id: generic_360p_preset_id
    }

    generic_320p = {
      key: 'generic_320p/'+@s3_upload.name,
      preset_id: generic_360p_preset_id
    }

    outputs = [ generic_720p, generic_480p, generic_320p ] # list of in which quality you want transcode
    # playlist = {
    #   name: 'hls_' + output_key,
    #   format: 'HLSv3',
    #   output_keys: outputs.map { |output| output[:key] }
    # }

    job = transcoder_client.create_job(
      pipeline_id: pipeline_id,
      input: input,
      output_key_prefix: output_key_prefix+'/',
      outputs: outputs)
      # playlists: [ playlist ])[:job]
      puts "job created"
    film_video_720 = "#{@admin_movie.id}/generic_720p/#{@s3_upload.name}"
    film_video_480 = "#{@admin_movie.id}/generic_480p/#{@s3_upload.name}"
    film_video_320 = "#{@admin_movie.id}/generic_320p/#{@s3_upload.name}"
    @admin_movie.movie_versions.create(film_video: film_video_320,resolution: '320')
    @admin_movie.movie_versions.create(film_video: film_video_480,resolution: '480')
    @admin_movie.movie_versions.create(film_video: film_video_720,resolution: '720')
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_movie
      @admin_movie = Movie.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_movie_params
      params.require(:admin_movie).permit(:name, :title, :description, :admin_genre_id, :film_video, :video_type, :video_size, :video_duration, :video_format, :directed_by, :language, :star_cast, :actors, :downloadable,:festival_laureates)
    end
end
