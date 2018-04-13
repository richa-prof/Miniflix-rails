class UsersController < ApplicationController

  def destroy
    User.find(params[:id]).destroy
    respond_to do |format|
      format.html { redirect_to admin_users_path, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
end
