class Api::Vm1::SerialsController < Api::Vm1::ApplicationController
  before_action :authenticate_api, only: []
  before_action :authenticate_according_to_devise, only: []


  def get_serial_detail
    begin
      serial = Serial.find(params[:id]) 
      serial_hash = serial.formatted_response('short_serial_model')
      api_response =  {:code => "0", :status => "Success", data: serial_hash }
    rescue Exception => e
      api_response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render json: api_response
  end
end
