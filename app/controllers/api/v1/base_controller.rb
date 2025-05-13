module Api
  module V1
    class BaseController < ApplicationController
      include ActionController::Cookies
      
      before_action :authenticate_user!

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
      rescue_from ActionController::ParameterMissing, with: :parameter_missing
      rescue_from User::NotAuthorized, with: :user_not_authorized

      private

      def authenticate_user!
        unless current_user
          render json: { error: 'You need to sign in before continuing' }, status: :unauthorized
        end
      end

      def current_user
        @current_user ||= begin
          token = request.headers['Authorization']&.split(' ')&.last
          return nil unless token

          decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: 'HS256')
          User.find_by(id: decoded_token[0]['user_id'])
        rescue JWT::DecodeError
          nil
        end
      end

      def not_found(exception)
        render json: { error: exception.message }, status: :not_found
      end

      def record_invalid(exception)
        render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
      end

      def parameter_missing(exception)
        render json: { error: exception.message }, status: :bad_request
      end

      def user_not_authorized
        render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
      end
    end
  end
end 