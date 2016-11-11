module V1
  class WidgetsController < ApplicationController
    before_action :set_widget, only: [:show, :update, :destroy]

    def index
      @widgets = Widget.fetch_all(widget_type_filter)
      render json: @widgets, each_serializer: WidgetSerializer, meta: { widgets_count: @widgets.size }
    end

    def show
      render json: @widget, serializer: WidgetSerializer, meta: { status: @widget.try(:status_txt),
                                                                  published: @widget.try(:published),
                                                                  verified: @widget.try(:verified),
                                                                  updated_at: @widget.try(:updated_at),
                                                                  created_at: @widget.try(:created_at) }
    end

    def update
      if @widget.update(widget_params)
        render json: @widget, status: 200, serializer: WidgetSerializer, meta: { status: @widget.try(:status_txt),
                                                                                 published: @widget.try(:published),
                                                                                 verified: @widget.try(:verified),
                                                                                 updated_at: @widget.try(:updated_at),
                                                                                 created_at: @widget.try(:created_at) }
      else
        render json: { success: false, message: @widget.errors }, status: 422
      end
    end

    def create
      @widget = Widget.new(widget_params)
      if @widget.save
        render json: @widget, status: 201, serializer: WidgetSerializer, meta: { status: @widget.try(:status_txt),
                                                                                 published: @widget.try(:published),
                                                                                 verified: @widget.try(:verified),
                                                                                 updated_at: @widget.try(:updated_at),
                                                                                 created_at: @widget.try(:created_at) }
      else
        render json: { success: false, message: @widget.errors }, status: 422
      end
    end

    def destroy
      @widget.destroy
      begin
        render json: { message: 'Widget deleted' }, status: 200
      rescue ActiveRecord::RecordNotDestroyed
        return render json: @widget.erors, message: 'Widget could not be deleted', status: 422
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

      def widget_type_filter
        params.permit(:status, :published, :verified, :app, :template, :dataset, :default, :widget)
      end

      def widget_params
        params.require(:widget).permit!
      end
  end
end
