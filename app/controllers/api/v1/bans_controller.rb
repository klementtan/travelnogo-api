class Api::V1::BansController < Api::V1::BaseController
  def create
    authenticate
    banner = Country.find_by_code(params[:banner])
    bannee = Country.find_by_code(params[:bannee])
    ban = Ban.find_by(banner: banner, bannee: bannee)
    ban = Ban.create(banner: banner, bannee: bannee) unless ban
    ban.ban_type = params[:ban_type] if params[:ban_type]
    ban.ban_description = params[:ban_description] if params[:ban_description]
    ban.ban_url = params[:ban_url] if params[:ban_url]
    set_scraper_ban_request_done(banner, bannee)
    ban.save
    render json: { status: 200, ban: ban }
  end

  def create_many
    authenticate
    banner = Country.find_by_code(params[:banner])

    bans = []
    raise InvalidParamsError, "Enter country receiving travel restriction" if params[:bannee].empty?

    params[:bannee].each do |bannee_code|
      #update actual ban
      REDIS.del("get_country_banner/bannee: #{bannee_code}", "pending_review")
      bannee = Country.find_by_code(bannee_code)
      ban = Ban.find_by(banner: banner, bannee: bannee)
      next if banner == bannee
      ban = Ban.create(banner: banner, bannee: bannee) unless ban
      ban.ban_type = params[:ban_type] if params[:ban_type]
      ban.ban_description = params[:ban_description] if params[:ban_description]
      ban.ban_url = params[:ban_url] if params[:ban_url]
      ban.save
      bans.push(ban)
      set_scraper_ban_request_done(banner, bannee)
    end
    render json: { status: 200, bans: bans }
  end

  def get_country_banner

    country = Country.find_by_code(params[:bannee])
    if REDIS.get("get_country_banner/bannee: #{country.code}")
      render json: { bans: JSON.parse(REDIS.get("get_country_banner/bannee: #{country.code}"))}
      return
    end
    bans = Ban.where(bannee: country).order(:banner_id)
    bans.order(:bannee)
    bans_json = JSON.parse(bans.to_json)

    bans_json.each do |ban|
      banner_id = ban['banner_id']
      banner_code = Country.find(banner_id).code
      ban['banner_code'] = banner_code
    end
    REDIS.set("get_country_banner/bannee: #{country.code}", bans_json.to_json)
    render json: { bans: bans_json }
  end

  def get_country_bannee
    country = Country.find_by_code(params[:banner])
    bans = Ban.where(banner: country).order(:bannee_id)
    bans_json = JSON.parse(bans.to_json)

    bans_json.each do |ban|
      bannee_id = ban['bannee_id']
      bannee_code = Country.find(bannee_id).code
      ban['bannee_code'] = bannee_code
    end
    render json: { bans: bans_json }
  end

  def get_ban
    banner = Country.find_by_code(params[:banner])
    bannee = Country.find_by_code(params[:bannee])
    ban = Ban.find_by(bannee: bannee, banner: banner)
    raise ActiveRecord::RecordNotFound, 'Ban does not exit' unless ban
    ban_json = JSON.parse(ban.to_json)
    banner_id = ban_json['banner_id']
    bannee_id = ban_json['bannee_id']
    banner_code = Country.find(banner_id).code
    bannee_code = Country.find(bannee_id).code
    ban_json['banner_code'] = banner_code
    ban_json['bannee_code'] = bannee_code
    render json: { ban: ban_json }
  end

  def get_many_ban
    banner = Country.find_by_code(params[:banner])
    bannees_code = params[:bannees].split(',')
    bans = []
    bannees_code.each do |bannee_code|
      bannee = Country.find_by_code(bannee_code)
      ban = Ban.find_by(bannee: bannee, banner: banner)
      next unless ban
      ban_json = JSON.parse(ban.to_json)
      banner_id = ban_json['banner_id']
      bannee_id = ban_json['bannee_id']
      banner_code = Country.find(banner_id).code
      bannee_code = Country.find(bannee_id).code
      ban_json['banner_code'] = banner_code
      ban_json['bannee_code'] = bannee_code
      bans.push(ban_json)
    end
    render json: { bans: bans }
  end

  def delete_ban
    authenticate
    banner = Country.find_by_code(params[:banner])
    bannees_code = params[:bannees].split(',')
    deleted_bans = []
    bannees_code.each do |bannee_code|
      bannee = Country.find_by_code(bannee_code)
      ban = Ban.find_by(bannee: bannee, banner: banner)
      next unless ban
      deleted_bans.push(ban)
      Ban.destroy(ban.id)
      set_scraper_ban_request_done(banner, bannee)
    end
    render json: { deleted_bans: deleted_bans }
  end

  def get_all_ban
    bans = Ban.all.order(:banner_id).reverse_order

    render json: bans, each_serializer: BanSerializer
  end

  private
  def set_scraper_ban_request_done(banner, bannee)
    scraper_ban_request = ScraperBanRequest.find_by(banner: banner, bannee: bannee, status: ScraperRequestStatus::PENDING_REVIEW)
    unless scraper_ban_request.nil?
      scraper_ban_request.status = ScraperRequestStatus::DONE
      scraper_ban_request.save
    end
  end
end
