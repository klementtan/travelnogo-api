class Api::V1::BansController < Api::V1::BaseController
  def create 
    authenticate
    banner = Country.find_by_code(params[:banner])
    bannee = Country.find_by_code(params[:bannee])
    ban = Ban.find_by(banner: banner, bannee: bannee)
    unless ban 
      ban = Ban.create(:banner => banner, :bannee => bannee)
    end
    if params[:ban_type]
      ban.ban_type = params[:ban_type]
    end
    if params[:ban_description]
      ban.ban_description = params[:ban_description]
    end
    if params[:ban_url]
      ban.ban_url = params[:ban_url]
    end
    ban.save
    render json: {
      status: 200,
      ban: ban,
    }
  end

  def create_many
    authenticate
    
    banner = Country.find_by_code(params[:banner])

    bans = []

    params[:bannee].each { |bannee_code|
      bannee = Country.find_by_code(bannee_code)
      ban = Ban.find_by(banner: banner, bannee: bannee)
      unless ban 
        ban = Ban.create(:banner => banner, :bannee => bannee)
      end
      if params[:ban_type]
        ban.ban_type = params[:ban_type]
      end
      if params[:ban_description]
        ban.ban_description = params[:ban_description]
      end
      if params[:ban_url]
        ban.ban_url = params[:ban_url]
      end
      ban.save
      bans.push(ban)
    }
    render json: {
      status: 200,
      bans: bans,
    }
  end

  def get_country_banner
    country = Country.find_by_code( params[:bannee])
    bans = Ban.where( bannee: country)
    bans_json = JSON.parse(bans.to_json)

    bans_json.each { |ban|
      banner_id = ban["banner_id"]
      banner_code = Country.find(banner_id).code
      ban["banner_code"] = banner_code
    }
    render json: {
      bans: bans_json
    }
  end

  def get_ban
    banner = Country.find_by_code( params[:banner])
    bannee = Country.find_by_code( params[:bannee])
    ban = Ban.find_by( bannee: bannee, banner: banner)
    raise ActiveRecord::RecordNotFound, "Ban does not exit" unless ban
    ban_json = JSON.parse(ban.to_json)
    banner_id = ban_json["banner_id"]
    bannee_id = ban_json["bannee_id"]
    banner_code = Country.find(banner_id).code
    bannee_code = Country.find(bannee_id).code
    ban_json["banner_code"] = banner_code
    ban_json["bannee_code"] = bannee_code
    render json: {
      ban: ban_json
    }
  end

  def get_many_ban
    
    banner = Country.find_by_code( params[:banner])
    bannees_code = params[:bannees].split(',')
    bans = []
    bannees_code.each { |bannee_code|
      bannee = Country.find_by_code( bannee_code )
      ban = Ban.find_by( bannee: bannee, banner: banner)
      next unless ban
      ban_json = JSON.parse(ban.to_json)
      banner_id = ban_json["banner_id"]
      bannee_id = ban_json["bannee_id"]
      banner_code = Country.find(banner_id).code
      bannee_code = Country.find(bannee_id).code
      ban_json["banner_code"] = banner_code
      ban_json["bannee_code"] = bannee_code
      bans.push(ban_json)
    }
    render json: {
      bans: bans
    }
  end


  def delete_ban
    authenticate
    banner = Country.find_by_code( params[:banner])
    bannee = Country.find_by_code( params[:bannee])
    ban = Ban.find_by( bannee: bannee, banner: banner)
    raise ActiveRecord::RecordNotFound, "Ban does not exit" unless ban
    Ban.destroy(ban.id)
    render json: {
      message: "Ban deleted"
    }
  end
end
