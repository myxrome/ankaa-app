class ValueSerializer < ActiveModel::Serializer
  require 'concerns/model_concern'
  include ModelConcern

  attributes :id, :_id, :n, :t, :op, :np, :ds,
             :url, :e, :u
  has_many :d
  has_many :p

  def _id
    object.category_id
  end

  def n
    object.name
  end

  def t
    object.thumb
  end

  def op
    object.old_price
  end

  def np
    object.new_price
  end

  def ds
    object.discount
  end

  def e
    object.end_date
  end

  def d
    object.descriptions
  end

  def p
    object.promos
  end
end
