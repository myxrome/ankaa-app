class CategoriesController < ApplicationController
  include TopicConcern

  def category
    @categories = @topic.categories.where(id: params[:ids])
    render json: @categories
  end

end