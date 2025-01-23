// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';

// Future<void> _submitData() async {
//   if (_image == null) {
//     // Show error if no image is uploaded
//     setState(() {
//       _isImageRequired = true;
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Please upload a photo before submitting.'),
//         backgroundColor: Colors.red,
//       ),
//     );
//     return; // Stop submission if no image
//   }

//   // Show loading dialog
//   showDialog(
//     context: context,
//     barrierDismissible: false, // Prevent dismissing the dialog
//     builder: (BuildContext context) {
//       return Center(
//         child: CircularProgressIndicator(
//           color: const Color.fromARGB(255, 101, 19, 116),
//         ),
//       );
//     },
//   );

//   try {
//     // Get current location
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);

//     double latitude = position.latitude;
//     double longitude = position.longitude;

//     // Convert coordinates to address
//     List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
//     Placemark place = placemarks[0]; // Get the first placemark

//     String city = place.locality ?? "Unknown City"; // If city not available, default to Unknown City

//     // Example API endpoint
//     final url = Uri.parse(
//         'https://dev-portal.eksam.cloud/api/v1/attendance/clock-in');

//     // Prepare multipart request to send image and data
//     var request = http.MultipartRequest('POST', url);

//     // Save selected work type and workplace type to SharedPreferences
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     await localStorage.setString('workType', _selectedWorkType!);
//     await localStorage.setString('workplaceType', _selectedWorkplaceType!);

//     request.headers['Authorization'] =
//         'Bearer ${localStorage.getString('token')}';
//     String type = '1';
//     String location = '1';
//     if (_selectedWorkType == "Lembur") {
//       type = '2';
//     } else {
//       type = '1';
//     }
//     if (_selectedWorkplaceType == "WFH") {
//       location = '2';
//     } else {
//       location = '1';
//     }
//     request.fields['type'] = type;
//     request.fields['status'] = '1';
//     request.fields['location'] = location;
//     request.fields['city'] = city; // Send city name

//     // Add image file
//     if (_image != null) {
//       request.files.add(await http.MultipartFile.fromPath(
//         'foto', // Field name for image in the API
//         _image!.path,
//         contentType: MediaType('image', 'jpg'), // Set content type
//       ));
//     }

//     // Send the request and get the response
//     var response = await request.send();
//     var rp = await http.Response.fromStream(response);
//     var data = jsonDecode(rp.body.toString());
//     print(data);
//     var status = data['status'];
//     if (status == 'success') {
//       // Successfully submitted
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => SuccessPage()),
//       );
//     } else {
//       // Submission failed
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => FailurePage()),
//       );
//     }
//   } catch (e) {
//     // Handle error and navigate to failure page
//     print("Error: $e");
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => FailurePage()),
//     );
//   }
// }