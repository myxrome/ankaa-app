class ApplicationDataSerializer < ActiveModel::Serializer
  has_many :g
  has_many :t
  has_many :c
  has_many :v
  has_many :p

  def self.root_name
    'd'
  end

  def g
    object.topic_groups
  end

  def t
    object.topics
  end

  def c
    object.categories
  end

  def v
    object.values
  end

  def p
    object.values
  end

end