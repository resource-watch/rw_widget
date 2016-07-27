class RenameChartToWidgetConfig < ActiveRecord::Migration[5.0]
  def change
    rename_column :widgets, :chart, :widget_config
  end
end
