class Api::V1::ScrapersController < Api::V1::BaseController
  def create_iata_request
    authenticate_internal
    REDIS.del("pending_review")
    ini_pending_count = ScraperBanRequest.where(status: ScraperRequestStatus::PENDING_REVIEW).length
    send_slack_message('Received data from scraper...') 
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
      rescue StandardError => e
        ApiQueryLog.create!(response: e.message)
        #Log
      end


    end
    send_slack_message('Completed processing scraped data!✅')
    finial_pending_count = ScraperBanRequest.where(status: ScraperRequestStatus::PENDING_REVIEW).length
    new_pending_count = finial_pending_count - ini_pending_count
    send_slack_message('Number of new travel restriciton to review: ' + new_pending_count.to_s)
    scrape_request.date = date
    scrape_request.save
    render json: scrape_request, serializer: ScraperRequestSerializer
  end

  def get_pending_review
    if REDIS.get("pending_review")
      render json: REDIS.get("pending_review")
      return
    end
    pending_reviews = ScraperBanRequest.where(status: ScraperRequestStatus::PENDING_REVIEW).order(:banner_id)
    ban_request_ptr = 0
    curr_banner = pending_reviews[ban_request_ptr].banner
    curr_banner_pending_review = []
    response = {}
    while ban_request_ptr < pending_reviews.length
      banner = pending_reviews[ban_request_ptr].banner
      if banner == curr_banner

        curr_banner_pending_review.append(ScraperBanRequestSerializer.new(pending_reviews[ban_request_ptr]).serializable_hash)
      else
        response[curr_banner.code] = curr_banner_pending_review
        curr_banner_pending_review = []
        curr_banner = pending_reviews[ban_request_ptr+1].banner if ban_request_ptr + 1 < pending_reviews.length
      end
      ban_request_ptr+=1
    end
    response[curr_banner.code] = curr_banner_pending_review if response.empty? && !curr_banner_pending_review.empty?
    REDIS.set "pending_review", response.to_json
    render json: response
  end

  def get_pending_review_overview
    pending_reviews = ScraperBanRequest.where(status: ScraperRequestStatus::PENDING_REVIEW).order(:banner_id)
    ban_request_ptr = 0
    curr_banner = pending_reviews[ban_request_ptr].banner
    curr_count = 0;
    curr_banner_pending_review = []
    response = {}
    while ban_request_ptr < pending_reviews.length
      banner = pending_reviews[ban_request_ptr].banner
      if banner == curr_banner
        curr_count += 1
      else
        response[curr_banner.code] = curr_count
        curr_count = 0;
        curr_banner = pending_reviews[ban_request_ptr+1].banner if ban_request_ptr + 1 < pending_reviews.length
      end
      ban_request_ptr+=1
    end
    render json: {
        overview: response,
        total_count: pending_reviews.length
    }
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
