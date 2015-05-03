class ApiController < ApplicationController
  def get_token
    render json: {token: form_authenticity_token}
  end
end