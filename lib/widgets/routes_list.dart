import 'dart:async';

import 'package:bus_routes_app/models/bus_routes.dart';
import 'package:bus_routes_app/utils/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workmanager/workmanager.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:bus_routes/service/api_service.dart';
import 'package:bus_routes_app/utils/utils.dart';
import 'package:bus_routes_app/utils/shared_preferences_helper.dart';

// made global variable to use in workmanager and by this screen, the busRoutes list is available
List<BusRoute> sortedRoutes = [];

// method executed by workmanager
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == "sortRoutesTask") {
      // final container = ProviderContainer();
      // var routesList = await container.read(routesProvider.future);

      sortedRoutes =
          await SharedPreferencesHelper.getSortedRoutesFromSharedPreferences();
      sortedRoutes = sortRoutesByTime(sortedRoutes);
      await SharedPreferencesHelper.saveSortedRoutesToSharedPreferences(
          sortedRoutes);
    }

    return Future.value(true);
  });
}

final timeFormat = DateFormat('HH:mm');

class RoutesList extends StatefulWidget {
  const RoutesList({super.key, required this.busRoutes});

  final List<BusRoute> busRoutes;

  @override
  State<RoutesList> createState() => _RoutesListState();
}

class _RoutesListState extends State<RoutesList> {
  Timer? timer;
  // List<BusRoute> sortedRoutes = [];

  bool isLoading = false;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // timer is initialised inside initstate and first call to updateData to sort the routes
  @override
  void initState() {
    super.initState();
    updateData();
    startTimer();
    configureWorkManager();
  }

  // for configuring the work manager
  void configureWorkManager() {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
    Workmanager().registerPeriodicTask(
      "sortRoutesTask",
      "sortRoutesTask",
      frequency: const Duration(minutes: 1),
    );
  }

  // dispose method
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // updates sorted list of bus routes
  void updateData() async {
    setState(() {
      sortedRoutes = sortRoutesByTime(widget.busRoutes);
    });

    // saving sorted routes to shared preferences
    await SharedPreferencesHelper.saveSortedRoutesToSharedPreferences(
        sortedRoutes);

    // logic for showing notifications when 5 minutes till next bus
    if (sortedRoutes[0].shortestTripStartTime != null) {
      final remainingTime =
          getRemainingTimeInMinutes(sortedRoutes[0].shortestTripStartTime!);

      if (remainingTime == 5) {
        NotificationService.showNotification();
      }
    }
  }

  // starts timer for periodic update of bus routes every minute
  void startTimer() {
    timer = Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      updateData();
    });
  }

  // function to be executed on pull to refresh
  Future<void> _refreshList() async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    isLoading = false;
    updateData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1),
          duration: const Duration(milliseconds: 1500),
          builder: (context, value, _) => CircularProgressIndicator(
            value: value,
          ),
        ),
      );
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refreshList,
      child: ListView.builder(
          itemCount: sortedRoutes.length,
          itemBuilder: (context, index) {
            final route = sortedRoutes[index];

            int? remainingTime;
            String? tripEndTime;

            if (route.shortestTripStartTime != null) {
              remainingTime =
                  getRemainingTimeInMinutes(route.shortestTripStartTime!);
              tripEndTime = getTripEndTime(
                  route.shortestTripStartTime!, route.tripDuration);

              if (remainingTime <= 0) {
                return Container();
              }
            }

            route.trips.sort(
              (a, b) => timeFormat
                  .parse(a.tripStartTime)
                  .compareTo(timeFormat.parse(b.tripStartTime)),
            );

            // widget for route card
            return GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        title: Text(
                          'Bus Timings: ${route.name}',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        content: SizedBox(
                          width: 200,
                          height: 175,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (route.trips.isEmpty)
                                        const Expanded(
                                          child: Center(
                                            child: Text('No trips'),
                                          ),
                                        )
                                      else
                                        for (var trip in route.trips)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 16),
                                            child: Text(trip.tripStartTime,
                                                style: timeFormat
                                                        .parse(
                                                            trip.tripStartTime)
                                                        .isAfter(timeFormat
                                                            .parse(timeFormat
                                                                .format(DateTime
                                                                    .now())))
                                                    ? const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.green)
                                                    : const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.grey,
                                                      )),
                                          ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Legend:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Row(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          color: Colors
                                              .green, // Upcoming time color
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Upcoming Trips'),
                                      ],
                                    ),
                                    SizedBox(width: 12),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          color: Colors.grey, // Past time color
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Past Trips'),
                                      ],
                                    ),
                                  ],
                                ),
                              ]),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Close'),
                          ),
                        ],
                        actionsAlignment: MainAxisAlignment.center,
                      );
                    });
              },
              child: Center(
                child: Card(
                  margin: const EdgeInsets.only(bottom: 30),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    child: SizedBox(
                      width: 350,
                      height: 200,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      minLeadingWidth: 10,
                                      leading: const IconTheme(
                                        data: IconThemeData(
                                          color: Colors.blue,
                                        ),
                                        child: Icon(Icons.location_on),
                                      ),
                                      title: Text(
                                        route.source,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      subtitle: Text(
                                          route.shortestTripStartTime ??
                                              '----'),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    ListTile(
                                      minLeadingWidth: 10,
                                      leading: const IconTheme(
                                        data: IconThemeData(
                                          color: Colors.red,
                                        ),
                                        child: Icon(Icons.location_on),
                                      ),
                                      title: Text(
                                        route.destination,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      subtitle: Text(tripEndTime ?? '----'),
                                    )
                                  ],
                                ),
                              ),
                              const VerticalDivider(),
                              if (route.shortestTripStartTime == null)
                                const Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Center(
                                        child: Text(
                                          'No upcoming trips',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              else
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Departure in:',
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '$remainingTime',
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const TextSpan(
                                              text: 'mins',
                                              style: TextStyle(fontSize: 12),
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                          'Travel time: ${route.tripDuration}'),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(route.name),
                                const SizedBox(
                                  width: 20,
                                ),
                                const Icon(
                                  Icons.bus_alert,
                                  color: Colors.lightBlue,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
