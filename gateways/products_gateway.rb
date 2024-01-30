require 'faraday'
require_relative '../models/product'

class ProductsGateway
  BASE_URL = 'https://23f0013223494503b54c61e8bee1190c.api.mockbin.io'.freeze

  def initialize(conn = nil)
    @conn = conn || Faraday.new(
      url: BASE_URL
    )
  end

  def get_products # rubocop:disable Naming/AccessorMethodName
    res = @conn.post do |req|
      req.headers['Content-Type'] = 'application/json'
    end
    return [] unless res.success?

    body = JSON.parse res.body
    products = body.fetch('data', [])
    parse_products products
  rescue JSON::ParserError
    []
  end

  private

  def parse_products(products)
    products.map do |p|
      Product.new(p['id'], name: p['name'])
    rescue ActiveModel::ValidationError
      nil
    end.compact
  end
end
