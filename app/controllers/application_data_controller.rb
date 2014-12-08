class ApplicationDataController < ActionController::Base

  def index
    @topic_groups = TopicGroup.where(key: params[:k], active: true)
    @topics = Topic.where(topic_group: @topic_groups, active: true)
    @categories = Category.where(topic: @topics, active: true)
    @values = Value.eager_load([:promos, descriptions: :description_template]).where(category: @categories, active: true)
    @partners = Partner.all

    @application_data = ApplicationData.new filter_by_updated_at(@topic_groups),
                                            filter_by_updated_at(@topics),
                                            filter_by_updated_at(@categories),
                                            filter_by_updated_at(@values),
                                            filter_by_updated_at(@partners)
    render json: Oj.dump(ApplicationDataSerializer.new(@application_data), mode: :compat)
  end

  private
  def filter_by_updated_at(collection)
    collection.select { |o| o.updated_at > params[:u] }
  end

end