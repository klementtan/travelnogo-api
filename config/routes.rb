Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get '/helloworld' => 'users#helloworld'

      post '/ban' => 'bans#create'
      post '/many_ban' => 'bans#create_many'

      get '/ban/:bannee' => 'bans#get_country_banner'
      get '/bannee/:banner' => 'bans#get_country_bannee'
      get '/ban/:bannee/:banner' => 'bans#get_ban'
      get '/many_ban/:banner' => 'bans#get_many_ban'
      get '/bans' => 'bans#get_all_ban'

      delete '/ban/:bannees/:banner' => 'bans#delete_ban'

      post '/ban_request' => 'ban_requests#create'
      post '/contributor' => 'contributors#create'

      post '/scraper/iata' => 'scrapers#create_iata_request'
      get '/scraper' => 'scrapers#get_pending_review'

      get '/users/' => 'users#get_all_users'
      post '/user/' => 'users#create_admin_user'
      post '/user/firebase' => 'users#update_user_uuid'
    end
  end
end
