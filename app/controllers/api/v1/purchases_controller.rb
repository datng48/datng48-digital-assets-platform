module Api
  module V1
    class PurchasesController < BaseController
      before_action :ensure_customer!, only: [:create]
      before_action :set_asset, only: [:create]

      def index
        purchases = current_user.purchases.includes(:asset)
        render json: purchases, each_serializer: PurchaseSerializer
      end
      
      def purchased_assets
        purchased_asset_ids = current_user.purchases.pluck(:asset_id)
        purchased_assets = Asset.where(id: purchased_asset_ids)
        
        assets_with_purchase_info = purchased_assets.map do |asset|
          asset_data = AssetSerializer.new(asset).as_json
          asset_data[:purchased] = true
          asset_data
        end
        
        render json: assets_with_purchase_info
      end

      def create
        if current_user.purchases.exists?(asset_id: @asset.id)
          render json: { 
            error: "You already purchased this asset",
            asset: {
              id: @asset.id,
              purchased: true
            }
          }, status: :unprocessable_entity
          return
        end
        
        purchase = current_user.purchases.new(
          asset: @asset,
          amount: BigDecimal(@asset.price.to_s)
        )

        if purchase.save
          creator = @asset.user
          if creator
            current_earnings = creator.total_earnings || 0.0
            new_earnings = current_earnings + purchase.amount.to_f
            creator.update_column(:total_earnings, new_earnings)
          end
          
          render json: {
            purchase: PurchaseSerializer.new(purchase),
            asset: {
              id: @asset.id,
              purchased: true
            }
          }, status: :created
        else
          render json: { errors: purchase.errors.full_messages }, status: :unprocessable_entity
        end
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
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