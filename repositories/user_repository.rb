require_relative '../models/user'

class UserRepository
  class UserNotFound < StandardError
    def initialize(msg = 'User not found!')
      super
    end
  end

  class UserAlreadyExists < StandardError
    def initialize(msg = 'User already exists!')
      super
    end
  end

  def initialize(db)
    @db = db
  end

  def insert(user)
    if user.valid?
      id = dataset.insert(email: user.email, crypted_password: user.crypted_password)
      user.id = id
    end
    user
  rescue Sequel::UniqueConstraintViolation
    raise UserAlreadyExists
  end

  def find_by_email(email)
    row = dataset.first(email:)
    raise UserNotFound if row.nil?

    load_user(row)
  end

  private

  def dataset
    @db[:users]
  end

  def load_user(row)
    User.new(row[:id], row[:crypted_password], email: row[:email], password: nil)
  end
end
