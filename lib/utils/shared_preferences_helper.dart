import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:bus_routes_app/models/bus_routes.dart';

class SharedPreferencesHelper {
  static Future<void> saveSortedRoutesToSharedPreferences(
      List<BusRoute> sortedRoutes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert the sortedRoutes list to JSON
    String jsonStr = json.encode(sortedRoutes);

    // Save the JSON string to shared preferences
    await prefs.setString('sortedRoutes', jsonStr);
  }

  static Future<List<BusRoute>> getSortedRoutesFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the JSON string from shared preferences
    String? jsonStr = prefs.getString('sortedRoutes');

    // Check if the JSON string is not null
    if (jsonStr != null) {
      // Convert the JSON string to a list of BusRoute objects
      List<dynamic> jsonList = json.decode(jsonStr);
      List<BusRoute> sortedRoutes = jsonList.map((json) {
        List<dynamic> tripListJson = json['trips'];

        return BusRoute.fromJson(json, tripListJson);
      }).toList();

      return sortedRoutes;
    }

    // Return an empty list if the JSON string is null or invalid
    return [];
  }
}
