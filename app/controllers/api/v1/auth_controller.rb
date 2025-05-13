module Api
  module V1
    class AuthController < BaseController
      skip_before_action :authenticate_user!, only: [:register, :login]

      def register
        # check if admin
        if params[:user][:role] == 'admin'
          admin_code = params[:user][:admin_code]
          env_admin_code = ENV['ADMIN_REGISTRATION_CODE'] || '1234'
          
          if admin_code != env_admin_code
            return render json: { error: 'Wrong admin code' }, status: :unauthorized
          end
        end

        # if not admin then remove admin code from payload
        user_data = user_params.except(:admin_code)
        user = User.new(user_data)

        if user.save
          token = generate_token(user)
          render json: { token: token, user: UserSerializer.new(user) }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def login
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          token = generate_token(user)
          render json: { token: token, user: UserSerializer.new(user) }
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      def me
        render json: current_user, serializer: UserSerializer
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation, :name, :role, :admin_code)
      end

      def generate_token(user)
        JWT.encode(
          { user_id: user.id, exp: 24.hours.from_now.to_i },
          Rails.application.credentials.secret_key_base,
          'HS256'
        )
      end
    end
  end
end 