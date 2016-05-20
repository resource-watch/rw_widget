# == Schema Information
#
# Table name: widgets
#
#  id          :uuid             not null, primary key
#  name        :string           not null
#  slug        :string
#  description :text
#  source      :string
#  source_url  :string
#  authors     :string
#  query_url   :string
#  chart       :jsonb
#  status      :integer          default(0)
#  published   :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class WidgetSerializer < ActiveModel::Serializer
  attributes :id, :slug, :name, :description, :source, :source_url, :authors, :query_url, :chart, :layers, :meta

  def chart
    object.chart == '{}' ? nil : object.chart
  end

  def layers
    object.with_active_layers.map do |layer|
      LayerSerializer.new(layer).serializable_hash
    end
  end

  def meta
    data = {}
    data['status']     = object.try(:status_txt)
    data['published']  = object.try(:published)
    data['updated_at'] = object.try(:updated_at)
    data['created_at'] = object.try(:created_at)
    data
  end

  def include_associations!
    include! :layers, serializer: LayerSerializer
  end
end
