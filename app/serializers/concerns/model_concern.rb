module ModelConcern
  extend ActiveSupport::Concern

  def u
    object.updated_at
  end
end