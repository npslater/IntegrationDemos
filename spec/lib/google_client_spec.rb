require 'spec_helper'

describe GoogleClient do

  let(:client) { GoogleClient.new() }
  let(:email) { "nateslate@gmail.com" }
  let(:state) { "authorizationCode"}

  it 'should have a constructor that returns an instance of Googleclient' do
    client = GoogleClient.new();
    client.should be_an_instance_of(GoogleClient)
  end

  it 'should return a URL when get_authorization_uri is called' do
    url = client.get_authorization_uri(email, state)
    url.should be_an_instance_of(String)
  end
end