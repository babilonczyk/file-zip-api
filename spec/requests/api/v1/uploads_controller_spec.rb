require 'rails_helper'

RSpec.describe Api::V1::UploadsController, type: :request do
  let!(:user) { create(:user) }
  let(:jwt) { JwtManagement::JwtEncodeService.new.call(payload: { user_id: user.id, jti: user.jti })[:jwt] }

  # -------------------------------------------------------------------------------
  shared_examples 'unauthorized' do
    it 'returns unauthorized status' do
      subject

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
    end
  end

  # -------------------------------------------------------------------------------
  describe 'GET /api/v1/files' do
    let(:headers) { { 'Content-Type': 'application/json', 'Authorization': "Bearer #{jwt}" } }
    let!(:files) { create_list(:upload, 3, user: user) }

    subject { get '/api/v1/files', headers: headers }

    let(:result) do
      files.map do |file|
        {
          'idx' => file.prefix_id,
          'name' => file.name,
          'url' => file.url
        }
      end
    end

    # -------------------------------------------------------------------------------
    context 'when user is authenticated', focus: true do
      it 'returns a list of files' do
        subject

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['files'].size).to eq(3)
        expect(JSON.parse(response.body)['files']).to eq(result)
      end
    end

    context 'when user is not authenticated' do
      let(:jwt) { 'expired' }

      it_behaves_like 'unauthorized'
    end
  end

  # -------------------------------------------------------------------------------
  describe 'POST /api/v1/files' do
  end

  # -------------------------------------------------------------------------------
  describe 'DELETE /api/v1/files/:idx' do
    let!(:file) { create(:upload, user: user) }
    let(:headers) { { 'Content-Type': 'application/json', 'Authorization': "Bearer #{jwt}" } }

    subject { delete "/api/v1/files/#{file.prefix_id}", headers: headers }

    # -------------------------------------------------------------------------------
    context 'when user is authenticated' do
      it 'deletes the file' do
        expect { subject }.to change { user.uploads.count }.by(-1)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('File deleted successfully')
      end
    end

    # -------------------------------------------------------------------------------
    context 'when file is not found' do
      let(:prefix_id) { 'invalid' }

      it 'returns error' do
        delete "/api/v1/files/#{prefix_id}", headers: headers

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('File not found')
      end
    end

    # -------------------------------------------------------------------------------
    context 'when user is not authenticated' do
      let(:jwt) { 'expired' }

      it_behaves_like 'unauthorized'
    end
  end
end
