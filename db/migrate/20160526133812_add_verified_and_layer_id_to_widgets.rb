class AddVerifiedAndLayerIdToWidgets < ActiveRecord::Migration[5.0]
  def change
    add_column :widgets, :verified,   :boolean, default: false, index: true
    add_column :widgets, :layer_id,   :uuid
    add_column :widgets, :dataset_id, :uuid
  end
end
