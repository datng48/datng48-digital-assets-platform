# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create admin user
admin = User.find_or_initialize_by(email: 'admin@digitalassets.com')
admin.assign_attributes(
  password: 'admin123',  # You should change this in production
  name: 'System Admin',
  role: 'admin'
)
admin.save!

puts "Admin user created with email: admin@digitalassets.com and password: admin123"
