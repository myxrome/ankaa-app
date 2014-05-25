class TopicSerializer < ActiveModel::Serializer
  require 'concerns/model_concern'
  include ModelConcern

  attributes :id, :k, :n, :u
  has_many :v
  has_many :c

  def k
    object.key
  end

  def n
    object.name
  end

  def v
    object.values
  end

  def c
    object.categories
  end

end
