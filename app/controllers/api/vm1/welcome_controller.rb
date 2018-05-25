class Api::Vm1::WelcomeController < Api::Vm1::ApplicationController

  def app_latest_version
    response = { code: '0',
                 status: 'Success',
                 latestVersion: 2.1 }

    render json: response
  end
end
