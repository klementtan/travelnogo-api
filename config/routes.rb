Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post '/ban' => 'bans#create'
      post '/many_ban' => 'bans#create_many'
      get '/ban/:bannee' => 'bans#get_country_banner'
      get '/ban/:bannee/:banner' => 'bans#get_ban'
      get '/many_ban/:banner' => 'bans#get_many_ban'
      delete '/ban/:bannee/:banner' => 'bans#delete_ban'
    end
  end
end
