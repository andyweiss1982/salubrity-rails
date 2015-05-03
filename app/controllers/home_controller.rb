class HomeController < ApplicationController
  before_action :get_current_parse_user

  def index
  end

  private

  def get_current_parse_user
    @current_parse_user = current_user.parse_record
  end
end
