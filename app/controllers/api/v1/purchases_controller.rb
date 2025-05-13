module Api
  module V1
    class PurchasesController < BaseController
      before_action :ensure_customer!
      before_action :set_asset, only: [:create]

      def index
        purchases = current_user.purchases.includes(:asset)
        render json: purchases, each_serializer: PurchaseSerializer
      end

      def create
        Rails.logger.info "Creating purchase for asset: #{@asset.inspect}"
        Rails.logger.info "Asset price: #{@asset.price} (#{@asset.price.class})"
        
        purchase = current_user.purchases.build
        purchase.asset = @asset
        purchase.amount = BigDecimal(@asset.price.to_s)

        Rails.logger.info "Built purchase with amount: #{purchase.amount} (#{purchase.amount.class})"

        if purchase.save
          Rails.logger.info "Purchase saved successfully: #{purchase.inspect}"
          render json: purchase, serializer: PurchaseSerializer, status: :created
        else
          Rails.logger.error "Purchase save failed: #{purchase.errors.full_messages}"
          render json: { errors: purchase.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_asset
        @asset = Asset.find(params[:asset_id])
      end

      def purchase_params
        params.permit(:asset_id)
      end

      def ensure_customer!
        unless current_user.customer?
          render json: { error: 'Only customers can make purchases' }, status: :forbidden
        end
      end
    end
  end
end 