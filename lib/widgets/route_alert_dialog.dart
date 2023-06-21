import 'package:bus_routes_app/models/bus_routes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final timeFormat = DateFormat('HH:mm');

class RouteAlertDialog extends StatelessWidget {
  const RouteAlertDialog({super.key, required this.route});

  final BusRoute route;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      title: Text(
        'Bus Timings: ${route.name}',
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      content: SizedBox(
        width: 200,
        height: 175,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(trip.tripStartTime,
                          style: timeFormat.parse(trip.tripStartTime).isAfter(
                                  timeFormat
                                      .parse(timeFormat.format(DateTime.now())))
                              ? const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
                    color: Colors.green, // Upcoming time color
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
  }
}
