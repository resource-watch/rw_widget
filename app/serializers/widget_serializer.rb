# frozen_string_literal: true
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
  attributes :id, :application, :slug, :name, :description, :source, :sourceUrl, :layerId, :dataset, :authors, :queryUrl, :widgetConfig, :template, :default,
             :status, :published, :verified

  def status
    object.try(:status_txt)
  end

  def sourceUrl
    object.try(:source_url)
  end

  def layerId
    object.try(:layer_id)
  end

  def dataset
    object.try(:dataset_id)
  end

  def queryUrl
    object.try(:query_url)
  end

  def widgetConfig
    object.widget_config == '{}' ? nil : object.widget_config
  end
end
