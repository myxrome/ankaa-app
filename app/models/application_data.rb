class ApplicationData
  include ActiveModel::Serialization
  include ActiveModel::SerializerSupport

  attr_accessor :topics, :partners

  def initialize(topics, partners)
    @topics, @partners = topics, partners
  end

end