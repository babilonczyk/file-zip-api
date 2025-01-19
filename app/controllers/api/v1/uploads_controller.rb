module Api
  module V1
    class UploadsController < Api::V1::ApiController
      # ----------------------------------------------
      def index
        files = current_user.uploads

        files = files.map do |file|
          {
            idx: file.prefix_id,
            name: file.name,
            url: file.url
          }
        end

        render json: { files: files }
      end

      # ----------------------------------------------
      def create
        # Create a new file

        # zip it

        # upload it

        # Return the file download link & password
      end

      # ----------------------------------------------
      def delete
        file = current_user.uploads.find_by_prefix_id(params[:idx])

        return render json: { error: 'File not found' }, status: :not_found if file.nil?

        file.destroy

        render json: { message: 'File deleted successfully' }
      end
    end
  end
end
