require 'bcrypt'

class Crypto
  def self.encrypt(password)
    BCrypt::Password.create(password) unless password.empty?
  end

  def self.decrypt(password)
    BCrypt::Password.new(password)
  end
end
