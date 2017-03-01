# frozen_string_literal: true
class WidgetArraySerializer < ActiveModel::Serializer
  attributes :id, :slug, :name, :published, :verified, :template, :default, :dataset_id, :application

  def status
    object.try(:status_txt)
  end
end
