require 'rails_helper'

RSpec.describe JwtManagement::JwtDecodeService do
  let(:payload) { { id: 1 }.freeze }
  let!(:expire_at) { 24.hours.from_now }

  let!(:jwt) { JwtManagement::JwtEncodeService.new.call(payload:, expire_at:)[:jwt] }

  subject { described_class.new.call(jwt:) }

  before do
    Timecop.freeze
  end

  # -------------------------------------------------------------------------------
  context '.call' do
    # -------------------------------------------------------------------------------
    context 'on success' do
      it 'returns a valid payload' do
        ret = subject

        expect(ret[:payload]).to eq(payload)

        # The to_i method is used to convert the time to an integer strips the microseconds
        expect(ret[:expire_at].change(usec: 0)).to eq(expire_at.change(usec: 0))
      end
    end

    # -------------------------------------------------------------------------------
    context 'on failure' do
      # -------------------------------------------------------------------------------
      context 'when jwt is blank' do
        let(:jwt) { nil }

        it 'returns an error' do
          ret = subject

          expect(ret[:error]).to eq('Token can\'t be blank')
        end
      end
    end
  end
end
