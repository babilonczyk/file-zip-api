module Api
  module V1
    class AuthController < Api::V1::ApiController
      skip_before_action :authorize_request, only: %i[sign_up sign_in]

      # ----------------------------------------------
      def sign_up
        user = User.new(user_params)
        if user.save
          render json: { message: 'User created successfully' }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # ----------------------------------------------
      def sign_in
        user = User.find_by(email: user_params[:email])
        return render json: { error: 'Invalid email or password' }, status: :unauthorized if user.nil?

        valid_password = user.valid_password?(user_params[:password])
        return render json: { error: 'Invalid email or password' }, status: :unauthorized unless valid_password

        user.regenerate_jti

        payload = { user_id: user.id, jti: user.jti }

        jwt = JwtManagement::JwtEncodeService.new.call(payload: payload)

        render json: { jwt: }, status: :ok
      end

      # ----------------------------------------------
      def sign_out
        return render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user

        # Invalidate generated JWT tokens
        current_user.regenerate_jti
        render json: { message: 'Logged out successfully' }, status: :ok
      end

      private

      # ----------------------------------------------
      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end
    end
  end
end
