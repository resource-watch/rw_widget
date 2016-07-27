class WidgetArraySerializer < ActiveModel::Serializer
  attributes :id, :slug, :name, :status, :published, :verified, :template, :default, :dataset_id, :application

  def status
    object.try(:status_txt)
  end
end
