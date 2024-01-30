require_relative '../../gateways/products_gateway'

describe ProductsGateway do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:conn) { Faraday.new { |b| b.adapter(:test, stubs) } }
  let(:client) { described_class.new(conn) }

  after do
    Faraday.default_connection = nil
  end

  describe 'get_products' do
    context 'when api is working'
    it 'should return products' do
      stubs.post('/') do
        [
          200,
          { 'Content-Type': 'application/json' },
          '{"data":[{"id":1,"name":"Apple"},{"id":2,"name":"Banana"}]}'
        ]
      end
      products = client.get_products
      expect(products).to eq([Product.new(1, name: 'Apple'), Product.new(2, name: 'Banana')])
      stubs.verify_stubbed_calls
    end

    it 'should not return products if they dont exist' do
      stubs.post('/') do
        [
          200,
          { 'Content-Type': 'application/json' },
          '{"data":[]}'
        ]
      end
      products = client.get_products
      expect(products).to eq([])
      stubs.verify_stubbed_calls
    end

    it 'should return only valid products' do
      stubs.post('/') do
        [
          200,
          { 'Content-Type': 'application/json' },
          '{"data":[{"id":1,"name":"Apple"},{"id":2,"name":""}]}'
        ]
      end
      products = client.get_products
      expect(products).to eq([Product.new(1, name: 'Apple')])
      stubs.verify_stubbed_calls
    end
  end

  context 'when api is not working' do
    it 'should not return products' do
      stubs.post('/') do
        [
          500
        ]
      end
      products = client.get_products
      expect(products).to eq([])
      stubs.verify_stubbed_calls
    end
  end
end
