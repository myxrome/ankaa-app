class ApplicationDataSerializer < ActiveModel::Serializer
  has_many :t
  has_many :p

  def t
    object.topics
  end

  def p
    object.partners
  end

end