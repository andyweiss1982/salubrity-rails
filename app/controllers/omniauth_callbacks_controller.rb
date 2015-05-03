class OmniauthCallbacksController < Devise::OmniauthCallbacksController
require 'parse-ruby-client'

  def facebook
    @user = User.from_omniauth(request.env["omniauth.auth"])
    @user.find_or_create_in_parse

    sign_in_and_redirect @user
  end

end