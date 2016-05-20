# == Schema Information
#
# Table name: layers
#
#  id         :uuid             not null, primary key
#  provider   :integer          default(0)
#  name       :string           not null
#  color      :string
#  settings   :jsonb
#  z_index    :integer          default(0)
#  status     :integer          default(0)
#  published  :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Layer, type: :model do
  let!(:settings) {{"marks": {
                  "type": "rect",
                  "from": {
                    "data": "table"
                  }}}}

  let!(:layers) {
    layers = []
    layers << Layer.create!(name: 'Layer data',     published: true, settings: settings)
    layers << Layer.create!(name: 'Layer data two', color: '#333333')
    layers << Layer.create!(name: 'Layer data one', status: 1)
    layers.each(&:reload)
  }

  let!(:layer_first)  { layers[0] }
  let!(:layer_second) { layers[1] }
  let!(:layer_third)  { layers[2] }

  it 'Is valid' do
    expect(layer_first).to          be_valid
    expect(layer_first.settings).to be_present
  end

  it 'Do not allow to create layer without name' do
    layer_reject = Layer.new(name: '')

    layer_reject.valid?
    expect {layer_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
  end

  it 'Do not allow to create layer with name douplications' do
    expect(layer_first).to be_valid
    layer_reject = Layer.new(name: 'Layer data')

    layer_reject.valid?
    expect {layer_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name has already been taken")
  end
end
