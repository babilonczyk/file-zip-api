module Api
  module V1
    class AuthController < Api::V1::ApiController
      skip_before_action :authorize_request, only: [:sign_in]

      # ----------------------------------------------
      def sign_in
        # TODO: Authenticate user
        # Update JIT token on the user resource
        # Return JWT token
      end

      # ----------------------------------------------
      def sign_out
        # TODO: Invalidate JWT token
      end
    end
  end
end
