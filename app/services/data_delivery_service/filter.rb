# frozen_string_literal: true

module DataDeliveryService
  class Filter
    # Initializes a new Filter object.
    #
    # @param params [Hash] The parameters for filtering the datasets.
    # @param datasets [Array] The datasets to be filtered.
    def initialize(params, datasets)
      @params = params
      @datasets = datasets
    end

    # Filters the datasets based on the provided parameters.
    #
    # @return [Hash] The filtered datasets.
    def call
      hotel_ids ? filter_by_hotel_ids : filter_by_destination_id
    end

    private

    attr_reader :params, :datasets

    def hotel_ids
      @params[:hotels]
    end

    def destination_id
      @params[:destination]
    end

    def filter_by_hotel_ids
      datasets.group_by { |data| data[:id] }.slice(*hotel_ids)
    end

    def filter_by_destination_id
      datasets.group_by { |data| data[:destination_id] }[destination_id.to_i]&.group_by { |data| data[:id] }.to_h
    end
  end
end
