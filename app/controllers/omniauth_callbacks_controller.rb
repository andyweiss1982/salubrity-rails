class OmniauthCallbacksController < Devise::OmniauthCallbacksController
require 'parse-ruby-client'

  def facebook
      @user = User.from_omniauth(request.env["omniauth.auth"])
      
      Parse.init :application_id => "ye9rhnCo5jyvk86O7iCYHOGTaNbSvfyMpzMSSuTK",
                 :api_key        => "3CAMBv8GOSo6kIS5Od1110JqdxYk3WvfYlxWS72n" 

      query = Parse::Query.new("User")
      query.eq("facebook_id", "#{@user.uid}")
      result = query.get

      if result.empty?
        new_user = Parse::Object.new("User")
        new_user['facebook_id'] = "#{@user.uid}"
        new_user['first_name'] = "#{@user.name}"
        new_user.save
      end

      sign_in_and_redirect @user
  end

end