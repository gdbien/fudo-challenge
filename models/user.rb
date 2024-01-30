require 'active_model'
require_relative '../security/crypto'

class User
  include ActiveModel::Validations

  attr_accessor :id, :email, :crypted_password

  validates :email, :crypted_password, presence: true

  def initialize(id = nil, crypted_password = nil, email:, password:)
    @id = id
    @email = email
    @crypted_password = if crypted_password.nil?
                          Crypto.encrypt(password)
                        else
                          crypted_password
                        end
    validate!
  end

  def password?(password)
    Crypto.decrypt(crypted_password) == password
  end
end
