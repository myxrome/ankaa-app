class PromoSerializer < ActiveModel::Serializer
  require 'concerns/model_concern'
  include ModelConcern

  attributes :id, :_id, :o, :x, :h, :m, :l, :u

  def _id
    object.value_id
  end

  def o
    object.order
  end

  def x
  object.image.url(:xhdpi)
  end

  def h
  object.image.url(:hdpi)
  end

  def m
  object.image.url(:mdpi)
  end

  def l
  object.image.url(:ldpi)
  end
end
