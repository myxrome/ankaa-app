class TopicSerializer < ActiveModel::Serializer
  has_many :values, serializer: ValueShortSerializer
  has_many :categories, serializer: CategoryShortSerializer
end
