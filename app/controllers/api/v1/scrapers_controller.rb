class Api::V1::ScrapersController < Api::V1::BaseController
  def create_iata_request
    date = Date.parse(params['date'])
    scrape_data = params['scrape_data']
    scrape_request =
      ScraperRequest.create(source: ScraperSources::IATA, date: date)
    scrape_data.each do |country_name, country_info|
      begin 
        banner = Country.find_by_code(country_info['ISO2'])
        ban_description = country_info['info']
        published_date = Date.parse(country_info['published_date'])
        possible_bannees = country_info['possible_bannees']

        if possible_bannees.empty? ||
            (possible_bannees.length == 1 && possible_bannees[0] == '')
          bannee = Country.find_by(all_countries: true)
          status = resolve_ban_request_status(banner, bannee, ban_description)
          scrape_request.scraper_ban_requests.create!(
            bannee: bannee,
            banner: banner,
            ban_description: ban_description,
            published_date: published_date,
            status: status
          )

        else
          possible_bannees.each do |bannee_code|
            bannee = Country.find_by_code(bannee_code)
            resolve_ban_request_status(banner, bannee, ban_description)
            status = resolve_ban_request_status(banner, bannee, ban_description)
            scrape_request.scraper_ban_requests.create!(
              bannee: bannee,
              banner: banner,
              ban_description: ban_description,
              published_date: published_date,
              status: status
            )
          end
        end
      rescue Exception => e
        byebug
      end


    end

    scrape_request.date = date
    scrape_request.save
    render json: scrape_request, serializer: ScraperRequestSerializer
  end

  def get_pending_review
    pending_reviews = ScraperBanRequest.where(status: ScraperRequestStatus::PENDING_REVIEW)
    render json: pending_reviews, each_serializer: ScraperBanRequestSerializer
  end

  private
  #TODO find a better implementation for this
  def resolve_ban_request_status(banner, bannee, ban_description)
    similar_ban_reqs =
      ScraperBanRequest.where(banner: banner, bannee: bannee).order(
        published_date: :desc
      )
    return ScraperRequestStatus::PENDING_REVIEW if similar_ban_reqs.length == 0

    latest_similar_ban_req = similar_ban_reqs.first
    latest_similar_ban_req_status = latest_similar_ban_req.status

    similar_ban_reqs.each do |scraper_ban_request|
      next if scraper_ban_request.status == ScraperRequestStatus::DONE
      scraper_ban_request.status = ScraperRequestStatus::OUTDATED
      scraper_ban_request.save
    end

    status = ScraperRequestStatus::PENDING_REVIEW

    if latest_similar_ban_req_status == ScraperRequestStatus::DONE
      if ban_description == latest_similar_ban_req.ban_description
        status = ScraperRequestStatus::DONE
      end
    end

    return status
  end
end
