require 'rspec'
require 'rack/test'
require_relative '../../models/product'
require_relative '../../app'
require_relative '../../services/product_service'
require_relative '../../services/auth_service'

describe App do
  include Rack::Test::Methods
  let(:product) { double(Product) }
  let(:product_service) { double(ProductService) }
  let(:auth_service) { double(AuthService) }
  let(:app) { described_class.new(product_service:, auth_service:) }

  describe '/products' do
    it 'should GET all products' do
      products = [Product.new(1, name: 'Orange'), Product.new(2, name: 'Apple')]
      expect(auth_service).to receive(:valid?).and_return(true)
      expect(product_service).to receive(:all).and_return(products)

      header 'Authorization', 'Bearer A_val1d_token'
      get '/products'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('{"products":[{"id":1,"name":"Orange"},{"id":2,"name":"Apple"}]}')
    end

    it 'should POST valid product' do
      data = { name: 'Orange' }
      product = Product.new(1, name: data[:name])
      expect(auth_service).to receive(:valid?).and_return(true)
      expect(product_service).to receive(:save).and_return(product)

      header 'Authorization', 'Bearer A_val1d_token'
      post '/products', data.to_json, { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq('{"product":{"id":1,"name":"Orange"}}')
    end
  end
end
