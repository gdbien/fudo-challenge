require 'active_model'

class Product
  include ActiveModel::Validations

  attr_accessor :id, :name

  validates :name, presence: true

  def initialize(id = nil, name:)
    @id = id
    @name = name
    validate!
  end

  def ==(other)
    return super unless other.is_a?(Product)

    id == other.id && name == other.name
  end
end
