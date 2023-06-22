import 'dart:async';

import 'package:bus_routes_app/models/bus_routes.dart';
import 'package:bus_routes_app/utils/notification_service.dart';
import 'package:bus_routes_app/widgets/routes_card.dart';
// import 'package:bus_routes_app/widgets/route_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workmanager/workmanager.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:bus_routes/service/api_service.dart';
import 'package:bus_routes_app/utils/utils.dart';
import 'package:bus_routes_app/utils/shared_preferences_helper.dart';

// made global variable to use in workmanager and by this screen, the busRoutes list is available
List<BusRoute> sortedRoutes = [];
Workmanager workmanager = Workmanager();
final timeFormat = DateFormat('HH:mm');

// method executed by workmanager
void callbackDispatcher() {
  workmanager.executeTask((task, inputData) async {
    if (task == "sortRoutesTask") {
      // final container = ProviderContainer();
      // var routesList = await container.read(routesProvider.future);

      sortedRoutes =
          await SharedPreferencesHelper.getSortedRoutesFromSharedPreferences();
      sortedRoutes = sortRoutesByTime(sortedRoutes);

      if (sortedRoutes.isNotEmpty &&
          sortedRoutes[0].shortestTripStartTime != null) {
        final remainingTime =
            getRemainingTimeInMinutes(sortedRoutes[0].shortestTripStartTime!);
        NotificationService notificationService = NotificationService();
        await notificationService.init();
        notificationService.showNotification(
            sortedRoutes[0].name, remainingTime);
      }

      await SharedPreferencesHelper.saveSortedRoutesToSharedPreferences(
          sortedRoutes);
    }

    return Future.value(true);
  });
}

class RoutesList extends StatefulWidget {
  const RoutesList({super.key, required this.busRoutes});

  final List<BusRoute> busRoutes;

  @override
  State<RoutesList> createState() => _RoutesListState();
}

class _RoutesListState extends State<RoutesList> {
  // List<BusRoute> sortedRoutes = [];

  Timer? timer;

  NotificationService notificationService = NotificationService();

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
    initializeNotifications();
  }

  void initializeNotifications() async {
    await notificationService.init();
  }

  // for configuring the work manager
  void configureWorkManager() {
    workmanager.initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
    workmanager.registerPeriodicTask(
      "sortRoutesTask",
      "sortRoutesTask",
      frequency: const Duration(minutes: 1),
      initialDelay: const Duration(seconds: 2),
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
    if (sortedRoutes.isNotEmpty &&
        sortedRoutes[0].shortestTripStartTime != null) {
      final remainingTime =
          getRemainingTimeInMinutes(sortedRoutes[0].shortestTripStartTime!);

      if (remainingTime == 5) {
        notificationService.showNotification(
            sortedRoutes[0].name, remainingTime);
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

              // if (remainingTime <= 0) {
              //   return Container();
              // }
            }

            // route.trips.sort(
            //   (a, b) => timeFormat
            //       .parse(a.tripStartTime)
            //       .compareTo(timeFormat.parse(b.tripStartTime)),
            // );

            // widget for route card
            return RouteCard(
              route: route,
              remainingTime: remainingTime,
              tripEndTime: tripEndTime,
            );
          }),
    );
  }
}
