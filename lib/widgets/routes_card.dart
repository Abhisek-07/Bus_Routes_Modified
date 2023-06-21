import 'package:bus_routes_app/models/bus_routes.dart';
import 'package:flutter/material.dart';
import 'package:bus_routes_app/widgets/route_alert_dialog.dart';

class RouteCard extends StatelessWidget {
  const RouteCard(
      {super.key, required this.route, this.remainingTime, this.tripEndTime});

  final BusRoute route;
  final int? remainingTime;
  final String? tripEndTime;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return RouteAlertDialog(route: route);
            });
      },
      child: Center(
        child: Card(
          margin: const EdgeInsets.only(bottom: 30),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
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
                              subtitle:
                                  Text(route.shortestTripStartTime ?? '----'),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(
                                child: Text(
                                  'No upcoming trips',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        )
                      else
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              Text('Travel time: ${route.tripDuration}'),
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
  }
}
