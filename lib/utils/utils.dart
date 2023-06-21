import 'package:bus_routes_app/models/bus_routes.dart';
import 'package:bus_routes_app/models/trip.dart';
import 'package:intl/intl.dart';

final timeFormat = DateFormat('HH:mm');

// returns trips end time using trip start time and duration
String getTripEndTime(String tripStartTime, String tripDuration) {
  // Parse the trip start time
  final startTime = timeFormat.parse(tripStartTime);

  // Split the trip duration into parts

  final durationParts = tripDuration.split(' ');

  int hours = 0;
  int minutes = 0;

  for (final part in durationParts) {
    // if string contains 'hrs', it is no of hours, else it contains no of minutes
    if (part.contains('hrs')) {
      final value = int.tryParse(part.split('hrs')[0]);
      if (value != null) {
        hours = value;
      }
    } else {
      final value = int.tryParse(part);
      if (value != null) {
        minutes = value;
      }
    }
  }

  DateTime endTime = startTime.add(Duration(hours: hours, minutes: minutes));
  final formattedEndTime = timeFormat.format(endTime);

  return formattedEndTime;
}

// sorts the trips of each route (only upcoming trips, i.e, trips after current time) and then sorts
// the routes based on the shortest remaining time(first entry of upcoming trips) of each route

List<BusRoute> sortRoutesByTime(List<BusRoute> routes) {
  final deviceTime = timeFormat.format(DateTime.now());

  // sorts the trips for each trip (if there are upcoming trips)
  routes.forEach((route) {
    // resetting each route's shortestTripStartTime so that remainingMinutes does not become negative after last trip of each route because of previously stored value...
    route.shortestTripStartTime = null;

    // changed trips sorting logic so that trips are aleady sorted and no need of sorting again before displaying in alert dialog... also used routes variable to sort in place
    if (route.trips.isNotEmpty) {
      route.trips.sort(((a, b) => timeFormat
          .parse(a.tripStartTime)
          .compareTo(timeFormat.parse(b.tripStartTime))));

      Trip firstUpcomingTrip = route.trips.firstWhere(
        (trip) => timeFormat
            .parse(trip.tripStartTime)
            .isAfter(timeFormat.parse(deviceTime)),
        orElse: () => Trip(tripStartTime: '', totalSeats: -1, available: -1),
      );

      if (firstUpcomingTrip.tripStartTime.isNotEmpty) {
        route.shortestTripStartTime = firstUpcomingTrip.tripStartTime;
      }

      // final upcomingTrips = route.trips
      //     .where((trip) => timeFormat
      //         .parse(trip.tripStartTime)
      //         .isAfter(timeFormat.parse(deviceTime)))
      //     .toList();

      // if (upcomingTrips.isNotEmpty) {
      //   upcomingTrips.sort((a, b) => timeFormat
      //       .parse(a.tripStartTime)
      //       .compareTo(timeFormat.parse(b.tripStartTime)));

      //   route.shortestTripStartTime = upcomingTrips[0].tripStartTime;
      // }
    }
  });

  // sorts the routes based on the shortestTripStartTime property
  routes.sort((a, b) {
    final shortestStartTimeA = a.shortestTripStartTime != null
        ? timeFormat.parse(a.shortestTripStartTime!)
        : null;
    final shortestStartTimeB = b.shortestTripStartTime != null
        ? timeFormat.parse(b.shortestTripStartTime!)
        : null;

    if (shortestStartTimeA != null && shortestStartTimeB != null) {
      return shortestStartTimeA.compareTo(shortestStartTimeB);
    } else if (shortestStartTimeA != null) {
      return -1;
    } else if (shortestStartTimeB != null) {
      return 1;
    } else {
      return 0;
    }
  });

  routes.forEach((element) {
    print(element.shortestTripStartTime);
  });

  return routes;
}

// returns remaining time from tripTime compared to currentTime
int getRemainingTimeInMinutes(String tripTime) {
  final currentTime = timeFormat.format(DateTime.now());
  final remainingTime =
      timeFormat.parse(tripTime).difference(timeFormat.parse(currentTime));

  return remainingTime.inMinutes;
}
