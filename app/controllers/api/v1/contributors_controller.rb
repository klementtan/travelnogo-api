class Api::V1::ContributorsController < Api::V1::BaseController
  def create
    email = params[:email]
    contributor = Contributor.find_by_email(email)
    contributor = Contributor.create(email: email) unless contributor
    contributor.name = params[:name]
    contributor.save
    render json: { status: 200, contributor: contributor }
  end
end
