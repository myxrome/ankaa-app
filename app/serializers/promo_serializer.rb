class PromoSerializer < ActiveModel::Serializer
  attributes :value_id, :id, :order, :xhdpi, :hdpi, :mdpi, :ldpi, :updated_at

  def xhdpi
    object.image.url(:xhdpi)
  end

  def hdpi
    object.image.url(:hdpi)
  end

  def mdpi
    object.image.url(:mdpi)
  end

  def ldpi
    object.image.url(:ldpi)
  end
end
