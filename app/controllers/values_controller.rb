class ValuesController < ApplicationController
  include TopicConcern

  def value
    @values = @topic.values.where(id: params[:ids])
    render json: @values
  end

end