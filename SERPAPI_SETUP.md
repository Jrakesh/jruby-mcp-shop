# SerpAPI Setup Guide

## Getting Your SerpAPI Key

1. **Sign Up for SerpAPI:**
   - Go to [https://serpapi.com/users/sign_up](https://serpapi.com/users/sign_up)
   - Create a free account (100 searches/month included)
   - Verify your email address

2. **Get Your API Key:**
   - Login to your SerpAPI dashboard
   - Go to [https://serpapi.com/manage-api-key](https://serpapi.com/manage-api-key)
   - Copy your API key

3. **Configure Your Application:**
   
   **Option 1: Environment Variable**
   ```bash
   export SERPAPI_API_KEY="your_actual_api_key_here"
   ```
   
   **Option 2: Direct Configuration in app.rb**
   ```ruby
   # In app.rb, replace the placeholder:
   ENV['SERPAPI_API_KEY'] ||= 'your_actual_api_key_here'
   ```
   
   **Option 3: Create .env file**
   ```bash
   cp .env.example .env
   # Edit .env and add your actual API key
   ```

## Testing the Integration

### Hotels & Restaurants Search

**Test URLs:**
- Mumbai: `http://localhost:3000/hotels-restaurants`
- Search for: "Mumbai"
- Expected: Real hotels and restaurants in Mumbai

**API Parameters:**
- `location`: City name (supports India and international cities)
- `query_type`: 'hotels', 'restaurants', or 'hotels and restaurants'

### Flights Search

**Test URLs:**
- Mumbai to Delhi: `http://localhost:3000/flights`
- Origin: "Mumbai", Destination: "Delhi"
- Expected: Real flight prices and schedules

**API Parameters:**
- `origin`: Departure city
- `destination`: Arrival city
- `departure_date`: YYYY-MM-DD format
- `return_date`: Optional for round trip
- `passengers`: Number of passengers (default: 1)
- `class_type`: Economy, Business, First (default: Economy)

## Supported Locations

### India (Major Cities)
- Mumbai (BOM), Delhi (DEL), Bangalore (BLR)
- Hyderabad (HYD), Chennai (MAA), Kolkata (CCU)
- Pune (PNQ), Jaipur (JAI), Ahmedabad (AMD)
- Kochi (COK), Goa (GOI), Lucknow (LKO)
- And 200+ other Indian cities

### International Cities
- New York (JFK), London (LHR), Paris (CDG)
- Tokyo (NRT), Dubai (DXB), Singapore (SIN)
- Sydney (SYD), Toronto (YYZ), Hong Kong (HKG)
- And many more

## API Features

### Real Data (with valid API key):
- **Hotels:** Real names, addresses, ratings, prices, reviews
- **Restaurants:** Real menus, hours, contact info, descriptions
- **Flights:** Real airlines, prices, schedules, durations

### Demo Data (without API key):
- Location-specific sample data
- Realistic pricing based on routes
- Indian and international examples

## Pricing Plans

- **Free:** 100 searches/month
- **Developer:** $50/month for 5,000 searches
- **Production:** $150/month for 15,000 searches
- **Enterprise:** Custom pricing for higher volumes

## Error Handling

The application gracefully handles:
- Invalid API keys (falls back to demo data)
- Network timeouts
- Invalid locations
- API rate limiting

## Support

For SerpAPI support:
- Documentation: [https://serpapi.com/search-api](https://serpapi.com/search-api)
- Support: [https://serpapi.com/contact](https://serpapi.com/contact)
- Status: [https://status.serpapi.com/](https://status.serpapi.com/)
