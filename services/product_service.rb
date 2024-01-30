require_relative '../repositories/product_repository'

class ProductService
  attr_reader :product_repository

  def initialize(product_repository)
    @product_repository = product_repository
  end

  def save(name:)
    product = Product.new(name:)
    product_repository.save(product)
    product
  end

  def all
    product_repository.all
  end
end
