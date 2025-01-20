require 'rails_helper'
require 'zip'

RSpec.describe UploadsManagement::ZipFileService do
  let!(:file) do
    Tempfile.new('file').tap do |f|
      f.write('TEMPORARY FILE')
      f.rewind
    end
  end
  let(:path) { Rails.root.join('tmp', 'file.zip') }
  let(:password) { 'password' }

  after do
    if path.present? && File.exist?(path)
      file&.close
      file&.unlink
      File.delete(path)
    end
  end

  subject { described_class.new.call(file: file, path: path, password: password) }

  # -------------------------------------------------------------------------------
  describe 'call' do
    # -------------------------------------------------------------------------------
    context 'on success' do
      it 'returns an empty hash' do
        ret = subject
        expect(ret).to eq({})
      end

      it 'creates a zip file' do
        subject
        expect(File.exist?(path)).to be_truthy
      end

      it 'creates a zip file with password' do
        subject

        output = `unzip -P #{password} -tq #{path} 2>&1`
        expect(output).to include('No errors detected')
      end
    end

    # -------------------------------------------------------------------------------
    context 'on failure' do
      # -------------------------------------------------------------------------------
      context 'when file is blank' do
        let(:file) { nil }

        it 'returns an error' do
          ret = subject
          expect(ret[:error]).to eq('File can\'t be blank')
        end
      end

      # -------------------------------------------------------------------------------
      context 'when path is blank' do
        let(:path) { nil }

        it 'returns an error' do
          ret = subject
          expect(ret[:error]).to eq('Zip path can\'t be blank')
        end
      end
    end
  end
end
