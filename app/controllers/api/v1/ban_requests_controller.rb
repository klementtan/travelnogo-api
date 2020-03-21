class Api::V1::BanRequestsController < Api::V1::BaseController
  def create 
    banner = Country.find_by_code(params[:banner])
    bannee = Country.find_by_code(params[:bannee])
    ban_request = BanRequest.create(:banner => banner, :bannee => bannee)
    if params[:contributor_id]
      ban_request.contributor =  Contributor.find(params[:contributor_id])
    end
    if params[:ban_type]
      ban_request.ban_type = params[:ban_type]
    end
    if params[:ban_description]
      ban_request.ban_description = params[:ban_description]
    end
    if params[:ban_url]
      ban_request.ban_url = params[:ban_url]
    end
    ban_request.save
    render json: {
      status: 200,
      ban_request: ban_request,
    }
  end
end
