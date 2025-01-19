require 'rails_helper'

RSpec.describe User, type: :model do
  let(:email) { 'dummy@email.com' }
  let(:password) { 'password' }

  # -------------------------------------------------------------------------------
  context 'on user creation' do
    it 'should automaticaly generate jti' do
      user = User.create(email: email, password: password)

      expect(user.jti).not_to be_nil
    end
  end

  # -------------------------------------------------------------------------------
  describe '#regenerate_jti' do
    it 'should change the jti of the user' do
      user = User.create(email: email, password: password)
      old_jti = user.jti

      user.regenerate_jti

      expect(user.jti).not_to eq(old_jti)
    end
  end
end
