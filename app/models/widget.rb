# frozen_string_literal: true
# == Schema Information
#
# Table name: widgets
#
#  id            :uuid             not null, primary key
#  name          :string           not null
#  slug          :string
#  description   :text
#  source        :string
#  source_url    :string
#  authors       :string
#  query_url     :string
#  widget_config :jsonb
#  status        :integer          default(0)
#  published     :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  verified      :boolean          default(FALSE)
#  layer_id      :uuid
#  dataset_id    :uuid
#  template      :boolean          default(FALSE)
#  default       :boolean          default(FALSE)
#  application   :jsonb
#  user_id       :string
#

class Widget < ApplicationRecord
  STATUS = %w(pending saved failed deleted).freeze

  before_save   :merge_apps, if: 'application_changed?'
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
  scope :filter_verified,    -> { where(verified: true)         }
  scope :filter_unverified,  -> { where(verified: false)        }
  scope :filter_template,    -> { where(template: true)         }
  scope :notfilter_template, -> { where(template: false)        }
  scope :filter_default,     -> { where(default: true)          }
  scope :notfilter_default,  -> { where(default: false)         }
  scope :filter_actives,     -> { filter_saved.filter_published }

  scope :filter_app,      ->(app)     { where('application ?| array[:keys]', keys: app) }
  scope :filter_dataset,  ->(dataset) { where(dataset_id: dataset)                      }

  def status_txt
    STATUS[status - 0]
  end

  def deleted?
    status_txt == 'deleted'
  end

  class << self
    def set_by_id_or_slug(param)
      widget_id = where(slug: param).or(where(id: param)).pluck(:id).min
      find(widget_id) rescue nil
    end

    def fetch_all(options)
      status    = options['status'].downcase if options['status'].present?
      published = options['published']       if options['published'].present?
      verified  = options['verified']        if options['verified'].present?
      apps       = options['app'].downcase    if options['app'].present?
      template  = options['template']        if options['template'].present?
      dataset   = options['dataset']         if options['dataset'].present?
      default   = options['default']         if options['default'].present?

      widgets = all
      widgets = widgets.filter_dataset(dataset) if dataset.present?

      widgets = case status
                when 'pending'  then widgets.filter_pending
                when 'active'   then widgets.filter_actives
                when 'failed'   then widgets.filter_failed
                when 'disabled' then widgets.filter_inactives
                when 'all'      then widgets
                else
                  published.present? || verified.present? ? widgets : widgets.filter_actives
                end

      widgets = widgets.filter_published   if published.present? && published.include?('true')
      widgets = widgets.filter_unpublished if published.present? && published.include?('false')
      widgets = widgets.filter_verified    if verified.present?  && verified.include?('true')
      widgets = widgets.filter_unverified  if verified.present?  && verified.include?('false')
      widgets = app_filter(widgets, apps)  if apps.present?
      widgets = widgets.filter_template    if template.present?  && template.include?('true')
      widgets = widgets.notfilter_template if template.present?  && template.include?('false')
      widgets = widgets.filter_default     if default.present?   && default.include?('true')
      widgets = widgets.notfilter_default  if default.present?   && default.include?('false')

      widgets
    end

    def fetch_by_datasets(options)
      ids  = options['ids']                 if options['ids'].present?
      apps = options['app'].map(&:downcase) if options['app'].present?

      widgets = recent
      widgets = widgets.filter_actives
      widgets = widgets.filter_dataset(ids) if ids.present?
      widgets = app_filter(widgets, apps)    if apps.present?
      widgets
    end

    def app_filter(scope, apps)
      apps    = apps.is_a?(Array) ? apps : apps.split(',')
      widgets = scope
      widgets = if apps.present? && !apps.include?('all')
                  widgets.filter_app(apps)
                else
                  widgets
                end
      widgets
    end
  end

  private

    def merge_apps
      self.application = self.application.each { |a| a.downcase! }.uniq
    end

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
