class CreateLayers < ActiveRecord::Migration[5.0]
  def change
    create_table :layers, id: :uuid, default: 'uuid_generate_v4()', force: true do |t|
      t.integer :provider,          default: 0,     index: true
      t.string  :name,              null: false
      t.string  :color
      t.jsonb   :settings,          default: '{}'
      t.integer :z_index,           default: 0
      t.integer :status,            default: 0,     index: true # status(in process - 0, saved - 1, failed - 2, deleted - 3)
      t.boolean :published,         default: false, index: true

      t.timestamps
    end

    add_index :layers, :settings, using: :gin
  end
end
