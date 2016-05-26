class RemoveLayers < ActiveRecord::Migration[5.0]
  def change
    drop_table :widgets_layers
    drop_table :layers
  end
end
