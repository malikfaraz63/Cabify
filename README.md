# Cabify
Fully functioning iOS-based ride-hailing apps, each for riders and drivers. Includes the following:
- CabifyKit
- CabifyDriver
- CabifyRider

## CabifyKit
Package used by both rider and driver app, containing common objects and frameworks.
- Google Places API interface for route summary and location description
- Map view management and annotations
- Live journey navigation interface for client apps
- Profile interface

## CabifyDriver
Driver app with location-based filtering of ride requests, in-app navigation and session rejoin. Here is a breakdown of included features:
  ### Profile
  - View profile details
  ### Ratings
  - View ratings given to riders in past rides
  - Rate unrated rider in past rides
  ### Earnings
  - Optimised storage of earnings data for annual, monthy and weekly overview
  - View concise summary of earnings history
  ### Past Journeys
  - View past journey details and overview
  ### Requests
  - Optimised location-based filtering of pending ride requests
  - Updating status and location as ride progresses
  - Rejoin of in-progress session if app unexpectedly quits
  ### Ride View
  - In-app live navigation, with current journey step details
  - Ride overview and traffic-updated journey times

## CabifyRider
Rider app with optimised route selection, in-app navigation and session rejoin. Here is a breakdown of included features:
  ### Profile
  - View profile details
  ### Ratings
  - View ratings given to drivers in past rides
  - Rate unrated driver in past rides
  ### Past Journeys
  - View past journey details and overview
  ### Requests
  - Optimise pending ride requests for location-based filtering
  - Updating view as status and driver location on ride progresses
  - Rejoin of in-progress session if app unexpectedly quits
  ### Ride View
  - In-app live navigation
  - Ride overview and traffic-updated journey times
  
