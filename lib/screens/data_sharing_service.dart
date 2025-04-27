// TODO Implement this library.
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/doctor.dart';
import '../models/health_data.dart';

class DataSharingService {
  static Future<bool> shareDataWithDoctor({
    required Doctor doctor,
    required List<HealthData> dataToSend,
  }) async {
    final url = Uri.parse(
      "https://jsonplaceholder.typicode.com/posts", // Mock API
    );

    // Convert the health data into JSON format
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "doctorEmail": doctor.email,
        "data": dataToSend.map((d) => d.toJson()).toList(),
      }),
    );

    // Check if the request was successful (status code 201 indicates success in jsonplaceholder mock API)
    return response.statusCode == 201;
  }
}
