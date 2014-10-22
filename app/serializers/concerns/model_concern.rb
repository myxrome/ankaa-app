module ModelConcern
  extend ActiveSupport::Concern

  def u
    object.updated_at
  end

  def a
    object.active
  end

  def o
    object.order
  end

end