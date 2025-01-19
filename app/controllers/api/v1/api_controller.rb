module Api
  module V1
    class ApiController < ApplicationController
      before_action :authorize_request

      attr_reader :current_user

      # ----------------------------------------------
      def authorize_request
        # TODO: get Authorization header from request
        # and check if it is valid.

        # TODO: if not valid, return 401 Unauthorized
        # Else assign @current_user

        @current_user = nil
      end
    end
  end
end
