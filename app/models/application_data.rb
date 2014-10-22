class ApplicationData
  include ActiveModel::Serialization
  include ActiveModel::SerializerSupport

  attr_accessor :topic_groups, :topics, :categories, :values, :partners

  def initialize(topic_groups, topics, categories, values, partners)
    @topic_groups, @topics, @categories, @values, @partners =
        topic_groups, topics, categories, values, partners
  end

end