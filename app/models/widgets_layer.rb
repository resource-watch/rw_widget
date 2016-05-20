# == Schema Information
#
# Table name: widgets_layers
#
#  id         :uuid             not null, primary key
#  widget_id  :uuid
#  layer_id   :uuid
#  main       :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class WidgetsLayer < ApplicationRecord
  belongs_to :layer
  belongs_to :widget

  validates_presence_of :layer
  validates_presence_of :widget

  accepts_nested_attributes_for :layer
end
