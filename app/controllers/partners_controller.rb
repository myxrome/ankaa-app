class PartnersController < ApplicationController

  def index
    @partners = Partner.all
    render json: @partners
  end

end