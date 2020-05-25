require 'rails_helper'

RSpec.describe 'Bans Controller', type: :request do
  before(:each) {
    User.destroy_all
  }

  firebase_user_mock_json = {'name'=>'Klement Tan', 'picture'=>'https://lh3.googleusercontent.com/a-/AOh14Gh53_ytx2BVPdKhxDlgW3bXDqiyLBsyIVSxiWlf', 'iss'=>'https://securetoken.google.com/travelnogo', 'aud'=>'travelnogo', 'auth_time'=>1590413251, 'user_id'=>'45HKGKK14HakqHfBsUOqfExUJgm2', 'sub'=>'45HKGKK14HakqHfBsUOqfExUJgm2', 'iat'=>1590413252, 'exp'=>1590416852, 'email'=>'klement.tandn@gmail.com', 'email_verified'=>true, 'firebase'=>{'identities'=>{'google.com'=>['114474468345739340761'], 'email'=>['klement.tandn@gmail.com']}, 'sign_in_provider'=>'google.com'}}

  describe 'Users Sad Flow' do
    it 'Cannot get user without bear token' do

      get '/api/v1/user/'
      expect(response.status).to eq(403)
      expect(JSON.parse(response.body)['error']).to eq('Bearer Token empty')
    end
    it 'Cannot get user without valid bear token' do

      get '/api/v1/user/', as: :json, headers:{ Authorization: 'Bearer foobar'}
      expect(response.status).to eq(403)
      expect(JSON.parse(response.body)['error']).to eq('Invalid token')
    end
    it 'should not let user create more users for non super_admin' do

      allow_any_instance_of(FirebaseIdToken::Signature).to receive(:verify).and_return(firebase_user_mock_json)

      user = User.create!(email: 'klement.tandn@gmail.com').add_role AuthorizationRoles::ADMIN
      user.save

      post '/api/v1/user/', as: :json, headers:{ Authorization: 'Bearer foobar'}

      expect(response.status).to eq(403)
      response_json = JSON.parse(response.body)
      expect(response_json['error']).to eq('Klement Tan is not authorised to execute this task')
    end
  end

  describe 'User Happy flow' do
    it 'should update user data with the valid info' do

      allow_any_instance_of(FirebaseIdToken::Signature).to receive(:verify).and_return(firebase_user_mock_json)

      user = User.create!(email: 'klement.tandn@gmail.com').add_role AuthorizationRoles::ADMIN
      user.save

      get '/api/v1/user/', as: :json, headers:{ Authorization: 'Bearer foobar'}

      expect(response.status).to eq(200)
      response_json = JSON.parse(response.body)
      expect(response_json['name']).to eq('Klement Tan')
      expect(response_json['email']).to eq('klement.tandn@gmail.com')
      expect(response_json['role']).to eq('admin')
    end

    it 'should create new admin user' do

      allow_any_instance_of(FirebaseIdToken::Signature).to receive(:verify).and_return(firebase_user_mock_json)

      user = User.create!(email: 'klement.tandn@gmail.com').add_role AuthorizationRoles::SUPER_ADMIN
      user.save

      post '/api/v1/user/', :params => { :new_admin_email => ["klementspy@gmail.com", "klementtabn@gmail.com"]}, as: :json, headers:{ Authorization: 'Bearer foobar'}

      expect(response.status).to eq(200)
      response_json = JSON.parse(response.body)
      expect(response_json[0]['email']).to eq('klementspy@gmail.com')
      expect(response_json[0]['name']).to eq(nil)
      expect(response_json[0]['role']).to eq('admin')
      expect(response_json[1]['email']).to eq('klementtabn@gmail.com')
      expect(response_json[1]['name']).to eq(nil)
      expect(response_json[1]['role']).to eq('admin')
    end

  end

end