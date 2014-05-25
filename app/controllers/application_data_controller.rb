class ApplicationDataController < ActionController::Base

  def index
    @topics = Topic.includes(:categories, values: [:promos, descriptions: :description_template]).
        where(key: params[:keys])
    @partners = Partner.all
    @application_data = ApplicationData.new @topics, @partners
    render json: @application_data
  end

end