class CreateDigitalAssetsSchema < ActiveRecord::Migration[8.0]
  def change
    execute "CREATE SCHEMA IF NOT EXISTS digital_assets"
  end
end 