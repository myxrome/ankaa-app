class ValueSerializer < ActiveModel::Serializer
  attributes :id, :category_id, :name, :thumb, :old_price, :new_price, :discount, :url, :end_date
  has_many :descriptions
  has_many :promos
end
