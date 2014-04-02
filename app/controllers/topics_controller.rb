class TopicsController < ApplicationController
  include TopicConcern

  def index
    render json: @topic
  end

end
