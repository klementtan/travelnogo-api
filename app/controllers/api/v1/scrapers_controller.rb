class Api::V1::ScrapersController < Api::V1::BaseController
  def create_iata_request
    date = params['date']
    scrape_data = params['scrape_data']
    scrape_request =
      ScraperRequest.create(source: ScraperSources::IATA, date: date)

    scrape_data.each do |country_name, country_info|
      banner = Country.find_by_code(country_info['ISO2'])
      ban_description = country_info['info']
      published_date = country_info['published_date']
      possible_bannees = country_info['possible_bannees']

      if possible_bannees.empty?
        Country.all.each { |bannee| possible_bannees.push(bannee.code) }
      end

      possible_bannees.each do |bannee_code|
        bannee = Country.find_by_code(bannee_code)
        scrape_request.scraper_ban_requests.create(
          bannee: bannee,
          banner: banner,
          ban_description: ban_description,
          published_date: published_date
        )
      end
    end

    scrape_request.date = date
    scrape_request.save

    render json: scrape_request
  end
end
