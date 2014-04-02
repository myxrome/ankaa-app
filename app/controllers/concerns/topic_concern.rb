module TopicConcern
  extend ActiveSupport::Concern
  included do
    before_action :set_topic
  end

  private
  def set_topic
    @topic = Topic.find_by_key params[:key]
  end

end