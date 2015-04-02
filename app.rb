require 'sinatra'
require 'sinatra/json'
require 'sinatra/reloader' if development?
require 'slim'
require 'coffee_script'
require 'uri'
require 'digest/sha1'
require 'logger'

class App < Sinatra::Base
  log = Logger.new(STDOUT)

  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    slim :index
  end

  get '/cred' do
    # cloudinary://api_key:api_secret@cloud_name
    api_key, api_secret, cloud_name = URI(ENV['CLOUDINARY_URL']).instance_eval{[user, password, host]}
    timestamp = Time.now.to_i
    signature = Digest::SHA1.hexdigest "timestamp=#{timestamp}#{api_secret}"
    endpoint = "https://api.cloudinary.com/v1_1/#{cloud_name}/raw/upload"
    json params: {api_key: api_key, timestamp: timestamp, signature: signature}, endpoint: endpoint
  end
end
