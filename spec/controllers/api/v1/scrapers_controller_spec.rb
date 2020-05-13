require 'rails_helper'

RSpec.describe 'Scraper Controller', type: :request do
  before(:all) { Rails.application.load_seed }
  before(:each) { ScraperRequest.destroy_all }
  describe 'Create IATA Scrapper Ban Request' do
    it 'Should Create new scraper ban request for country all' do
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
      expect(scraper_ban_request['ban_description']).to eq(
        "Flights to Afghanistan are suspended.\n- This does not apply to repatriation flights that bring back nationals of Afghanistan.\n"
      )
      expect(scraper_ban_request['status']).to eq(ScraperRequestStatus::PENDING_REVIEW)

      banner = scraper_ban_request['banner']
      expect(banner['code']).to eq('AF')

      bannee = scraper_ban_request['bannee']
      expect(bannee['code']).to eq('ALL')
      expect(bannee['all_countries']).to eq(true)

    end

    it 'Should Create new scraper ban request for multiple country' do
      post '/api/v1/scraper/iata',
           params: {
             "date": '12.05.2020',
             "scrape_data": {
               "AFGHANISTAN": {
                 "ISO2": 'AF',
                 "published_date": '24.04.2020',
                 "possible_bannees": ["SG", "US", "CN"],
                 "info":
                   "Flights to Afghanistan are suspended.\n- This does not apply to repatriation flights that bring back nationals of Afghanistan.\n"
               }
             }
           }
      
      response_json = JSON.parse(response.body)
      expect(response_json['date']).to eq('12.05.2020')
      expect(response_json['source']).to eq('IATA')

      scraper_ban_requests = response_json['scraper_ban_requests']

      expect(scraper_ban_requests.length).to eq(3)

      #Bannee is SG
      scraper_ban_request0 = scraper_ban_requests[0]
      expect(scraper_ban_request0['status']).to eq(ScraperRequestStatus::PENDING_REVIEW)
      expect(scraper_ban_request0['ban_description']).to eq(
        "Flights to Afghanistan are suspended.\n- This does not apply to repatriation flights that bring back nationals of Afghanistan.\n"
      )

      banner0 = scraper_ban_request0['banner']
      expect(banner0['code']).to eq('AF')

      bannee0 = scraper_ban_request0['bannee']
      expect(bannee0['code']).to eq('SG')

      #Bannee is US
      scraper_ban_request1 = scraper_ban_requests[1]
      expect(scraper_ban_request1['status']).to eq(ScraperRequestStatus::PENDING_REVIEW)
      expect(scraper_ban_request1['ban_description']).to eq(
        "Flights to Afghanistan are suspended.\n- This does not apply to repatriation flights that bring back nationals of Afghanistan.\n"
      )

      banner1 = scraper_ban_request1['banner']
      expect(banner1['code']).to eq('AF')

      bannee1 = scraper_ban_request1['bannee']
      expect(bannee1['code']).to eq('US')

      #Bannee is CN
      scraper_ban_request2 = scraper_ban_requests[2]
      expect(scraper_ban_request2['status']).to eq(ScraperRequestStatus::PENDING_REVIEW)
      expect(scraper_ban_request2['ban_description']).to eq(
        "Flights to Afghanistan are suspended.\n- This does not apply to repatriation flights that bring back nationals of Afghanistan.\n"
      )

      banner2 = scraper_ban_request2['banner']
      expect(banner2['code']).to eq('AF')

      bannee2 = scraper_ban_request2['bannee']
      expect(bannee2['code']).to eq('CN')
    end
    
    it 'Creating duplicate request will replace the old scraper ban request' do
      n = 10
      while n > 0 do
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
        n -= 1
        end
      expect(ScraperBanRequest.where(status: ScraperRequestStatus::OUTDATED).length).to eq(9)
      expect(ScraperBanRequest.where(status: ScraperRequestStatus::PENDING_REVIEW).length).to eq(1)
    end

    it 'If the latest request is done and the new request is exactly the same, the new request will have done status ' do
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
      scraper_ban_requests = response_json['scraper_ban_requests']
      scraper_ban_request = scraper_ban_requests[0]
      scraper_ban_request_id = scraper_ban_request['id']
      scraper_ban_request = ScraperBanRequest.find(scraper_ban_request_id)
      scraper_ban_request.status = ScraperRequestStatus::DONE
      scraper_ban_request.save

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

      expect(ScraperBanRequest.where(status: ScraperRequestStatus::DONE).length).to eq(2)
    end

    it 'If the latest request is done and the new request is exactly the same, the new request will have done status ' do
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
      scraper_ban_requests = response_json['scraper_ban_requests']
      scraper_ban_request = scraper_ban_requests[0]
      scraper_ban_request_id = scraper_ban_request['id']
      scraper_ban_request = ScraperBanRequest.find(scraper_ban_request_id)
      scraper_ban_request.status = ScraperRequestStatus::DONE
      scraper_ban_request.save

      post '/api/v1/scraper/iata',
        params: {
          "date": '12.05.2020',
          "scrape_data": {
            "AFGHANISTAN": {
              "ISO2": 'AF',
              "published_date": '24.04.2020',
              "possible_bannees": [],
              "info":
                "Lorem Ipsum"
            }
          }
        }
      expect(ScraperBanRequest.where(status: ScraperRequestStatus::DONE).length).to eq(1)
      expect(ScraperBanRequest.where(status: ScraperRequestStatus::PENDING_REVIEW).length).to eq(1)
    end

    describe 'Get Pending Reviews' do
      it 'Should return all the pending reviews' do
        post '/api/v1/scraper/iata',
          params: {
            "date": '12.05.2020',
            "scrape_data": {
              "AFGHANISTAN": {
                "ISO2": 'AF',
                "published_date": '24.04.2020',
                "possible_bannees": ["SG", "US", "CN"],
                "info":
                  "Flights to Afghanistan are suspended.\n- This does not apply to repatriation flights that bring back nationals of Afghanistan.\n"
              }
            }
          }
        get '/api/v1/scraper'
        pending_review_arr = JSON.parse(response.body)
        expect(pending_review_arr.length).to be(3)
        
        pending_review_sg = pending_review_arr[0]
        expect(pending_review_sg["bannee"]["code"]).to eq("SG")
        expect(pending_review_sg["status"]).to eq(ScraperRequestStatus::PENDING_REVIEW)

        pending_review_us = pending_review_arr[1]
        expect(pending_review_us["bannee"]["code"]).to eq("US")
        expect(pending_review_us["status"]).to eq(ScraperRequestStatus::PENDING_REVIEW)

        pending_review_cn = pending_review_arr[2]
        expect(pending_review_cn["bannee"]["code"]).to eq("CN")
        expect(pending_review_cn["status"]).to eq(ScraperRequestStatus::PENDING_REVIEW)
      end

      it 'Should return all the pending reviews and filter out the other statuses' do
        post '/api/v1/scraper/iata',
          params: {
            "date": '12.05.2020',
            "scrape_data": {
              "AFGHANISTAN": {
                "ISO2": 'AF',
                "published_date": '24.04.2020',
                "possible_bannees": ["SG", "US", "CN"],
                "info":
                  "Flights to Afghanistan are suspended.\n- This does not apply to repatriation flights that bring back nationals of Afghanistan.\n"
              }
            }
          }
          ScraperBanRequest.find_by(banner: Country.find_by_code("AF"), bannee: Country.find_by_code("SG")).status = ScraperRequestStatus::DONE
          post '/api/v1/scraper/iata',
          params: {
            "date": '12.05.2020',
            "scrape_data": {
              "AFGHANISTAN": {
                "ISO2": 'AF',
                "published_date": '24.04.2020',
                "possible_bannees": ["SG", "US", "CN"],
                "info":
                  "Lorem Ipsum"
              }
            }
          }
        get '/api/v1/scraper'
        pending_review_arr = JSON.parse(response.body)
        expect(pending_review_arr.length).to be(3)
        expect(ScraperBanRequest.all.length).to be(6)
        
        pending_review_sg = pending_review_arr[0]
        expect(pending_review_sg["bannee"]["code"]).to eq("SG")
        expect(pending_review_sg["status"]).to eq(ScraperRequestStatus::PENDING_REVIEW)

        pending_review_us = pending_review_arr[1]
        expect(pending_review_us["bannee"]["code"]).to eq("US")
        expect(pending_review_us["status"]).to eq(ScraperRequestStatus::PENDING_REVIEW)

        pending_review_cn = pending_review_arr[2]
        expect(pending_review_cn["bannee"]["code"]).to eq("CN")
        expect(pending_review_cn["status"]).to eq(ScraperRequestStatus::PENDING_REVIEW)
      end
    end
  end
end
