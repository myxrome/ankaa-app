class TopicSerializer < ActiveModel::Serializer
  attributes :id, :name, :updated_at

  has_many :values, serializer: ValueShortSerializer
  has_many :categories, serializer: CategoryShortSerializer
end
