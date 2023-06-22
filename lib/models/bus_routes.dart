import 'package:bus_routes_app/models/trip.dart';

// model for bus route to store each route info and it has a shortestTripStartTime property that is extracted by sorting the trips list
class BusRoute {
  BusRoute(
      {required this.id,
      required this.name,
      required this.source,
      required this.destination,
      required this.tripDuration,
      required this.icon,
      required this.trips});

  String id;
  String name;
  String source;
  String destination;
  String tripDuration;
  String icon;
  List<Trip> trips;
  String? shortestTripStartTime;

  factory BusRoute.fromJson(
      Map<String, dynamic> routeInfo, List<dynamic> routeTimings) {
    List<Trip> trips = routeTimings.map(
      (trip) {
        return Trip.fromJson(trip);
      },
    ).toList();

    return BusRoute(
      id: routeInfo['id'],
      name: routeInfo['name'],
      source: routeInfo['source'],
      destination: routeInfo['destination'],
      tripDuration: routeInfo['tripDuration'],
      icon: routeInfo['icon'],
      trips: trips,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'source': source,
      'destination': destination,
      'tripDuration': tripDuration,
      'icon': icon,
      'trips': trips.map((trip) => trip.toJson()).toList(),
      'shortestTripStartTime': shortestTripStartTime,
    };
  }
}
