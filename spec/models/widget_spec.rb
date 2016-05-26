# == Schema Information
#
# Table name: widgets
#
#  id          :uuid             not null, primary key
#  name        :string           not null
#  slug        :string
#  description :text
#  source      :string
#  source_url  :string
#  authors     :string
#  query_url   :string
#  chart       :jsonb
#  status      :integer          default(0)
#  published   :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  verified    :boolean          default(FALSE)
#  layer_id    :uuid
#  dataset_id  :uuid
#

require 'rails_helper'

RSpec.describe Widget, type: :model do
  let!(:chart) {{"marks": {
                  "type": "rect",
                  "from": {
                    "data": "table"
                  }}}}

  let!(:widgets) {
    widgets = []
    widgets << Widget.create!(name: 'Widget data',     published: true, slug: 'first-test-widget', chart: chart)
    widgets << Widget.create!(name: 'Widget data two', description: 'Lorem ipsum...')
    widgets << Widget.create!(name: 'Widget data one', status: 1)
    widgets.each(&:reload)
  }

  let!(:widget_first)  { widgets[0] }
  let!(:widget_second) { widgets[1] }
  let!(:widget_third)  { widgets[2] }

  it 'Is valid' do
    expect(widget_first).to                be_valid
    expect(widget_first.slug).to           eq('first-test-widget')
    expect(widget_first.chart).to          be_present
  end

  it 'Generate slug after create' do
    expect(widget_third.slug).to eq('widget-data-one')
  end

  it 'Do not allow to create widget without name' do
    widget_reject = Widget.new(name: '', slug: 'test')

    widget_reject.valid?
    expect {widget_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
  end

  it 'Do not allow to create widget with wrong slug' do
    widget_reject = Widget.new(name: 'test', slug: 'test&')

    widget_reject.valid?
    expect {widget_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Slug invalid. Slug must contain at least one letter and no special character")
  end

  it 'Do not allow to create widget with name douplications' do
    expect(widget_first).to be_valid
    widget_reject = Widget.new(name: 'Widget data', slug: 'test')

    widget_reject.valid?
    expect {widget_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name has already been taken")
  end
end
