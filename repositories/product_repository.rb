require_relative '../models/product'

class ProductRepository
  def initialize(db)
    @db = db
  end

  def save(product)
    return false unless product.valid?

    @db.transaction do
      if dataset.first(id: product.id)
        update(product).positive?
      else
        !insert(product).id.nil?
      end
    end
  end

  def all
    dataset.all.map { |row| load_product(row) }
  end

  private

  def dataset
    @db[:products]
  end

  def load_product(row)
    Product.new(row[:id], name: row[:name])
  end

  def update(product)
    return 0 unless product.valid?

    dataset.where(id: product.id).update(name: product.name)
  end

  def insert(product)
    if product.valid?
      id = dataset.insert(name: product.name)
      product.id = id
    end
    product
  end
end
