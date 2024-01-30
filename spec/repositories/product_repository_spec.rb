require 'spec_helper'
require 'sequel/core'
require_relative '../../repositories/product_repository'
require 'sqlite3'
require 'sequel'

Sequel.extension :migration
db = Sequel.sqlite
Sequel::Migrator.apply(db, 'db/migrate')

RSpec.configure do |c|
  c.around(:each) do |example|
    db.transaction(rollback: :always, auto_savepoint: true) { example.run }
  end
end

describe ProductRepository do
  let(:repository) { described_class.new(db) }

  describe 'save' do
    it 'should update the id if it doesnt exist' do
      product = Product.new(name: 'Orange')

      expect(product.id).to eq(nil)
      expect(repository.save(product)).to eq(true)
      expect(product.id).to eq(1)
    end

    it 'should update the name and not the id if it does exist' do
      product = Product.new(name: 'Orange')

      repository.save(product)
      old_id = product.id

      product.name = 'Apple'

      expect(repository.save(product)).to eq(true)
      expect(old_id).to eq(product.id)
    end

    it 'should not update the id if name is invalid' do
      product = Product.new(name: 'Orange')
      product.name = ''

      expect(repository.save(product)).to eq(false)
      expect(product.id).to eq(nil)
    end
  end

  describe 'all' do
    it 'should return empty array when no products exist' do
      expect(repository.all).to eq([])
    end

    it 'should return existent products' do
      products = [Product.new(name: 'Orange'),
                  Product.new(name: 'Apple')]
      products.each { |product| repository.save(product) }

      expect(products).to match_array(repository.all)
    end
  end
end
