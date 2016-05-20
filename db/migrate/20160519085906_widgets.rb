class Widgets < ActiveRecord::Migration[5.0]
  def change
    create_table :widgets, id: :uuid, default: 'uuid_generate_v4()', force: true do |t|
      t.string  :name,              null: false
      t.string  :slug
      t.text    :description
      t.string  :source
      t.string  :source_url
      t.string  :authors
      t.string  :query_url
      t.jsonb   :chart,             default: '{}'
      t.integer :status,            default: 0,     index: true # status(in process - 0, saved - 1, failed - 2, deleted - 3)
      t.boolean :published,         default: false, index: true

      t.timestamps
    end

    add_index :widgets, :chart, using: :gin
  end
end
