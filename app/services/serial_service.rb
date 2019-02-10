class SerialService
  def initialize(author:, serial:, params:)
    @author,@serial, @params = author, serial, params
  end

  def  call
    ActiveRecord::Base.transaction do
      create_seasons(@serial)
    end
  end

  def check_seasons
    actual_value = @params[:serial][:seasons_number].to_i
      if @serial.seasons.count > actual_value
        splited = @serial.seasons.drop(actual_value)
        splited.each do |el|
          season = Season.find(el.id)
          season.destroy
        end
      elsif  @serial.seasons.count < actual_value
        number = actual_value - @serial.seasons.count
        number_name = @serial.seasons.count + 1
        number.times do |season|
          Season.create!(admin_serial_id: @serial.id, season_number: number_name )
          number_name += 1
        end
      else
        @message = 'Nothing change.'
      end
  end


  private

  def create_seasons(serial)
    num = 1
    serial.seasons_number.times do |number|
      Season.create!(admin_serial_id: serial.id, season_number: num)
      num += 1
    end
  end
end
