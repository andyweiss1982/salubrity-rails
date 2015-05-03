class UsersController < ApplicationController

  def edit

  end

  def update
    current_user.update_in_parse(user_params)
    redirect_to :root
  end

  private

  def user_params
    params.require(:user).permit(:hiv, :hpv, :gonorrhea, :herpes, :other)
  end
end
