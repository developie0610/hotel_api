# frozen_string_literal: true

module DataDeliveryService
  class InformationAggregator
    # Initializes a new InformationAggregator object.
    #
    # @param params [Hash] The parameters for filtering the datasets.
    # @param datasets [Array] The datasets to be processed.
    def initialize(params, datasets = [])
      @params = params
      @datasets = datasets.present? ? datasets : fetch_live_data
    end

    # Aggregates and processes the datasets based on the provided parameters.
    #
    # @return [Array] The processed data.
    def call
      return [] if @datasets.empty?

      filter_data.values.map { |data| DataProcessingService::Merger.new(data).call }
    end

    private

    def fetch_live_data
      DataProcuringService::Fetcher.fetch_normalized.flatten
    end

    def filter_data
      Filter.new(@params, @datasets).call
    end
  end
end
