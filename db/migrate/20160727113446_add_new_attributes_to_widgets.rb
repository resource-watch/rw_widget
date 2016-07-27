class AddNewAttributesToWidgets < ActiveRecord::Migration[5.0]
  def change
    add_column :widgets, :template, :boolean, default: false
    add_column :widgets, :default, :boolean, default: false
    add_column :widgets, :application, :jsonb, default: []
  end
end
