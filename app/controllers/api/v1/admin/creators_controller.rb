module Api
  module V1
    module Admin
      class CreatorsController < Api::V1::BaseController
        before_action :ensure_admin!

        def earnings
          creators = User.creator.includes(:assets)
          earnings_data = creators.map do |creator|
            {
              creator_id: creator.id,
              name: creator.name,
              email: creator.email,
              total_earnings: creator.total_earnings
            }
          end

          render json: earnings_data
        end

        private

        def ensure_admin!
          unless current_user&.admin?
            render json: { error: 'Only admins can access this endpoint' }, status: :forbidden
          end
        end
      end
    end
  end
end 