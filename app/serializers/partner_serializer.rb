class PartnerSerializer < ActiveModel::Serializer
  require 'concerns/model_concern'
  include ModelConcern

  attributes :id, :n, :url, :l, :u

  def n
    object.name
  end

  def l
  object.logo.url
  end

end