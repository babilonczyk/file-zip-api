module Api
  module V1
    class ApiController < ApplicationController
      protect_from_forgery with: :null_session

      before_action :authorize_request

      attr_reader :current_user

      # ----------------------------------------------
      def authorize_request
        header = request.headers['Authorization']
        jwt = header.split(' ').last if header

        begin
          payload = JwtManagement::JwtDecodeService.new.call(jwt: jwt)[:payload]

          return render json: { error: 'Unauthorized' }, status: :unauthorized if payload.nil?

          @current_user = User.find(payload[:user_id])
        rescue JWT::DecodeError
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end
    end
  end
end
