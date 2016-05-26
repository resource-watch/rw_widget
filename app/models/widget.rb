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

class Widget < ApplicationRecord
  STATUS = %w(pending saved failed deleted).freeze

  before_update :assign_slug

  before_validation(on: [:create, :update]) do
    check_slug
  end

  before_save :generate_dataset_id, if: 'query_url_changed? || dataset_id.blank?'

  validates :name, presence: true
  validates :slug, presence: true, format: { with: /\A[^\s!#$%^&*()（）=+;:'"\[\]\{\}|\\\/<>?,]+\z/,
                                             allow_blank: true,
                                             message: 'invalid. Slug must contain at least one letter and no special character' }
  validates_uniqueness_of :name, :slug

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

  def deleted?
    status_txt == 'deleted'
  end

  class << self
    def find_by_id_or_slug(param)
      widget_id = where(slug: param).or(where(id: param)).pluck(:id).min
      find(widget_id) rescue nil
    end

    def fetch_all(options)
      status    = options['status']    if options['status'].present?
      published = options['published'] if options['published'].present?

      widgets = recent

      widgets = case status
                when 'pending'  then widgets.filter_pending
                when 'active'   then widgets.filter_actives
                when 'failed'   then widgets.filter_failed
                when 'disabled' then widgets.filter_inactives
                when 'all'      then widgets
                else
                  published.present? ? widgets : widgets.filter_actives
                end

      widgets = widgets.filter_published   if published.present? && published.include?('true')
      widgets = widgets.filter_unpublished if published.present? && published.include?('false')

      widgets
    end
  end

  private

    def check_slug
      self.slug = self.name.downcase.parameterize if self.name.present? && self.slug.blank?
    end

    def assign_slug
      self.slug = self.slug.downcase.parameterize
    end

    def generate_dataset_id
      self.dataset_id = URI.parse(self.query_url).path.split('/').last if self.query_url.present?
    end
end
