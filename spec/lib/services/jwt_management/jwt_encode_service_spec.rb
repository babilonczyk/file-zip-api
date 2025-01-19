require 'rails_helper'

RSpec.describe JwtManagement::JwtEncodeService do
  let(:payload) { { user_id: 1 } }
  let(:expire_at) { 24.hours.from_now }

  subject { described_class.new.call(payload:, expire_at:) }

  # -------------------------------------------------------------------------------
  context '.call' do
    # -------------------------------------------------------------------------------
    context 'on success' do
      # -------------------------------------------------------------------------------
      it 'return a jwt token' do
        ret = subject

        expect(ret[:jwt]).not_to be_nil
      end
    end

    # -------------------------------------------------------------------------------
    context 'on failure' do
      # -------------------------------------------------------------------------------
      context 'when payload is blank' do
        let(:payload) { nil }

        it 'returns error' do
          ret = subject

          expect(ret[:error]).to eq('Payload can\'t be blank')
        end
      end

      # -------------------------------------------------------------------------------
      context 'when exp is blank' do
        let(:expire_at) { nil }

        it 'returns error' do
          ret = subject

          expect(ret[:error]).to eq('Expire time can\'t be blank')
        end
      end

      # -------------------------------------------------------------------------------
      context 'when exp is not a valid time' do
        let(:expire_at) { 'dummy_value' }

        it 'returns error' do
          ret = subject

          expect(ret[:error]).to eq('Expire time must be a valid time')
        end
      end
    end
  end
end
