# frozen_string_literal: true

module DataProcessingService
  class Sorter
    WEIGHTS = {
      keys_count: 0.4,
      values_richness: 0.6
    }.freeze

    # Initializes the Sorter with datasets.
    #
    # @param datasets [Array<Hash>] The datasets to be sorted.
    def initialize(datasets)
      @datasets = datasets
    end

    # Sorts the datasets based on the number of keys and values richness.
    #
    # @return [Array<Hash>] The sorted datasets.
    def call
      @datasets.sort_by do |data|
        key_count_score = data.keys.size * WEIGHTS[:keys_count]
        values_richness_score = data.values.size * WEIGHTS[:values_richness]

        key_count_score + values_richness_score
      end
    end
  end
end
