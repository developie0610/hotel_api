# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataProcessingService::Merger do
  describe '#call' do
    let(:dataset1) do
      {
        id: 'iJhz',
        destination_id: 5432,
        name: 'Beach Villas Singapore',
        location: {
          lat: 1.264751,
          lng: 103.824006
        },
        description: 'This 5 star hotel is located on the coastline of Singapore.',
        amenities: {
          general: %w[Pool BusinessCenter WiFi],
          room: ['TV', 'Coffee machine']
        },
        images: {
          rooms: [
            { link: 'https://example.com/image1.jpg', description: 'Image 1' },
            { link: 'https://example.com/image2.jpg', description: 'Image 2' }

          ]
        },
        booking_conditions: ['Condition 1', 'Condition 2']
      }
    end

    let(:dataset2) do
      {
        id: 'iJhz',
        destination_id: 5432,
        name: 'Beach Villas Singapore',
        location: {
          address: '8 Sentosa Gateway, Beach Villas, 098269',
          city: 'Singapore',
          country: 'SG'
        },
        description: 'This is a description of Beach Villas Singapore.',
        amenities: {
          general: %w[Pool WiFi],
          room: ['TV', 'Hair dryer']
        },
        images: { site: [
          { link: 'https://example.com/image1.jpg', description: 'Image 1' }, # Same image
          { link: 'https://example.com/image2.jpg', description: 'Image 2' }, # Same image
          { link: 'https://example.com/image3.jpg', description: 'Image 3' }  # Additional image
        ] }
      }
    end

    let(:datasets) { [dataset1, dataset2] }
    let(:expected_merged_data) do
      {
        id: 'iJhz',
        destination_id: 5432,
        name: 'Beach Villas Singapore',
        location: {
          lat: 1.264751,
          lng: 103.824006,
          address: '8 Sentosa Gateway, Beach Villas, 098269',
          city: 'Singapore',
          country: 'SG'
        },
        description: 'This 5 star hotel is located on the coastline of Singapore.', # Should take the value from dataset1
        amenities: { general: %w[Pool WiFi BusinessCenter], room: ['TV', 'Hair dryer', 'Coffee machine'] },
        images: { rooms: [{ description: 'Image 1', link: 'https://example.com/image1.jpg' }, { description: 'Image 2', link: 'https://example.com/image2.jpg' }],
                  site: [{ description: 'Image 1', link: 'https://example.com/image1.jpg' }, { description: 'Image 2', link: 'https://example.com/image2.jpg' },
                         { description: 'Image 3', link: 'https://example.com/image3.jpg' }] },
        booking_conditions: ['Condition 1', 'Condition 2']
      }
    end
    subject(:service) { described_class.new(datasets) }

    it 'merges the datasets' do
      expect(service.call).to eq(expected_merged_data)
    end
  end
end
