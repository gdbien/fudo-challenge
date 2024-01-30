require_relative './app'
require_relative './services/product_service'
require_relative './services/auth_service'
require_relative './gateways/products_gateway'
require 'sequel'

DB = Sequel.connect(ENV['DATABASE_URL'])

product_repo = ProductRepository.new(DB)
user_repo = UserRepository.new(DB)

prod_srvce = ProductService.new(product_repo)
auth_srvce = AuthService.new(user_repo)

begin
  ProductsGateway.new.get_products.each do |p|
    product_repo.save(p)
  end
rescue Sequel::Error => e
  p e.message
end

run App.new(product_service: prod_srvce, auth_service: auth_srvce)
