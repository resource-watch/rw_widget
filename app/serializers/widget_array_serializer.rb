class WidgetArraySerializer < ActiveModel::Serializer
  attributes :id, :slug, :name, :status, :published, :verified

  def status
    object.try(:status_txt)
  end
end
