import 'dart:convert';

import 'package:bus_routes_app/models/bus_routes.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// api_service to fetch json data and return list of Bus routes
class ApiService {
  Future<List<BusRoute>> getData() async {
    const url =
        'https://d080ce76-38ec-4b9b-aca2-6b6f0bf3b176.mock.pstmn.io/bus_routes';
    Uri uri = Uri.parse(url);
    final response = await http.get(uri);

    final data = response.body;

    final Map<String, dynamic> busData = json.decode(data);

    // list of bus routes
    List<dynamic> busRoutesInfo = busData['routeInfo'];

    List<BusRoute> busRoutes = busRoutesInfo.map(
      (busInfo) {
        String id = busInfo['id'];

        // list of bus route trips for each bus route
        List<dynamic> busRouteTimings = busData['routeTimings'][id];

        return BusRoute.fromJson(busInfo, busRouteTimings);
      },
    ).toList();

    print(jsonEncode(busRoutes[0].toJson()));

    return busRoutes;
  }
}

final routesProvider = FutureProvider<List<BusRoute>>((ref) async {
  ApiService apiService = ApiService();
  final busRoutes = await apiService.getData();
  return busRoutes;
});
