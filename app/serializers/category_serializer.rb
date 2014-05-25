class CategorySerializer < ActiveModel::Serializer
  require 'concerns/model_concern'
  include ModelConcern

  attributes :id, :_id, :o, :n, :u

  def _id
    object.topic_id
  end

  def o
    object.order
  end

  def n
    object.displayed_name
  end

end