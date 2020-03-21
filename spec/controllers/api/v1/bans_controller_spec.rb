require 'rails_helper'

RSpec.describe 'Bans Controller', type: :request do
  before(:all) do
    Rails.application.load_seed
  end
  describe 'Post /bans' do

    
    # make HTTP get request before each example
    


    it 'Create Ban' do
      post '/api/v1/ban?X_TRAVELNOGO_KEY=' + ENV['X_TRAVELNOGO_KEY'], params: {
        "banner": "AL",
        "bannee": "CN",
        "ban_type": "FULL_BAN",
        "ban_description": "Individuals from China not allowed into the country"
      } 
      ban = JSON.parse(response.body)["ban"]
      expect(ban["ban_type"]).to eq("FULL_BAN")
      expect(ban["ban_description"]).to eq("Individuals from China not allowed into the country")
    end

    it 'Create Ban' do
      post '/api/v1/ban?X_TRAVELNOGO_KEY=' + ENV['X_TRAVELNOGO_KEY'] , params: {
        "banner": "AL",
        "bannee": "CN",
        "ban_type": "FULL_BAN",
        "ban_description": "Individuals from China not allowed into the country"
      } 
      post '/api/v1/ban?X_TRAVELNOGO_KEY=' + ENV['X_TRAVELNOGO_KEY'] , params: {
        "banner": "AL",
        "bannee": "CN",
        "ban_type": "HALF_BAN",
        "ban_description": "Lorem Ipsum"
      } 
      banner = Country.find_by_code("AL")
      bannee = Country.find_by_code("CN")
      ban = Ban.find_by(:banner => banner, :bannee => bannee)
      expect(ban.ban_type).to eq("HALF_BAN")
      expect(ban.ban_description).to eq("Lorem Ipsum")
    end

    it 'Get Country Banner' do
      post '/api/v1/ban?X_TRAVELNOGO_KEY=' + ENV['X_TRAVELNOGO_KEY'], params: {
        "banner": "AL",
        "bannee": "CN",
        "ban_type": "FULL_BAN",
        "ban_description": "Individuals from China not allowed into the country"
      } 
      post '/api/v1/ban?X_TRAVELNOGO_KEY=' + ENV['X_TRAVELNOGO_KEY'], params: {
        "banner": "US",
        "bannee": "CN",
        "ban_type": "HALF_BAN",
        "ban_description": "Lorem Ipsum"
      } 

      post '/api/v1/ban?X_TRAVELNOGO_KEY=' + ENV['X_TRAVELNOGO_KEY'], params: {
        "banner": "SG",
        "bannee": "CN",
        "ban_type": "HALF_BAN",
        "ban_description": "Lorem Ipsum"
      } 
      get '/api/v1/ban/CN'
      bans = JSON.parse(response.body)["bans"]
      byebug
      expect(bans[0]["banner_code"]).to eq("AL")
      expect(bans[1]["banner_code"]).to eq("US")
      expect(bans[2]["banner_code"]).to eq("SG")

    end

    it 'Get Banner' do
      post '/api/v1/ban?X_TRAVELNOGO_KEY=' + ENV['X_TRAVELNOGO_KEY'], params: {
        "banner": "AL",
        "bannee": "CN",
        "ban_type": "FULL_BAN",
        "ban_description": "Individuals from China not allowed into the country"
      } 
      get '/api/v1/ban/CN/AL'
      ban = JSON.parse(response.body)["ban"]
      expect(ban["banner_code"]).to eq("AL")
      expect(ban["bannee_code"]).to eq("CN")
    end

  end

end
