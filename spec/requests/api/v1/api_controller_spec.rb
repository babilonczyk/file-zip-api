require 'rails_helper'

RSpec.describe Api::V1::ApiController, type: :request do
  # -------------------------------------------------------------------------------
  # DELETE /api/v1/auth/sign_out endpoint uses authorize_request
  # used as an example to avoid not_found status and test the authorize_request method
  describe 'GET /api/v1/some_path' do
    let(:headers) { { 'Authorization': "Bearer #{jwt}" } }

    let(:user) { create(:user) }
    let(:jwt) { JwtManagement::JwtEncodeService.new.call(payload: { user_id: user.id, jti: user.jti })[:jwt] }

    subject { delete '/api/v1/auth/sign_out', headers: headers }

    # -------------------------------------------------------------------------------
    context 'when jwt is valid' do
      it do
        subject

        expect(response).to have_http_status(:ok)
      end
    end

    # -------------------------------------------------------------------------------
    context 'when jwt is invalid' do
      let(:jwt) { 'invalid_jwt' }

      it 'returns error' do
        subject

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
      end
    end
  end
end
