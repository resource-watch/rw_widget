# frozen_string_literal: true
module V1
  class WidgetsController < ApplicationController
    include ParamsHandler

    before_action :set_widget, only: [:show, :update, :destroy]
    before_action :set_user,   except: [:index, :show, :by_datasets]
    before_action :set_caller, only: :update

    def index
      @widgets = Widget.fetch_all(widget_type_filter)
      render json: @widgets, each_serializer: WidgetSerializer, meta: { widgets_count: @widgets.size }
    end

    def by_datasets
      @widgets = Widget.fetch_by_datasets(widget_datasets_filter)
      render json: @widgets, each_serializer: WidgetSerializer, meta: { widgetsCount: @widgets.size }
    end

    def show
      render json: @widget, serializer: WidgetSerializer, meta: { status: @widget.try(:status_txt),
                                                                  published: @widget.try(:published),
                                                                  verified: @widget.try(:verified),
                                                                  updated_at: @widget.try(:updated_at),
                                                                  created_at: @widget.try(:created_at) }
    end

    def update
      if @authorized.present?
        if @widget.update(@widget_params)
          render json: @widget, status: 200, serializer: WidgetSerializer, meta: { status: @widget.try(:status_txt),
                                                                                   published: @widget.try(:published),
                                                                                   verified: @widget.try(:verified),
                                                                                   updated_at: @widget.try(:updated_at),
                                                                                   created_at: @widget.try(:created_at) }
        else
          render json: { success: false, message: @widget.errors.full_messages }, status: 422
        end
      else
        render json: { errors: [{ status: 401, title: 'Not authorized!' }] }, status: 401
      end
    end

    def create
      authorized = User.authorize_user!(@user, @widget_apps)
      if authorized.present?
        @widget = Widget.new(widget_params.except(:logged_user))
        if @widget.save
          render json: @widget, status: 201, serializer: WidgetSerializer, meta: { status: @widget.try(:status_txt),
                                                                                   published: @widget.try(:published),
                                                                                   verified: @widget.try(:verified),
                                                                                   updated_at: @widget.try(:updated_at),
                                                                                   created_at: @widget.try(:created_at) }
        else
          render json: { success: false, message: @widget.errors.full_messages }, status: 422
        end
      else
        render json: { errors: [{ status: 401, title: 'Not authorized!' }] }, status: 401
      end
    end

    def destroy
      authorized = User.authorize_user!(@user, intersect_apps(@widget.application, @apps), @widget.user_id, match_apps: true)
      if authorized.present?
        if @widget.destroy
          render json: { success: true, message: 'Widget deleted' }, status: 200
        else
          return render json: @widget.erors, message: 'Widget could not be deleted', status: 422
        end
      else
        render json: { errors: [{ status: 401, title: 'Not authorized!' }] }, status: 401
      end
    end

    def docs
      @docs = YAML.load(File.read('lib/files/swagger.yml')).to_json
      render json: @docs
    end

    def info
      @service = ServiceSetting.save_gateway_settings(params)
      if @service
        @docs = Oj.load(File.read("lib/files/service_#{ENV['RAILS_ENV']}.json"))
        render json: @docs
      else
        render json: { success: false, message: 'Missing url and token params' }, status: 422
      end
    end

    private

      def set_widget
        @widget = Widget.set_by_id_or_slug(params[:id])
        record_not_found if @widget.blank?
      end

      def intersect_apps(widget_apps, user_apps, additional_apps=nil)
        if additional_apps.present?
          if (widget_apps | additional_apps).uniq.sort == (user_apps & (widget_apps | additional_apps)).uniq.sort
            widget_apps | additional_apps
          else
            ['apps_not_authorized'] if widget_params[:logged_user][:id] != 'microservice'
          end
        else
          widget_apps
        end
      end

      def set_user
        if ENV.key?('OLD_GATEWAY') && ENV.fetch('OLD_GATEWAY').include?('true')
          User.data = [{ user_id: '123-123-123', role: 'superadmin', apps: nil }]
          @user= User.last
        elsif params[:logged_user].present? && params[:logged_user][:id] != 'microservice'
          user_id       = params[:logged_user][:id]
          @role         = params[:logged_user][:role].downcase
          @apps         = if params[:logged_user][:extra_user_data].present? && params[:logged_user][:extra_user_data][:apps].present?
                            params[:logged_user][:extra_user_data][:apps].map { |v| v.downcase }.uniq
                          end
          @widget_apps  = if action_name != 'destroy' && widget_params[:application].present?
                            widget_params[:application]
                          end

          User.data = [{ user_id: user_id, role: @role, apps: @apps }]
          @user= User.last
        else
          render json: { errors: [{ status: 401, title: 'Not authorized!' }] }, status: 401 if params[:logged_user][:id] != 'microservice'
        end
      end

      def set_caller
        if widget_params[:logged_user].present? && widget_params[:logged_user][:id] == 'microservice'
          @widget_params = widget_params.except(:user_id, :logged_user)
          @authorized = true
        else
          @widget_params = widget_params.except(:logged_user)
          @authorized = User.authorize_user!(@user, intersect_apps(@widget.application, @apps, @widget_apps), @widget.user_id, match_apps: true)
        end
      end

      def widget_type_filter
        params.permit(:status, :published, :verified, :app, :template, :dataset, :default, :widget)
      end

      def widget_datasets_filter
        params.require(:widget).permit(ids: [], app: [])
      end

      def widget_params
        widget_params_sanitizer
      end
  end
end
