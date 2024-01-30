require 'sinatra/base'
require 'json'
require_relative 'helpers/utils'

class App < Sinatra::Base
  attr_reader :product_service, :auth_service

  def initialize(product_service:, auth_service:)
    super
    @product_service = product_service
    @auth_service = auth_service
  end

  helpers do
    def protected!
      return if authorized?

      headers['WWW-Authenticate'] = 'Bearer realm="Restricted Area"'
      halt 401, { error: 'Not authorized, provide valid JWT' }.to_json
    end

    def authorized?
      token = request.env['HTTP_AUTHORIZATION']
      return false if token.nil?

      auth_service.valid?(token)
    end
  end

  post '/users' do
    body = parse_body(request, %w[email password])
    email = body['email']
    password = body['password']
    user = auth_service.create_user(email:, password:)
    status 201
    { user: { id: user.id, email: user.email, crypted_password: user.crypted_password } }.to_json
  rescue UserRepository::UserAlreadyExists => e
    status 409
    error_to_json(e)
  rescue StandardError => e
    status 400
    error_to_json(e)
  end

  post '/auth/token' do
    body = parse_body(request, %w[email password])
    email = body['email']
    password = body['password']
    token = auth_service.create_token(email:, password:)
    status 201
    { token: }.to_json
  rescue AuthService::IncorrectPassword, UserRepository::UserNotFound => e
    status 401
    error_to_json(e)
  rescue StandardError => e
    status 400
    error_to_json(e)
  end

  post '/products' do
    protected!
    body = parse_body(request, ['name'])
    name = body['name']
    product = product_service.save(name:)
    status 201
    { product: { id: product.id, name: product.name } }.to_json
  rescue StandardError => e
    status 400
    error_to_json(e)
  end

  get '/products' do
    protected!
    status 200
    products = product_service.all.map do |product|
      { id: product.id, name: product.name }
    end
    { products: }.to_json
  end
end
