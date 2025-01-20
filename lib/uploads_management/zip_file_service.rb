require 'zip'

module UploadsManagement
  class ZipFileService
    def call(file:, path:, password: nil)
      return { error: 'File can\'t be blank' } if file.blank?
      return { error: 'Zip path can\'t be blank' } if path.blank?

      # Write the file into a zip archive
      Zip::File.open(path, Zip::File::CREATE) do |zip|
        zip.get_output_stream(File.basename(file.path)) do |zip_file|
          zip_file.write(file.read)
        end
      end

      # Encrypt the zip file with a password (if provided)
      if password.present?
        temp_path = "#{path}.temp"
        `zip -P #{Shellwords.escape(password)} -j #{Shellwords.escape(temp_path)} #{Shellwords.escape(path)}`
        FileUtils.mv(temp_path, path)
      end

      {}
    end
  end
end
