class PartnerSerializer < ActiveModel::Serializer
  require 'concerns/model_concern'
  include ModelConcern

  attributes :id, :a, :n, :l, :lg, :u

  def n
    object.name
  end

  def l
    object.url
  end

  def lg
    object.logo.url
  end

end