require_relative '../models/product'
require_relative '../models/user'
require_relative '../app'
require_relative '../services/product_service'
require_relative '../services/auth_service'
require_relative '../repositories/user_repository'
require_relative '../repositories/product_repository'
require_relative '../security/crypto'
require 'spec_helper'
require 'sequel/core'
require 'database_cleaner-sequel'
require 'rspec'
require 'rack/test'
require 'rspec/json_expectations'

Sequel.extension :migration
DB = Sequel.connect(ENV['DATABASE_URL'])
Sequel::Migrator.apply(DB, 'db/migrate')
DatabaseCleaner[:sequel].db = DB

RSpec.configure do |c|
  c.before(:suite) do
    DatabaseCleaner.allow_remote_database_url = true
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
    DatabaseCleaner.clean_with(:truncation)
  end

  c.after(:suite) do
    DatabaseCleaner.clean
  end

  c.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

describe 'Integration' do
  include Rack::Test::Methods

  let(:prod_service) { ProductService.new(ProductRepository.new(DB)) }
  let(:auth_service) { AuthService.new(UserRepository.new(DB)) }

  def app
    App.new(product_service: prod_service, auth_service:)
  end

  describe 'POST' do
    describe '/products' do
      context 'without JWT token' do
        it 'should throw error' do
          data = { name: 'Orange' }
          post '/products', data.to_json, { 'CONTENT_TYPE' => 'application/json' }

          expect(last_response.status).to eq(401)
          expect(last_response.body).to eq('{"error":"Not authorized, provide valid JWT"}')
        end
      end

      context 'with valid JWT token' do
        let(:email) { 'franco@gmail.com' }
        let(:password) { 's3cure_pa$sword!' }
        let(:token) do
          auth_service.create_user(email:, password:)
          auth_service.create_token(email:, password:)
        end

        it 'should create product' do
          data = { name: 'Orange' }
          header 'Authorization', "Bearer #{token}"
          post '/products', data.to_json, { 'CONTENT_TYPE' => 'application/json' }

          expect(last_response.status).to eq(201)
          expect(last_response.body).to include_json(
            product: {
              id: be_kind_of(Integer),
              name: 'Orange'
            }
          )
        end

        it 'should not create product with empty name' do
          data = { name: '' }
          header 'Authorization', "Bearer #{token}"
          post '/products', data.to_json, { 'CONTENT_TYPE' => 'application/json' }

          expect(last_response.status).to eq(400)
          expect(last_response.body).to eq('{"error":"Validation failed: Name can\'t be blank"}')
        end
      end
    end
  end

  describe 'GET' do
    describe '/products' do
      context 'without JWT token' do
        it 'should throw error' do
          get '/products'
          expect(last_response.status).to eq(401)
          expect(last_response.body).to eq('{"error":"Not authorized, provide valid JWT"}')
        end
      end

      context 'with valid JWT token' do
        let(:email) { 'franco@gmail.com' }
        let(:password) { 's3cure_pa$sword!' }
        let(:token) do
          auth_service.create_user(email:, password:)
          auth_service.create_token(email:, password:)
        end

        it 'should return existing products' do
          prod_service.save(name: 'Big Apple')

          header 'Authorization', "Bearer #{token}"
          get '/products'

          expect(last_response.status).to eq(200)
          body = JSON.parse(last_response.body)
          expect(body).to include_json(
            products: [
              {
                id: be_kind_of(Integer),
                name: 'Big Apple'
              }
            ]
          )
          expect(body['products'].size).to eq(1)
        end
      end
    end
  end

  describe 'POST' do
    let(:email) { 'franco@gmail.com' }
    let(:password) { 's3cure_pa$sword!' }

    describe '/users' do
      it 'should create valid user' do
        data = { email:, password: }
        post '/users', data.to_json, { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(201)
        expect(last_response.body).to include_json(
          user: {
            id: be_kind_of(Integer),
            email:,
            crypted_password: be_kind_of(String)
          }
        )
      end

      it 'should not create user if email already exists' do
        auth_service.create_user(email:, password:)

        data = { email:, password: }
        post '/users', data.to_json, { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(409)
        expect(last_response.body).to eq('{"error":"User already exists!"}')
      end

      it 'should not create user if email is blank' do
        data = { email: '', password: }
        post '/users', data.to_json, { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq('{"error":"Validation failed: Email can\'t be blank"}')
      end

      it 'should not create user if password is blank' do
        data = { email:, password: '' }
        post '/users', data.to_json, { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq('{"error":"Validation failed: Crypted password can\'t be blank"}')
      end

      it 'should not create user if body is invalid' do
        data = 'invalid data'
        post '/users', data, { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq('{"error":"Must provide valid body"}')
      end
    end
  end

  describe 'POST' do
    let(:email) { 'franco@gmail.com' }
    let(:password) { 's3cure_pa$sword!' }

    describe '/auth/token' do
      it 'should create token if valid user exists' do
        auth_service.create_user(email:, password:)

        data = { email:, password: }
        post '/auth/token', data.to_json, { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(201)
        expect(last_response.body).to include_json(
          token: be_kind_of(String)
        )
      end

      it 'should not create token if user does not exist' do
        data = { email:, password: }
        post '/auth/token', data.to_json, { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(401)
        expect(last_response.body).to eq('{"error":"User not found!"}')
      end

      it 'should not create token if user password is incorrect' do
        auth_service.create_user(email:, password:)

        data = { email:, password: 'wrong_pas$word!' }
        post '/auth/token', data.to_json, { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(401)
        expect(last_response.body).to eq('{"error":"Password is incorrect!"}')
      end

      it 'should not create token if missing parameter' do
        data = { password: }
        post '/auth/token', data.to_json, { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq('{"error":"Missing body parameter: email"}')
      end
    end
  end
end
