module V1
  class WidgetsController < ApplicationController
    before_action :basic_auth, only: [:update, :create, :destroy]
    before_action :set_widget, only: [:show, :update, :destroy]

    def index
      @widgets = Widget.fetch_all(widget_type_filter)
      render json: @widgets, each_serializer: WidgetArraySerializer, root: false
    end

    def show
      render json: @widget, serializer: WidgetSerializer, root: false
    end

    def update
      if @widget.update(widget_params)
        render json: @widget, status: 200, serializer: WidgetSerializer, root: false
      else
        render json: { success: false, message: @widget.errors }, status: 422
      end
    end

    def create
      @widget = Widget.new(widget_params)
      if @widget.save
        render json: @widget, status: 201, serializer: WidgetSerializer, root: false
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

    private

      def set_widget
        @widget = Widget.find_by_id_or_slug(params[:id])
      end

      def widget_type_filter
        params.permit(:status, :published, :verified)
      end

      def widget_params
        params.require(:widget).permit!
      end
  end
end
