# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataDeliveryService::Filter do
  describe '#call' do
    let(:datasets) do
      [
        { id: 1, destination_id: 100, name: 'Hotel A' },
        { id: 2, destination_id: 200, name: 'Hotel B' },
        { id: 3, destination_id: 100, name: 'Hotel C' }
      ]
    end

    subject { described_class.new(params, datasets).call }

    context 'when filtering by hotel ids' do
      let(:params) { { hotels: [1, 2] } }

      it 'returns data filter by hotel ids and group by hotel ids' do
        expect(subject).to eq({ 1 => [{ id: 1, destination_id: 100, name: 'Hotel A' }],
                                2 => [{ id: 2, destination_id: 200, name: 'Hotel B' }] })
      end
    end

    context 'when filtering by destination id' do
      let(:params) { { destination: 100 } }

      it 'returns data filter by destination id and group by hotel ids' do
        expect(subject).to eq({ 1 => [{ id: 1, destination_id: 100, name: 'Hotel A' }],
                                3 => [{ id: 3, destination_id: 100, name: 'Hotel C' }] })
      end
    end
  end
end
