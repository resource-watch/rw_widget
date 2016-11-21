# frozen_string_literal: true
class User < ActiveHash::Base
  fields :user_id, :role, :apps

  class << self
    def authorize_user!(user, widget_apps, widget_user_id=nil, match_apps=false)
      user_role     = user.role
      user_apps     = user.apps.sort         if user.apps.present?
      widget_apps  = widget_apps.uniq.sort if widget_apps.present?
      if user_apps.present? && widget_apps.present?
        create_case_a = user_apps.present? && widget_apps.present? && match_apps.blank? &&
                                          (user_apps & widget_apps).any? &&
                                          user_apps.size > widget_apps.size &&
                                          user_apps | widget_apps == user_apps

        create_case_b = user_apps.present? && widget_apps.present? && match_apps.blank? &&
                                          user_apps == widget_apps

        update_case   = user_apps.present? && widget_apps.present? && match_apps.present? &&
                                          (user_apps & widget_apps).any?
      end

      any_apps      = if user_apps.present? && widget_apps.present? && (create_case_a || create_case_b || update_case)
                        true
                      else
                        false
                      end

      user_widget = user.user_id == widget_user_id if widget_user_id.present?

      case user_role
      when 'user' then false
      when 'manager'
        manager_ability(any_apps, user_widget, widget_user_id)
      when 'admin'
        admin_ability(any_apps)
      when 'superadmin'
        true
      else
        false
      end
    end

    def manager_ability(any_apps, user_widget, widget_user_id)
      if any_apps.present? && (user_widget || widget_user_id.blank?)
        true
      else
        false
      end
    end

    def admin_ability(any_apps)
      if any_apps.present?
        true
      else
        false
      end
    end
  end
end
