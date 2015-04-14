require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'
require 'pry'

require './saml_eater_one_login'

post '/saml/onelogin/consume' do
  saml_eater = SamlEaterOneLogin.new(app_id: 441811)
  valid_login = saml_eater.eat_response(request.POST['SAMLResponse'])
  content_type :json

  if valid_login
    JSON.pretty_generate valid_login
  else
    JSON.pretty_generate({ status: 'failed' })
  end
end
