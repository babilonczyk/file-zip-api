class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  before_create :initialize_jti

  def regenerate_jti
    new_jti = SecureRandom.uuid
    update!(jti: new_jti)
  end

  private

  # ----------------------------------------------
  def initialize_jti
    jit = SecureRandom.uuid
    self.jti = jit
  end
end
