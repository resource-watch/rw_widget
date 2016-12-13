class AddUserToWidgets < ActiveRecord::Migration[5.0]
  def change
    add_column :widgets, :user_id, :string, index: true
  end
end
