# Geofence Reminder iOS App

An iOS app that allows users to set geofence-based reminders for points of interest fetched from an API. Built with Swift, MapKit, Core Data, and MVVM architecture.

## Overview
This app lets users explore points of interest (e.g., cafes, landmarks) fetched from a mock API, set geofence reminders with custom radii, and receive notifications when entering/exiting the geofenced area. Reminders are persisted locally using Core Data and displayed on a map and in a list.

## Features
- **API Integration**: Fetch points of interest from OpenStreetAPI (https://nominatim.openstreetmap.org/).
- **MapKit Annotations**: Display locations as custom map pins.
- **Geofencing**: Set circular geofences (100m–1000m) and trigger local notifications.
- **Core Data**: Save reminders with location details, radius, and notes.
- **Custom Radius Slider**: A dynamic circular slider for selecting geofence size.
- **Offline Support**: Persist reminders and display them without network access.
- **Error Handling**: Gracefully location permission denials and Notification permission denials.

## Third-party Libraries
- **Alamofire:** Used for handling network requests.
- **Anchorage:** Used for applying constraints in simpler way when creating UI programmatically.
- **HGCircularSlider:** Customizable circular slider for radius selection.
- **IQKeyboardManager:** Automatically manages keyboard interactions.

## Other Libraries Used
- **CoreData:** Used to store Geo-fence data
- **MapKit:** Used to display map and map related data
