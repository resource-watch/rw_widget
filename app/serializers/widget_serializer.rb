# == Schema Information
#
# Table name: widgets
#
#  id            :uuid             not null, primary key
#  name          :string           not null
#  slug          :string
#  description   :text
#  source        :string
#  source_url    :string
#  authors       :string
#  query_url     :string
#  widget_config :jsonb
#  status        :integer          default(0)
#  published     :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  verified      :boolean          default(FALSE)
#  layer_id      :uuid
#  dataset_id    :uuid
#  template      :boolean          default(FALSE)
#  default       :boolean          default(FALSE)
#  application   :jsonb
#

class WidgetSerializer < ActiveModel::Serializer
  attributes :id, :application, :slug, :name, :description, :source, :source_url, :layer_id, :dataset_id, :authors, :query_url, :widget_config, :meta

  def widget_config
    object.widget_config == '{}' ? nil : object.widget_config
  end

  def meta
    data = {}
    data['status']     = object.try(:status_txt)
    data['published']  = object.try(:published)
    data['verified']   = object.try(:verified)
    data['updated_at'] = object.try(:updated_at)
    data['created_at'] = object.try(:created_at)
    data
  end
end
