class PartnerSerializer < ActiveModel::Serializer
  attributes :id, :name, :url, :logo, :updated_at

  def logo
    object.logo.url
  end

end