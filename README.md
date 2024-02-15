# Simplify Hotel Data Aggregator

## Requirements
[Problem statement and description](https://gist.github.com/mal90/90eb57055c3f2cxxxxxxxxx)

## Analysis
### Data input:
```
{
  "hotel_id": "iJhz",
  "destination_id": 5432,
  "hotel_name": "Beach Villas Singapore",
  "location": {
    "address": "8 Sentosa Gateway, Beach Villas, 098269",
    "country": "Singapore"
  },
  "details": "Surrounded by tropical gardens, these upscale villas in elegant Colonial-style buildings are part of the Resorts World Sentosa complex and a 2-minute walk from the Waterfront train station. Featuring sundecks and pool, garden or sea views, the plush 1- to 3-bedroom villas offer free Wi-Fi and flat-screens, as well as free-standing baths, minibars, and tea and coffeemaking facilities. Upgraded villas add private pools, fridges and microwaves; some have wine cellars. A 4-bedroom unit offers a kitchen and a living room. There's 24-hour room and butler service. Amenities include posh restaurant, plus an outdoor pool, a hot tub, and free parking.",
  "amenities": {
    "general": [
      "outdoor pool",
      "indoor pool",
      "business center",
      "childcare"
    ],
    "room": [
      "tv",
      "coffee machine",
      "kettle",
      "hair dryer",
      "iron"
    ]
  },
  "images": {
    "rooms": [
      {
        "link": "https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/2.jpg",
        "caption": "Double room"
      },
      {
        "link": "https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/3.jpg",
        "caption": "Double room"
      }
    ],
    "site": [
      {
        "link": "https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/1.jpg",
        "caption": "Front"
      }
    ]
  },
  "booking_conditions": [
    "All children are welcome. One child under 12 years stays free of charge when using existing beds. One child under 2 years stays free of charge in a child's cot/crib. One child under 4 years stays free of charge when using existing beds. One older child or adult is charged SGD 82.39 per person per night in an extra bed. The maximum number of children's cots/cribs in a room is 1. There is no capacity for extra beds in the room.",
    "Pets are not allowed.",
    "WiFi is available in all areas and is free of charge.",
    "Free private parking is possible on site (reservation is not needed).",
    "Guests are required to show a photo identification and credit card upon check-in. Please note that all Special Requests are subject to availability and additional charges may apply. Payment before arrival via bank transfer is required. The property will contact you after you book to provide instructions. Please note that the full amount of the reservation is due before arrival. Resorts World Sentosa will send a confirmation with detailed payment information. After full payment is taken, the property's details, including the address and where to collect keys, will be emailed to you. Bag checks will be conducted prior to entry to Adventure Cove Waterpark. === Upon check-in, guests will be provided with complimentary Sentosa Pass (monorail) to enjoy unlimited transportation between Sentosa Island and Harbour Front (VivoCity). === Prepayment for non refundable bookings will be charged by RWS Call Centre. === All guests can enjoy complimentary parking during their stay, limited to one exit from the hotel per day. === Room reservation charges will be charged upon check-in. Credit card provided upon reservation is for guarantee purpose. === For reservations made with inclusive breakfast, please note that breakfast is applicable only for number of adults paid in the room rate. Any children or additional adults are charged separately for breakfast and are to paid directly to the hotel."
  ]
}
```
#### Observation
- Data nested key level is 2
- Each supplier provide slightly different variants of key names
- Data values is of String/Integer/Float (single value) or Array type
- Data key name and values type can varies between multiple suppliers but the format is consistent accross all data from a single supplier
- Key is consistent but its values can sometime result in different data type
- Amenities data come in many format but represent similar definition, they are NOT always categorized correctly. incomplete data are match as best we could instead of discarding.
- Image data keys is consistent but the each image structure have slight variation that need to be accounted for
- 4 types of data that need to be handle differently.
  - String: `name, location[], detail`select from 1 source, simple text cleaning
  - Array of **long** Sring: `booking_conditions`, we can merge from multiple source if possible, simple text cleaning
  - Array of predefined set of values: `amenities`, the data need to be normalize and categorize while try to match with a set of valid data. data also need to be non-duplicated
  - Array of structured data: `images`, the data values contains different but predictable structure, require normalize to standard structure, aggregate from multiple sources and deduplicated

### Expected Data output:
```
[
  {
    "id": "iJhz",
    "destination_id": 5432,
    "name": "Beach Villas Singapore",
    "location": {
      "lat": 1.264751,
      "lng": 103.824006,
      "address": "8 Sentosa Gateway, Beach Villas, 098269",
      "city": "Singapore",
      "country": "Singapore"
    },
    "description": "Surrounded by tropical gardens, these upscale villas in elegant Colonial-style buildings are part of the Resorts World Sentosa complex and a 2-minute walk from the Waterfront train station. Featuring sundecks and pool, garden or sea views, the plush 1- to 3-bedroom villas offer free Wi-Fi and flat-screens, as well as free-standing baths, minibars, and tea and coffeemaking facilities. Upgraded villas add private pools, fridges and microwaves; some have wine cellars. A 4-bedroom unit offers a kitchen and a living room. There's 24-hour room and butler service. Amenities include posh restaurant, plus an outdoor pool, a hot tub, and free parking.",
    "amenities": {
      "general": ["outdoor pool", "indoor pool", "business center", "childcare", "wifi", "dry cleaning", "breakfast"],
      "room": ["aircon", "tv", "coffee machine", "kettle", "hair dryer", "iron", "bathtub"]
    },
    "images": {
      "rooms": [
        { "link": "https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/2.jpg", "description": "Double room" },
        { "link": "https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/3.jpg", "description": "Double room" },
        { "link": "https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/4.jpg", "description": "Bathroom" }
      ],
      "site": [
        { "link": "https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/1.jpg", "description": "Front" }
      ],
      "amenities": [
        { "link": "https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/0.jpg", "description": "RWS" }
      ]
    },
    "booking_conditions": [
      "All children are welcome. One child under 12 years stays free of charge when using existing beds. One child under 2 years stays free of charge in a child's cot/crib. One child under 4 years stays free of charge when using existing beds. One older child or adult is charged SGD 82.39 per person per night in an extra bed. The maximum number of children's cots/cribs in a room is 1. There is no capacity for extra beds in the room.",
      "Pets are not allowed.",
      "WiFi is available in all areas and is free of charge.",
      "Free private parking is possible on site (reservation is not needed).",
      "Guests are required to show a photo identification and credit card upon check-in. Please note that all Special Requests are subject to availability and additional charges may apply. Payment before arrival via bank transfer is required. The property will contact you after you book to provide instructions. Please note that the full amount of the reservation is due before arrival. Resorts World Sentosa will send a confirmation with detailed payment information. After full payment is taken, the property's details, including the address and where to collect keys, will be emailed to you. Bag checks will be conducted prior to entry to Adventure Cove Waterpark. === Upon check-in, guests will be provided with complimentary Sentosa Pass (monorail) to enjoy unlimited transportation between Sentosa Island and Harbour Front (VivoCity). === Prepayment for non refundable bookings will be charged by RWS Call Centre. === All guests can enjoy complimentary parking during their stay, limited to one exit from the hotel per day. === Room reservation charges will be charged upon check-in. Credit card provided upon reservation is for guarantee purpose. === For reservations made with inclusive breakfast, please note that breakfast is applicable only for number of adults paid in the room rate. Any children or additional adults are charged separately for breakfast and are to paid directly to the hotel."
    ]
  }
]
```
#### Observation
- Data nested key level is 2
- Single value key is chosen from single source while Array type are aggregated and deduplicated
- All Single value choice prefer the best data source and not so much on the value itself
- Best data source can be determined using most relevant information, closest structure to data ouput and the richness of the data
- Array output consist of data with the same normalization standard, aggregated together from many sources and have slightly different rules of merging
- Output Array are not always require sorting, but for consistency we will try to sort data when possible

## Approach and Decision
1. Step 1: Fetch Raw Data
2. Step 2: Map all data to the output format using a predefined mapping table
3. Step 3: Normalize data into mergeable form
4. Step 4: Clean values
5. Step 5: Evaluate and rank data in prefered order
6. Step 6: Split data into group of identifier
7. Step 7: Apply filter (receive from client)
8. Step 8: Merge Data with different rule based on value type

- Fetch data and save to memory cache as a simplify approach
- For key transformation and mapping, a set of mapping per supplier are defined manually based on output data. This mapping is used at Step 2 and can support nested data structure.
- Normalize rules: keys with String value are select from best source to worst if not available and cleaned, amenities string are normalized and match to a predefined list of amenities build from sample data manually. images data are build with a predefined structed and sorted. booking_conditions are only available from 1 source but will support aggregated from multiple sources, the text are long so consider simple text cleaning.
- Services are structured in 3 groups procuring, processing and delivery for coherence.
- Both unit tests and request tests are setup for more complete coverage.

## Implementation
See [PR 1](https://github.com/developie0610/hotel_api/pull/1) for more detail implementation and further details

## How to use
Setup project locally:
```
Install ruby
Install rails
Install postgresql
cd project & bundle install
rake db:create
```
Tests:
```
bundle exec rspec
```
Start server:
```
rails server
```
Verify setup (See PR 1):
```
1. curl
curl 'http://localhost:3000/api/v1/hotels?destination=5432'
curl -v 'http://localhost:3000/api/v1/hotels?hotels[]=SjyX&hotels[]=iJhz&hotels[]=f8c9'

2. URL
http://localhost:3000/api/v1/hotels?destination=5432
http://localhost:3000/api/v1/hotels?hotels[]=SjyX&hotels[]=iJhz&hotels[]=f8c9'

3. Swagger UI
http://localhost:3000/api-docs
```
**Important NOTE:** use `hotels` & `destination` parameter in request instead of `hotel_ids` & `destination_id` 
