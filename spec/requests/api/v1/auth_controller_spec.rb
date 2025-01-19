require 'rails_helper'

RSpec.describe Api::V1::AuthController, type: :request do
  let(:email) { 'dummy@email.com' }
  let(:password) { 'dummy_password' }
  let(:password_confirmation) { password }

  # -------------------------------------------------------------------------------
  describe 'POST /api/v1/auth/sign_up' do
    let(:headers) { { 'Content-Type': 'application/json' } }
    let(:params) do
      {
        user: {
          email:,
          password:,
          password_confirmation:
        }
      }.to_json
    end

    subject { post '/api/v1/auth/sign_up', params:, headers: }

    # -------------------------------------------------------------------------------
    context 'on success' do
      it 'creates a new user and returns a success message' do
        expect { subject }.to change { User.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq('User created successfully')
      end
    end

    # -------------------------------------------------------------------------------
    context 'on failure' do
      # -------------------------------------------------------------------------------
      context 'when password and password_confirmation do not match' do
        let(:password_confirmation) { 'not_matching_password' }

        it 'returns error' do
          expect { subject }.not_to(change { User.count })

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)['errors']).not_to be_empty
        end
      end

      # -------------------------------------------------------------------------------
      context 'when email is already taken' do
        let!(:user) { create(:user, email:) }

        it 'returns error' do
          expect { subject }.not_to(change { User.count })

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)['errors']).not_to be_empty
        end
      end
    end
  end

  # -------------------------------------------------------------------------------
  describe 'POST /api/v1/auth/sign_in' do
    let!(:user) { create(:user, email:, password:, password_confirmation:) }

    let(:headers) { { 'Content-Type': 'application/json' } }
    let(:params) do
      {
        user: {
          email:,
          password:
        }
      }.to_json
    end

    subject { post '/api/v1/auth/sign_in', params:, headers: }

    # -------------------------------------------------------------------------------
    context 'on success' do
      it 'returns a jwt token' do
        expect { subject }.to(change { user.reload.jti })

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['jwt']).not_to be_nil
      end
    end

    # -------------------------------------------------------------------------------
    context 'on failure' do
      # -------------------------------------------------------------------------------
      context 'when email is invalid' do
        let(:params) do
          {
            user: {
              email: 'non_existent_email@test.com',
              password:
            }
          }.to_json
        end

        it 'returns error' do
          subject

          expect(response).to have_http_status(:unauthorized)
          expect(JSON.parse(response.body)['error']).to eq('Invalid email or password')
        end
      end

      # -------------------------------------------------------------------------------
      context 'when password is invalid' do
        let!(:user) { create(:user, email:, password:) }

        let(:params) do
          {
            user: {
              email:,
              password: 'invalid_password'
            }
          }.to_json
        end

        it 'returns error' do
          subject

          expect(response).to have_http_status(:unauthorized)
          expect(JSON.parse(response.body)['error']).to eq('Invalid email or password')
        end
      end
    end
  end

  # -------------------------------------------------------------------------------
  describe 'DELETE /api/v1/auth/sign_out' do
    let!(:user) { create(:user) }
    let(:headers) { { 'Content-Type': 'application/json', 'Authorization': "Bearer #{jwt}" } }

    subject { delete '/api/v1/auth/sign_out', headers: }

    # -------------------------------------------------------------------------------
    context 'on success' do
      let(:jwt) { JwtManagement::JwtEncodeService.new.call(payload: { user_id: user.id, jti: user.jti })[:jwt] }

      it 'returns a success message' do
        expect { subject }.to(change { user.reload.jti })

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Logged out successfully')
      end
    end

    # -------------------------------------------------------------------------------
    context 'on failure' do
      # -------------------------------------------------------------------------------
      context 'when jwt is invalid' do
        let(:jwt) { 'expired' }

        it 'returns error' do
          subject

          expect(response).to have_http_status(:unauthorized)
          expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
        end
      end
    end
  end
end
