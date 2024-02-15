# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataProcessingService::Sorter do
  describe '#call' do
    let(:datasets) do
      [
        { id: 1, name: 'Hotel A', destination_id: 100, addkey1: 1, addkey2: 2, addkey3: 3 },
        { id: 2, name: 'Hotel B', destination_id: 200, addkey1: 999 },
        { id: 3, name: 'Hotel C', destination_id: 300, addkey1: [1, 2, 3, 4, 5] },
        { id: [1, 2, 3, 4, 5], name: [1, 2, 3, 4, 5], destination_id: [1, 2, 3, 4, 5] }
      ]
    end

    subject(:service) { described_class.new(datasets) }

    it 'sorts the datasets based on key count and values richness' do
      expect(service.call).to eq([{ id: [1, 2, 3, 4, 5], name: [1, 2, 3, 4, 5], destination_id: [1, 2, 3, 4, 5] },
                                  { id: 2, name: 'Hotel B', destination_id: 200, addkey1: 999 },
                                  { id: 3, name: 'Hotel C', destination_id: 300, addkey1: [1, 2, 3, 4, 5] },
                                  { id: 1, name: 'Hotel A', destination_id: 100, addkey1: 1, addkey2: 2, addkey3: 3 }])
    end
  end
end
