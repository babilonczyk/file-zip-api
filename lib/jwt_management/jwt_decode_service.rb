module JwtManagement
  class JwtDecodeService
    SECRET_KEY = Rails.application.secret_key_base
    HASHING_STRATEGY = 'HS256'

    def call(jwt)
      return { error: 'Token can\'t be blank' } if jwt.blank?

      data = JWT.decode(jwt, SECRET_KEY, HASHING_STRATEGY)

      payload = data.first.transform_keys(&:to_sym)

      # Change epoch time to Time object
      expire_at = Time.at(payload[:exp]).utc

      { payload: payload.except(:exp), expire_at: }
    rescue JWT::DecodeError
      { error: 'Token couldn\'t be decoded.' }
    end
  end
end
