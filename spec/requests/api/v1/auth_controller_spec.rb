require 'rails_helper'
require 'swagger_helper'

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

  # -------------------------------------------------------------------------------
  describe 'Swagger docs' do
    # -------------------------------------------------------------------------------
    path '/api/v1/auth/sign_up' do
      let(:email) { 'test@example.com' }
      let(:password) { 'password123' }
      let(:password_confirmation) { 'password123' }

      let(:payload) do
        {
          user: {
            email:,
            password:,
            password_confirmation:
          }
        }
      end

      post 'Sign up a new user' do
        tags 'Authentication'
        consumes 'application/json'

        parameter name: :payload, in: :body, schema: {
          type: :object,
          properties: {
            user: {
              type: :object,
              properties: {
                email: { type: :string },
                password: { type: :string },
                password_confirmation: { type: :string }
              },
              required: %w[email password password_confirmation]
            }
          },
          required: ['user']
        }

        response '201', 'User created successfully' do
          run_test!
        end

        response '422', 'Validation errors' do
          let(:email) { 'invalid_email' }

          run_test!
        end
      end
    end

    # -------------------------------------------------------------------------------
    path '/api/v1/auth/sign_in' do
      let(:user_email) { 'user@gmail.com' }
      let(:password) { 'password123' }
      let!(:user) { create(:user, email: user_email, password:) }

      let(:email) { user_email }

      let(:payload) do
        {
          user: {
            email:,
            password:
          }
        }
      end

      post 'Sign in a user' do
        tags 'Authentication'
        consumes 'application/json'

        parameter name: :payload, in: :body, schema: {
          type: :object,
          properties: {
            user: {
              type: :object,
              properties: {
                email: { type: :string },
                password: { type: :string }
              },
              required: %w[email password]
            }
          },
          required: ['user']
        }

        response '200', 'Returns a JWT token for valid credentials' do
          run_test!
        end

        response '401', 'Invalid credentials' do
          let(:email) { 'invalid_email@test.com' }

          run_test!
        end
      end
    end

    # -------------------------------------------------------------------------------
    path '/api/v1/auth/sign_out' do
      let!(:user) { create(:user) }
      let(:jwt) { JwtManagement::JwtEncodeService.new.call(payload: { user_id: user.id, jti: user.jti })[:jwt] }
      let(:Authorization) { "Bearer #{jwt}" }

      delete 'Sign out a user' do
        tags 'Authentication'
        consumes 'application/json'
        security [bearer_auth: []]
        parameter name: :Authorization, in: :header, schema: {
          type: :string,
          example: 'Bearer <YOUR_JWT_TOKEN>'
        }, required: true, description: 'Bearer token for authorization'

        response '200', 'User logged out successfully' do
          run_test!
        end

        response '401', 'Unauthorized' do
          let(:Authorization) { 'Bearer invalid_token' }
          run_test!
        end
      end
    end
  end
end
