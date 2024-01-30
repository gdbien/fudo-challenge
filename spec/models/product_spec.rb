require 'spec_helper'
require_relative '../../models/product'

describe Product do
  describe 'valid?' do
    it 'should be true when name is not blank' do
      expect(described_class.new(name: 'Naranja')).to be_valid
    end

    it 'should be invalid when name is blank' do
      expect { described_class.new(name: '') }.to raise_error(ActiveModel::ValidationError)
    end
  end
end
