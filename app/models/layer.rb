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

class Layer < ApplicationRecord
  STATUS   = %w(pending saved failed deleted).freeze
  PROVIDER = %w(CartoDb).freeze

  has_many :widgets_layers
  has_many :widgets, through: :widgets_layers

  validates               :name, presence: true
  validates_uniqueness_of :name

  scope :recent,             -> { order('updated_at DESC')      }
  scope :filter_pending,     -> { where(status: 0)              }
  scope :filter_saved,       -> { where(status: 1)              }
  scope :filter_failed,      -> { where(status: 2)              }
  scope :filter_inactives,   -> { where(status: 3)              }
  scope :filter_published,   -> { where(published: true)        }
  scope :filter_unpublished, -> { where(published: false)       }
  scope :filter_actives,     -> { filter_saved.filter_published }

  def status_txt
    STATUS[status - 0]
  end

  def provider_txt
    PROVIDER[provider - 0]
  end

  def deleted?
    status_txt == 'deleted'
  end
end
