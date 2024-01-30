require 'spec_helper'
require_relative '../../models/user'

describe User do
  let(:email) { 'franco@gmail.com' }
  let(:password) { 'a_s3cure_p4ssw0rd' }

  describe 'valid?' do
    it 'should be true when email and password are not blank' do
      expect(described_class.new(email:, password:)).to be_valid
    end

    it 'should be invalid when email is blank' do
      expect { described_class.new(email: '', password:) }.to raise_error(ActiveModel::ValidationError)
    end

    it 'should be invalid when password is blank' do
      expect { described_class.new(email:, password: '') }.to raise_error(ActiveModel::ValidationError)
    end
  end

  describe 'password?' do
    it 'should be true when password is the same' do
      user = described_class.new(email:, password:)
      expect(user.password?(password)).to be true
    end

    it 'should be false when password is different' do
      user = described_class.new(email:, password:)
      expect(user.password?('wrong_password')).to be false
    end
  end
end
