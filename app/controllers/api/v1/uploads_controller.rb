module Api
  module V1
    class UploadsController < Api::V1::ApiController
      MAX_FILE_SIZE_MB = 10
      public_constant :MAX_FILE_SIZE_MB

      MAX_FILES_PER_USER = 10
      public_constant :MAX_FILES_PER_USER

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
        return render json: { error: 'File not found' }, status: :not_found if params[:file].nil?
        return render json: { error: 'Name can\'t be blank' }, status: :bad_request if params[:name].blank?

        file = params[:file]

        if file.size > MAX_FILE_SIZE_MB.megabytes
          return render json: { error: "File size cannot exceed #{MAX_FILE_SIZE_MB} MB" }, status: :unprocessable_entity
        end

        if current_user.uploads.count >= MAX_FILES_PER_USER
          return render json: { error: "You cannot upload more than #{MAX_FILES_PER_USER} files" },
                        status: :unprocessable_entity
        end

        password = SecureRandom.hex(16)
        filename = "#{params[:name]}.zip"
        temp_path = Rails.root.join('tmp', filename)

        ActiveRecord::Base.transaction do
          ret = UploadsManagement::ZipFileService.new.call(file: file, path: temp_path, password: password)

          return render json: ret, status: :unprocessable_entity if ret[:error].present?

          upload = Upload.new
          upload.name = filename
          upload.user = current_user
          upload.save!

          upload.file.attach(io: File.open(temp_path), filename: filename)

          # Record needs to be saved and file attached before generating the URL
          upload.url = url_for(upload.file)
          upload.save!

          File.delete(temp_path) if File.exist?(temp_path)

          return render json: { name: upload.name, url: upload.url, password: password, hint: 'Remember to save the password.' },
                        status: :created
        end
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
