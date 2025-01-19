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
    let(:file) { fixture_file_upload('spec/fixtures/files/sample.txt', 'text/plain') }
    let(:name) { 'test_zip' }
    let(:params) { { name:, file: } }
    let(:max_file_size) { Api::V1::UploadsController::MAX_FILE_SIZE_MB }
    let(:max_files_per_user) { Api::V1::UploadsController::MAX_FILES_PER_USER }

    let(:headers) { { 'Authorization': "Bearer #{jwt}" } }

    subject { post '/api/v1/files', params: params, headers: headers, as: :multipart }

    # -------------------------------------------------------------------------------
    context 'when user is authenticated' do
      # -------------------------------------------------------------------------------
      context 'when the request is valid' do
        it 'creates a zip file and returns its details' do
          subject

          expect(response).to have_http_status(:created)

          json = JSON.parse(response.body)
          expect(json['name']).to eq("#{name}.zip")
          expect(json['url']).not_to be_nil
          expect(json['password']).not_to be_nil
        end
      end

      # -------------------------------------------------------------------------------
      context 'when the file is missing' do
        let(:file) { nil }

        it 'returns an error' do
          subject

          expect(response).to have_http_status(:not_found)
          json = JSON.parse(response.body)
          expect(json['error']).to eq('File not found')
        end
      end

      # -------------------------------------------------------------------------------
      context 'when the name is missing' do
        let(:name) { nil }

        it 'returns an error' do
          subject

          expect(response).to have_http_status(:bad_request)
          json = JSON.parse(response.body)
          expect(json['error']).to eq("Name can't be blank")
        end
      end

      # -------------------------------------------------------------------------------
      context 'when the user exceeds the file upload limit' do
        before do
          create_list(:upload, max_files_per_user, user: user)
        end

        it 'returns an error' do
          subject

          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json['error']).to eq("You cannot upload more than #{max_files_per_user} files")
        end
      end
    end

    # -------------------------------------------------------------------------------
    context 'when user is not authenticated' do
      let(:jwt) { 'expired' }

      it_behaves_like 'unauthorized'
    end
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
