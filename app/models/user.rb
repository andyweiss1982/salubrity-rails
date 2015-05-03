class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # require "httparty"

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

  def friend_ids
    require 'httparty'
    response = HTTParty.get("https://graph.facebook.com/v2.3/#{self.uid}/friends?access_token=#{self.token}")

    hash = JSON.parse(response.body)
    hash['data'].map{ |x| x['id'] }
  end

  def friends_on_parse
    my_friends_on_parse = []
    
    friend_ids.each do |id|
      query = Parse::Query.new("User")
      query.eq('facebook_id', id)
      response = query.get 
      unless response.empty?
        my_friends_on_parse<<response.first
      end
    end  
    
    my_friends_on_parse
  end

  def counter_values 
    hiv = 0
    herpes = 0
    chlamydia = 0
    gonorrhea = 0
    hpv = 0
    other = 0

    friends_on_parse.each do |friend|
      hiv +=1 if friend['hiv'] == 'true'
      herpes +=1 if friend['herpes'] == 'true'
      chlamydia +=1 if friend['chlamydia'] == 'true'
      gonorrhea +=1 if friend['gonorrhea'] == 'true'
      hpv +=1 if friend['hpv'] == 'true'
      other +=1 if friend['other'] == 'true'
    end

    {hiv: hiv, herpes: herpes, chlamydia: chlamydia, gonorrhea: gonorrhea, hpv: hpv, other: other}
  end

end









