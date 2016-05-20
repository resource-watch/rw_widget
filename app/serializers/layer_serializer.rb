# == Schema Information
#
# Table name: layers
#
#  id         :uuid             not null, primary key
#  provider   :integer          default(0)
#  name       :string           not null
#  color      :string
#  settings   :jsonb
#  z_index    :integer          default(0)
#  status     :integer          default(0)
#  published  :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class LayerSerializer < ActiveModel::Serializer
  attributes :id, :provider, :name, :color, :z_index, :status, :published, :settings

  def provider
    object.try(:provider_txt)
  end

  def status
    object.try(:status_txt)
  end

  def settings
    object.settings == '{}' ? nil : object.settings
  end
end
