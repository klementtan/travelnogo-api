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
    ban.save
    render json: { status: 200, ban: ban }
  end

  def create_many
    authenticate

    banner = Country.find_by_code(params[:banner])

    bans = []

    params[:bannee].each do |bannee_code|
      bannee = Country.find_by_code(bannee_code)
      ban = Ban.find_by(banner: banner, bannee: bannee)
      next if banner == bannee
      ban = Ban.create(banner: banner, bannee: bannee) unless ban
      ban.ban_type = params[:ban_type] if params[:ban_type]
      ban.ban_description = params[:ban_description] if params[:ban_description]
      ban.ban_url = params[:ban_url] if params[:ban_url]
      ban.save
      bans.push(ban)
    end
    render json: { status: 200, bans: bans }
  end

  def get_country_banner
    country = Country.find_by_code(params[:bannee])
    bans = Ban.where(bannee: country).order(:banner_id)
    bans.order(:bannee)
    bans_json = JSON.parse(bans.to_json)

    bans_json.each do |ban|
      banner_id = ban['banner_id']
      banner_code = Country.find(banner_id).code
      ban['banner_code'] = banner_code
    end
    bans_json
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
    end
    render json: { deleted_bans: deleted_bans }
  end

  def get_all_ban
    bans = Ban.all.order(:banner_id).reverse_order
    bans_json = JSON.parse(bans.to_json)
    bans_json.each do |ban|
      banner = Country.find(ban['banner_id'])
      bannee = Country.find(ban['bannee_id'])
      ban['banner_name'] = banner.country_name
      ban['banner_code'] = banner.code
      ban['bannee_name'] = bannee.country_name
      ban['bannee_code'] = bannee.code
    end
    render json: { bans: bans_json }
  end
end
