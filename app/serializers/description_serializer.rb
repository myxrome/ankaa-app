class DescriptionSerializer < ActiveModel::Serializer
  require 'concerns/model_concern'
  include ModelConcern

  attributes :id, :_id, :o, :c, :t, :r, :b, :u

  def _id
    object.value_id
  end

  def o
    object.order
  end

  def c
    object.caption
  end

  def t
    object.text
  end

  def r
    object.red
  end

  def b
    object.bold
  end
end
