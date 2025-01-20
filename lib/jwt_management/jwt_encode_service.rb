module JwtManagement
  class JwtEncodeService
    SECRET_KEY = Rails.application.secret_key_base
    HASHING_STRATEGY = 'HS256'

    # -------------------------------------------------------------------------------
    def call(payload:, expire_at: 24.hours.from_now)
      return { error: 'Payload can\'t be blank' } if payload.blank?
      return { error: 'Expire time can\'t be blank' } if expire_at.blank?
      return { error: 'Expire time must be a valid time' } unless expire_at.is_a?(Time)

      payload = { **payload, exp: expire_at.to_i }

      jwt = JWT.encode(payload, SECRET_KEY, HASHING_STRATEGY)

      { jwt: jwt }
    end
  end
end
