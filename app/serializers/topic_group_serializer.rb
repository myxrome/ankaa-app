class TopicGroupSerializer < ActiveModel::Serializer
  require 'concerns/model_concern'
  include ModelConcern

  attributes :id, :a, :o, :k, :n, :u

  def k
    object.key
  end

  def n
    object.name
  end

end
