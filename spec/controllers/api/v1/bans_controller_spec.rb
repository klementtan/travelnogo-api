require 'rails_helper'

RSpec.describe 'Bans Controller', type: :request do
  before(:all) {
    Rails.application.load_seed

  }
  before(:each) {
    allow_any_instance_of(Api::V1::BaseController).to receive(:authenticate).and_return(true)
    ScraperRequest.destroy_all

  }
  describe 'Create Ban' do
    it 'Should Create new Ban' do

      post '/api/v1/ban?X_TRAVELNOGO_KEY=' + ENV['X_TRAVELNOGO_KEY'],
           params: {
             "banner": 'AL',
             "bannee": 'CN',
             "ban_type": 'FULL_BAN',
             "ban_description":
               'Individuals from China not allowed into the country'
           }
      ban = JSON.parse(response.body)['ban']
      expect(ban['ban_type']).to eq('FULL_BAN')
      expect(ban['ban_description']).to eq(
        'Individuals from China not allowed into the country'
      )
    end

    it 'Should Create many new Ban' do
      post '/api/v1/many_ban?X_TRAVELNOGO_KEY=' + ENV['X_TRAVELNOGO_KEY'],
           params: {
             "banner": 'AL',
             "bannee": %w[CN US SG],
             "ban_type": 'FULL_BAN',
             "ban_description":
               'Individuals from CN US and SG not allowed into the country'
           }
      bans = JSON.parse(response.body)['bans']
      expect(bans.length).to eq(3)
      bans.each { |ban| expect(Ban.find(ban['id'])).not_to be_nil }
    end

    it 'It should replace old Ban' do
      post '/api/v1/ban?X_TRAVELNOGO_KEY=' + ENV['X_TRAVELNOGO_KEY'],
           params: {
             "banner": 'AL',
             "bannee": 'CN',
             "ban_type": 'FULL_BAN',
             "ban_description":
               'Individuals from China not allowed into the country'
           }
      post '/api/v1/ban?X_TRAVELNOGO_KEY=' + ENV['X_TRAVELNOGO_KEY'],
           params: {
             "banner": 'AL',
             "bannee": 'CN',
             "ban_type": 'HALF_BAN',
             "ban_description": 'Lorem Ipsum'
           }
      banner = Country.find_by_code('AL')
      bannee = Country.find_by_code('CN')
      ban = Ban.find_by(banner: banner, bannee: bannee)
      expect(ban.ban_type).to eq('HALF_BAN')
      expect(ban.ban_description).to eq('Lorem Ipsum')
    end
  end

  describe 'Get ban details' do
    it 'Get Country Banner' do
      post '/api/v1/ban?X_TRAVELNOGO_KEY=' + ENV['X_TRAVELNOGO_KEY'],
           params: {
             "banner": 'AL',
             "bannee": 'CN',
             "ban_type": 'FULL_BAN',
             "ban_description":
               'Individuals from China not allowed into the country'
           }
      post '/api/v1/ban?X_TRAVELNOGO_KEY=' + ENV['X_TRAVELNOGO_KEY'],
           params: {
             "banner": 'US',
             "bannee": 'CN',
             "ban_type": 'HALF_BAN',
             "ban_description": 'Lorem Ipsum'
           }

      post '/api/v1/ban?X_TRAVELNOGO_KEY=' + ENV['X_TRAVELNOGO_KEY'],
           params: {
             "banner": 'SG',
             "bannee": 'CN',
             "ban_type": 'HALF_BAN',
             "ban_description": 'Lorem Ipsum'
           }
      get '/api/v1/ban/CN'
      bans = JSON.parse(response.body)['bans']
      expect(bans[0]['banner_code']).to eq('AL')
      expect(bans[1]['banner_code']).to eq('SG')
      expect(bans[2]['banner_code']).to eq('US')
    end

    it 'Get all country that has travel restriction from country ___' do
      post '/api/v1/ban?X_TRAVELNOGO_KEY=' + ENV['X_TRAVELNOGO_KEY'],
           params: {
             "banner": 'AL',
             "bannee": 'CN',
             "ban_type": 'FULL_BAN',
             "ban_description":
               'Individuals from China not allowed into the country'
           }
      post '/api/v1/ban?X_TRAVELNOGO_KEY=' + ENV['X_TRAVELNOGO_KEY'],
           params: {
             "banner": 'AL',
             "bannee": 'SG',
             "ban_type": 'FULL_BAN',
             "ban_description":
               'Individuals from China not allowed into the country'
           }
      post '/api/v1/ban?X_TRAVELNOGO_KEY=' + ENV['X_TRAVELNOGO_KEY'],
           params: {
             "banner": 'AL',
             "bannee": 'US',
             "ban_type": 'FULL_BAN',
             "ban_description":
               'Individuals from China not allowed into the country'
           }
      get '/api/v1/bannee/AL'
      bans = JSON.parse(response.body)['bans']
      expect(bans[0]['bannee_code']).to eq('CN')
      expect(bans[1]['bannee_code']).to eq('SG')
      expect(bans[2]['bannee_code']).to eq('US')
    end

    it 'Get many specific ban  ' do
      post '/api/v1/ban?X_TRAVELNOGO_KEY=' + ENV['X_TRAVELNOGO_KEY'],
           params: {
             "banner": 'AL',
             "bannee": 'CN',
             "ban_type": 'FULL_BAN',
             "ban_description":
               'Individuals from China not allowed into the country'
           }
      post '/api/v1/ban?X_TRAVELNOGO_KEY=' + ENV['X_TRAVELNOGO_KEY'],
           params: {
             "banner": 'AL',
             "bannee": 'SG',
             "ban_type": 'FULL_BAN',
             "ban_description":
               'Individuals from China not allowed into the country'
           }
      post '/api/v1/ban?X_TRAVELNOGO_KEY=' + ENV['X_TRAVELNOGO_KEY'],
           params: {
             "banner": 'AL',
             "bannee": 'US',
             "ban_type": 'FULL_BAN',
             "ban_description":
               'Individuals from China not allowed into the country'
           }
      post '/api/v1/ban?X_TRAVELNOGO_KEY=' + ENV['X_TRAVELNOGO_KEY'],
           params: {
             "banner": 'AL',
             "bannee": 'VN',
             "ban_type": 'FULL_BAN',
             "ban_description":
               'Individuals from China not allowed into the country'
           }
      get '/api/v1/many_ban/AL?bannees=CN,SG,US,'
      bans = JSON.parse(response.body)['bans']
      expect(bans.length).to eq(3)
      expect(bans[0]['bannee_code']).to eq('CN')
      expect(bans[1]['bannee_code']).to eq('SG')
      expect(bans[2]['bannee_code']).to eq('US')
    end
  end

  describe 'Integration test with scraper request' do
    it 'Should Create new Ban' do
      post '/api/v1/scraper/iata',
        params: {
          "date": '12.05.2020',
          "scrape_data": {
            "AFGHANISTAN": {
              "ISO2": 'AF',
              "published_date": '24.04.2020',
              "possible_bannees": ['CN'],
              "info":
                "Flights to Afghanistan are suspended.\n- This does not apply to repatriation flights that bring back nationals of Afghanistan.\n"
            }
          }
        }
      post '/api/v1/many_ban?X_TRAVELNOGO_KEY=' + ENV['X_TRAVELNOGO_KEY'],
        params: {
          "banner": 'AF',
          "bannee": %w[CN],
          "ban_type": 'FULL_BAN',
          "ban_description":
            'Individuals from CN US and SG not allowed into the country'
        }
      expect(ScraperBanRequest.find_by(banner: Country.find_by_code('AF'), bannee: Country.find_by_code('CN')).status).to eq(ScraperRequestStatus::DONE)
    end
  end
end
