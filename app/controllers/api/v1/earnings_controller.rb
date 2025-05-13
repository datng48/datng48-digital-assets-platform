module Api
  module V1
    class EarningsController < BaseController
      before_action :ensure_admin!

      def creator_earnings
        Rails.logger.info "Fetching creator earnings"
        
        creators = User.where(role: 1)
        Rails.logger.info "Found #{creators.count} creators"
        
        earnings = creators.map do |creator|
          Rails.logger.info "Creator #{creator.id} (#{creator.name}) earnings: #{creator.total_earnings}"
          
          {
            name: creator.name,
            email: creator.email,
            total_earnings: creator.total_earnings
          }
        end

        render json: earnings
      end

      private

      def ensure_admin!
        unless current_user&.admin?
          render json: { error: 'Admin access required' }, status: :forbidden
        end
      end
    end
  end
end 