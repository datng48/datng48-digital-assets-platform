module Api
  module V1
    class AssetsController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show]
      before_action :set_asset, only: [:show, :update, :destroy]
      before_action :authorize_creator!, only: [:create, :update, :destroy, :bulk_import]

      def index
        all_assets = Asset.all
        
        if current_user
          purchased_asset_ids = current_user.purchases.pluck(:asset_id)
          assets_with_purchase_info = all_assets.map do |asset|
            asset_data = AssetSerializer.new(asset).as_json
            asset_data[:purchased] = purchased_asset_ids.include?(asset.id)
            asset_data
          end
          
          render json: assets_with_purchase_info
        else
          render json: all_assets, each_serializer: AssetSerializer
        end
      end

      def show
        render json: @asset, serializer: AssetSerializer
      end

      def create
        asset = current_user.assets.new(asset_params)

        if asset.save
          render json: asset, serializer: AssetSerializer, status: :created
        else
          render json: { errors: asset.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @asset.update(asset_params)
          render json: @asset, serializer: AssetSerializer
        else
          render json: { errors: @asset.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @asset.destroy
        head :no_content
      end

      def bulk_import
        begin
          assets = Asset.bulk_import(current_user, params[:assets])
          render json: assets, each_serializer: AssetSerializer, status: :created
        rescue InvalidJsonError, BulkImportError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end

      private

      def set_asset
        @asset = Asset.find(params[:id])
      end

      def asset_params
        params.require(:asset).permit(:title, :description, :file_url, :price)
      end

      def authorize_creator!
        unless current_user.creator? || current_user.admin?
          render json: { error: 'Only creators can manage assets' }, status: :forbidden
        end
      end
    end
  end
end 