require "sinatra"
require "json"
require "faraday"
require 'alexa_rubykit'

before do
  content_type('application/json')
end

post "/" do
  alexa = AlexaRubykit.build_request(JSON.parse(request.body.read.to_s))
  alexa_response = AlexaRubykit::Response.new

  provider = alexa.slots['Provider']['value']

  create_connection

  providers = []
  response = @conn.get "/api/vms?expand=resources&attributes=#{provider}"
  JSON.parse(response.body).to_h['resources'].each do |result|
    providers << result['vendor']
  end

  counts = {}
  providers.group_by(&:itself).each { |k,v| counts[k] = v.length }
  speach_string = "#{provider} has #{counts[provider.downcase]} VMs running"

  if (alexa.type == 'INTENT_REQUEST')
    alexa_response.add_speech(speach_string)
    alexa_response.add_hash_card( { :title => 'MangeIQ', :subtitle => "Intent #{alexa.name}" } )
  end

  if (alexa.type =='SESSION_ENDED_REQUEST')
    halt 200
  end

  alexa_response.build_response
end

def create_connection
  @conn ||= Faraday.new(:url => 'http://localhost:3000') do |c|
    c.basic_auth(ENV['manageiq_username'], ENV['manageiq_password'])
    c.headers['Content-Type'] = 'application/json'
    c.use Faraday::Adapter::NetHttp
  end
end
