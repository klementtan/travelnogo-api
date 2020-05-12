require 'rails_helper'

RSpec.describe 'Scraper Controller', type: :request do
  before(:all) { Rails.application.load_seed }
  describe 'Create IATA Scrapper Ban Request' do
    it 'Should Create new scraper ban request' do
      post '/api/v1/scraper/iata',
           params: {
             "date": '12.05.2020',
             "scrape_data": {
               "AFGHANISTAN": {
                 "ISO2": 'AF',
                 "published_date": '24.04.2020',
                 "possible_bannees": [],
                 "info":
                   "Flights to Afghanistan are suspended.\n- This does not apply to repatriation flights that bring back nationals of Afghanistan.\n"
               }
             }
           }
      
      response_json = JSON.parse(response.body)
      expect(response_json['date']).to eq('12.05.2020')
      expect(response_json['source']).to eq('IATA')

      scraper_ban_requests = response_json['scraper_ban_requests']

      expect(scraper_ban_requests.length).to eq(1)

      scraper_ban_request = scraper_ban_requests[0]
      @id1 = scraper_ban_request["id"]
      expect(scraper_ban_request['ban_description']).to eq(
        "Flights to Afghanistan are suspended.\n- This does not apply to repatriation flights that bring back nationals of Afghanistan.\n"
      )

      banner = scraper_ban_request['banner']
      expect(banner['code']).to eq('AF')

      bannee = scraper_ban_request['bannee']
      expect(bannee['code']).to eq('ALL')
      expect(bannee['all_countries']).to eq(true)

    end
    it 'Creating duplicate request will replace the old scraper ban request' do

      post '/api/v1/scraper/iata',
        params: {
          "date": '12.05.2020',
          "scrape_data": {
            "AFGHANISTAN": {
              "ISO2": 'AF',
              "published_date": '24.04.2020',
              "possible_bannees": [],
              "info":
                "Flights to Afghanistan are suspended.\n- This does not apply to repatriation flights that bring back nationals of Afghanistan.\n"
            }
          }
        }

      firs_id = JSON.parse(response.body)['scraper_ban_requests'][0]['id']

      post '/api/v1/scraper/iata',
        params: {
          "date": '12.05.2020',
          "scrape_data": {
            "AFGHANISTAN": {
              "ISO2": 'AF',
              "published_date": '24.04.2020',
              "possible_bannees": [],
              "info":
                "Flights to Afghanistan are suspended.\n- This does not apply to repatriation flights that bring back nationals of Afghanistan.\n"
            }
          }
        }
      expect(ScraperBanRequest.find(firs_id).status).to eq(ScraperRequestStatus::OUTDATED)
      expect(JSON.parse(response.body)['scraper_ban_requests'][0]['status']).to eq(ScraperRequestStatus::PENDING_REVIEW)
    end
  end
end
