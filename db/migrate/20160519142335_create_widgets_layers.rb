class CreateWidgetsLayers < ActiveRecord::Migration[5.0]
  def change
    create_table :widgets_layers, id: :uuid do |t|
      t.uuid    :widget_id, index: true
      t.uuid    :layer_id,  index: true
      t.boolean :main,      default: false

      t.timestamps
    end
  end
end
