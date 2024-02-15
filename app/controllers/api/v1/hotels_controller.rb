# frozen_string_literal: true

module Api
  module V1
    class HotelsController < ApplicationController
      rescue_from StandardError, with: :render_error

      def index
        hotel_info = DataDeliveryService::InformationAggregator.new(index_params).call

        render json: hotel_info
      end

      private

      def index_params
        params.permit(:destination_id, hotel_ids: [])
      end

      def render_error(exception)
        render json: { error: exception.message }, status: :internal_server_error
      end
    end
  end
end
