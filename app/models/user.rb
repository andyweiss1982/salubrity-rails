class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  require "httparty"

  PARSE_APPLICATION_ID = "ye9rhnCo5jyvk86O7iCYHOGTaNbSvfyMpzMSSuTK"
  PARSE_API_KEY = "3CAMBv8GOSo6kIS5Od1110JqdxYk3WvfYlxWS72n"

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  def self.from_omniauth(auth)
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.email = auth.info.email
        user.name = auth.info.first_name
        user.password = Devise.friendly_token[0,20]
        user.token = auth.credentials.token
      end
  end

  def parse_results
    Parse.init(
      application_id: PARSE_APPLICATION_ID,
      api_key: PARSE_API_KEY 
    )

    query = Parse::Query.new("User")
    query.eq("facebook_id", uid)
    query.get
  end

  def parse_record
    parse_results.first
  end

  def create_in_parse
    new_user = Parse::Object.new("User")
    new_user['facebook_id'] = uid
    new_user['first_name'] = name
    new_user['hiv'] = "false"
    new_user['hpv'] = "false"
    new_user['herpes'] = "false"
    new_user['gonorrhea'] = "false"
    new_user['other'] = "false"
    new_user.save
  end

  def find_or_create_in_parse
    create_in_parse if parse_results.empty?
  end

  def update_in_parse(params)
    HTTParty.put(
      "https://api.parse.com/1/classes/User/#{parse_record['objectId']}",
      headers: {
        'Content-Type' => 'application/json',
        'X-Parse-Application-Id' => PARSE_APPLICATION_ID,
        'X-Parse-REST-API-Key' => PARSE_API_KEY
      },
      body: params.to_json
    )
  end

  def ping_facebook
    response = HTTParty.get("https://graph.facebook.com/v2.3/#{self.uid}/friends?access_token=#{self.token}")
    puts response.body
  end
end