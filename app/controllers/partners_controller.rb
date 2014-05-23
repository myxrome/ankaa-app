class PartnersController < ApplicationController
  before_action :set_partners

  def index
    render json: @partners
  end

  def urls
    render json: @partners, each_serializer: PartnerUrlSerializer
  end

  def set_partners
    @partners = Partner.all
  end

end