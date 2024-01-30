require_relative '../repositories/user_repository'
require 'jwt'

class AuthService
  HMAC_SECRET = '264ef30672797113c54ad1eec882f3c8'.freeze
  EXP_TIME = 15 * 60
  AUTH_TYPE = 'Bearer '.freeze

  class IncorrectPassword < StandardError
    def initialize(msg = 'Password is incorrect!')
      super
    end
  end

  attr_reader :user_repository

  def initialize(user_repository)
    @user_repository = user_repository
  end

  def create_user(email:, password:)
    user = User.new(email:, password:)
    user_repository.insert(user)
  end

  def create_token(email:, password:)
    user = user_repository.find_by_email(email)

    raise IncorrectPassword unless user.password?(password)

    exp = Time.now.to_i + EXP_TIME
    payload = { data: { user: { id: user.id, email: user.email } }, exp: }
    JWT.encode payload, HMAC_SECRET, 'HS256'
  end

  def valid?(token)
    return false unless token.start_with?(AUTH_TYPE)

    begin
      JWT.decode token.delete_prefix(AUTH_TYPE), HMAC_SECRET, true, { algorithm: 'HS256' }
    rescue JWT::DecodeError
      return false
    end
    true
  end
end
