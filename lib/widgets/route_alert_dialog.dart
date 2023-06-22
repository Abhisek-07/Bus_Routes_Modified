import 'package:bus_routes_app/models/bus_routes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final timeFormat = DateFormat('HH:mm');

class RouteAlertDialog extends StatefulWidget {
  const RouteAlertDialog({super.key, required this.route});

  final BusRoute route;

  @override
  State<RouteAlertDialog> createState() => _RouteAlertDialogState();
}

class _RouteAlertDialogState extends State<RouteAlertDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          'Bus Timings: ${widget.route.name}',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.route.trips.isEmpty)
                    const SizedBox(
                      height: 120,
                      child: Center(
                        child: Text('No trips'),
                      ),
                    )
                  else
                    for (var trip in widget.route.trips)
                      timeFormat.parse(trip.tripStartTime).isAfter(timeFormat
                              .parse(timeFormat.format(DateTime.now())))
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        border: Border.all(
                                            color:
                                                Theme.of(context).primaryColor),
                                        borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.all(2),
                                    child: Text(
                                      trip.tripStartTime,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                const Text(
                                  'Arriving',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        border: Border.all(
                                            color:
                                                Theme.of(context).primaryColor),
                                        borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.all(2),
                                    child: Text(
                                      trip.tripStartTime,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                const Text(
                                  'Departed',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                ],
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
                        color: Colors.red, // Past time color
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text('Past Trips'),
                    ],
                  ),
                ],
              ),
            ]),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }
}
