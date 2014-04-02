class DescriptionSerializer < ActiveModel::Serializer
  attributes :value_id, :id, :order, :caption, :text, :red, :bold, :updated_at
end
