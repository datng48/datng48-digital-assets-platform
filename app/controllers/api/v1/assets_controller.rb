module Api
  module V1
    class AssetsController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show]
      before_action :set_asset, only: [:show, :update, :destroy]
      before_action :ensure_creator!, only: [:create, :bulk_import]
      before_action :ensure_owner!, only: [:update, :destroy]

      def index
        assets = Asset.includes(:user)
        render json: assets, each_serializer: AssetSerializer
      end

      def show
        render json: @asset, serializer: AssetSerializer
      end

      def create
        asset = current_user.assets.build(asset_params)

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

      def ensure_creator!
        unless current_user.creator?
          render json: { error: 'Only creators can perform this action' }, status: :forbidden
        end
      end

      def ensure_owner!
        unless @asset.user_id == current_user&.id
          render json: { error: 'You can only modify your own assets' }, status: :forbidden
        end
      end
    end
  end
end 