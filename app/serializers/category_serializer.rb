class CategorySerializer < ActiveModel::Serializer
  attributes :id, :topic_id, :order, :name

  def name
    object.displayed_name
  end

end