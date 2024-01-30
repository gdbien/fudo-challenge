require 'spec_helper'
require 'sequel/core'
require_relative '../../repositories/user_repository'
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

describe UserRepository do
  let(:repository) { described_class.new(db) }
  let(:email) { 'franco@gmail.com' }
  let(:password) { 'a_s3cure_p4ssw0rd' }
  describe 'insert' do
    it 'should create user if it does not exist' do
      user = User.new(email:, password:)

      expect(user.id).to eq(nil)
      expect(repository.insert(user)).to eq(user)
      expect(user.id).to eq(1)
    end

    it 'should throw error if already exists' do
      user = User.new(email:, password:)
      repository.insert(user)

      expect { repository.insert(user) }.to raise_error(UserRepository::UserAlreadyExists)
    end

    it 'should not create user if it is invalid' do
      user = User.new(email:, password:)
      user.email = ''

      repository.insert(user)
      expect(user.id).to eq(nil)
      expect { repository.find_by_email(email) }.to raise_error(UserRepository::UserNotFound)
    end
  end

  describe 'find_by_email' do
    it 'should return user if it exists' do
      user = User.new(email:, password:)
      repository.insert(user)

      expect(repository.find_by_email(email).email).to eq(user.email)
    end

    it 'should throw error if it does not exist' do
      expect { repository.find_by_email(email) }.to raise_error(UserRepository::UserNotFound)
    end
  end
end
