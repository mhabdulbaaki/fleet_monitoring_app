import 'dart:convert';
import 'package:fleet_monitoring_app/models/car_api_model.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

String getRandomStatus() {
  final statuses = ['Parked', 'Moving'];
  final random = Random();
  return statuses[random.nextInt(statuses.length)];
}

class ApiService {
  static const String baseUrl =
      'https://682dc7c04fae188947578267.mockapi.io/api/v1/cars';

  static const List<Map<String, dynamic>> sampleData = [
    {
      "id": 1,
      "name": "Car A",
      "latitude": -1.94995,
      "longitude": 30.1,
      "speed": 45,
      "status": "Moving"
    },
    {
      "id": 2,
      "name": "Car B",
      "latitude": -1.94955,
      "longitude": 30.05825,
      "speed": 0,
      "status": "Parked"
    },
    {
      "id": 3,
      "name": "Car C",
      "latitude": -1.96015,
      "longitude": 30.05845,
      "speed": 30,
      "status": "Moving"
    },
    {
      "id": 4,
      "name": "Car D",
      "latitude": -1.90554,
      "longitude": 32.05905,
      "speed": 0,
      "status": "Parked"
    },
    {
      "id": 5,
      "name": "Car E",
      "latitude": -1.74000,
      "longitude": 30.28000,
      "speed": 55,
      "status": "Moving"
    },
    {
      "id": 6,
      "name": "Car F",
      "latitude": -1.78000,
      "longitude": 30.31000,
      "speed": 0,
      "status": "Parked"
    },
    {
      "id": 7,
      "name": "Car G",
      "latitude": -2.02000,
      "longitude": 30.20000,
      "speed": 62,
      "status": "Moving"
    },
    {
      "id": 8,
      "name": "Car H",
      "latitude": -1.85000,
      "longitude": 30.41000,
      "speed": 0,
      "status": "Parked"
    },
    {
      "id": 9,
      "name": "Car I",
      "latitude": -1.77000,
      "longitude": 30.18000,
      "speed": 58,
      "status": "Moving"
    },
    {
      "id": 10,
      "name": "Car J",
      "latitude": -2.05000,
      "longitude": 30.35000,
      "speed": 0,
      "status": "Parked"
    },
    {
      "id": 11,
      "name": "Car K",
      "latitude": -1.70500,
      "longitude": 30.25000,
      "speed": 63,
      "status": "Moving"
    },
    {
      "id": 12,
      "name": "Car L",
      "latitude": -1.92500,
      "longitude": 30.50000,
      "speed": 0,
      "status": "Parked"
    },
    {
      "id": 13,
      "name": "Car M",
      "latitude": -2.00000,
      "longitude": 30.06000,
      "speed": 51,
      "status": "Moving"
    },
    {
      "id": 14,
      "name": "Car N",
      "latitude": -1.81000,
      "longitude": 30.48000,
      "speed": 0,
      "status": "Parked"
    }
  ];



  // Fetch cars from API
  Future<List<Car>> fetchCars() async {
    try {
      // final response = await http.get(Uri.parse(baseUrl));
      // print("Response status code: ${response.statusCode}");
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = json.decode(response.body);
      //   print({...data[0], 'status': getRandomStatus()});
      //   return data
      //       .map(
      //         (json) => Car.fromJson({
      //           ...json,
      //           'status': getRandomStatus(),
      //           'id': int.parse(json['id']),
      //         }),
      //       )
      //       .toList();
      // } else {
      //   throw Exception('Failed to load cars: ${response.statusCode}');
      // }

      await Future.delayed(const Duration(milliseconds: 300));



      final now = DateTime.now().millisecondsSinceEpoch;
      final data = sampleData.map((car) {

        final rand = now % 1000 / 10000;
        return {
          ...car,
          "latitude": (car["latitude"] as double) + (rand - 0.05) * (car["status"] == "Moving" ? 1 : 0),
          "longitude": (car["longitude"] as double) + (rand - 0.04) * (car["status"] == "Moving" ? 1 : 0),
          "speed": car["status"] == "Moving" ? (car["speed"] as int) + (now % 10 - 5) : 0,
        };
      }).toList();

      return data.map((json) => Car.fromJson(json)).toList();
    } catch (e) {
      print("Error: $e");
      throw Exception('Failed to load cars: $e');
    }
  }
}
