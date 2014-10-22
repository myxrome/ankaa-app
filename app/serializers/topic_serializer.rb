class TopicSerializer < ActiveModel::Serializer
  require 'concerns/model_concern'
  include ModelConcern

  attributes :id, :_id, :a, :o, :n, :u

  def _id
    object.topic_group_id
  end

  def n
    object.displayed_name
  end

end
