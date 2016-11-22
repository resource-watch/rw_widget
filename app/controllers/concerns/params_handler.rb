# frozen_string_literal: true
module ParamsHandler
  extend ActiveSupport::Concern

  included do
    def widget_params_sanitizer
      params.require(:widget).merge(logged_user: params[:logged_user], user_id: params.dig(:logged_user, :id))
                             .permit!
                             .reject{ |_, v| v.nil? }
    end
  end

  class_methods {}
end
