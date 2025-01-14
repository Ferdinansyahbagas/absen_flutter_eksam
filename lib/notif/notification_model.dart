// class _HomePageState extends State<HomePage> {
//   PageController _pageController = PageController();
//   String? currentCity;
//   String? clockInMessage;
//   String? name = "";
//   String? message;
//   String _currentTime = "";
//   String? avatarUrl;
//   Timer? resetNoteTimer;
//   Timer? _timer;
//   int currentIndex = 0;
//   int _currentPage = 0;
//   bool isLoadingLocation = true;
//   bool hasClockedIn = false;
//   bool hasClockedOut = false;
//   bool showNote = true;
//   bool isSuccess = false;
//   bool isLate = false;
//   bool isHoliday = false;
//   bool isOvertimeIn = false; // Status untuk overtime in
//   bool isOvertimeOut = false; // Status untuk overtime out
//   List<String> announcements = [];

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//     getData();
//     getPengumuman();
//     _startClock();
//     _resetNoteAtFiveAM();
//     _pageController.addListener(() {
//       _fetchUserProfile();
//       setState(() {
//         _currentPage = _pageController.page!.round();
//       });
//     });
//   }

//   void _updateClockInStatus(bool status) {
//     setState(() {
//       hasClockedIn = status;
//     });
//   }

//   Future<void> getData() async {
//     // Ambil profil pengguna
//     try {
//       final url = Uri.parse(
//           'https://dev-portal.eksam.cloud/api/v1/karyawan/get-profile');
//       SharedPreferences localStorage = await SharedPreferences.getInstance();

//       var request = http.MultipartRequest('GET', url);
//       request.headers['Authorization'] =
//           'Bearer ${localStorage.getString('token')}';

//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);
//       var data = jsonDecode(rp.body.toString());
//       setState(() {
//         name = data['data']['name'];
//       });
//     } catch (e) {
//       print("Error mengambil profil pengguna: $e");
//     }

//     // Cek status clock-in
//     try {
//       final url = Uri.parse(
//           'https://dev-portal.eksam.cloud/api/v1/attendance/is-clock-in');
//       SharedPreferences localStorage = await SharedPreferences.getInstance();

//       var request = http.MultipartRequest('GET', url);
//       request.headers['Authorization'] =
//           'Bearer ${localStorage.getString('token')}';

//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);
//       var data = jsonDecode(rp.body.toString());

//       setState(() {
//         hasClockedIn = data['message'] != 'belum clock-in';
//         if (hasClockedIn) {
//           showNote = false;
//           final now = DateTime.now();
//           if (now.hour < 8) {
//             isSuccess = true;
//           } else {
//             isLate = true;
//           }
//         }
//       });
//     } catch (e) {
//       print("Error mengecek status clock-in: $e");
//     }

//     // Cek status clock-out
//     try {
//       final url = Uri.parse(
//           'https://dev-portal.eksam.cloud/api/v1/attendance/is-clock-out');
//       SharedPreferences localStorage = await SharedPreferences.getInstance();

//       var request = http.MultipartRequest('GET', url);
//       request.headers['Authorization'] =
//           'Bearer ${localStorage.getString('token')}';

//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);
//       var data = jsonDecode(rp.body.toString());

//       setState(() {
//         hasClockedOut = data['message'] == 'sudah clock-out';
//       });
//     } catch (e) {
//       print("Error mengecek status clock-out: $e");
//     }
//   }

//   void _resetNoteAtFiveAM() {
//     final now = DateTime.now();
//     final fiveAM = DateTime(now.year, now.month, now.day, 5);
//     final timeUntilReset = fiveAM.isBefore(now)
//         ? fiveAM.add(const Duration(days: 1)).difference(now)
//         : fiveAM.difference(now);

//     resetNoteTimer = Timer(timeUntilReset, () {
//       setState(() {
//         hasClockedIn = false;
//         showNote = true;
//         isSuccess = false;
//         isLate = false;
//         isHoliday = false;
//         isOvertimeIn = false; // Reset overtime status
//         isOvertimeOut = false;
//         clockInMessage = null;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     resetNoteTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Colors.orange,
//                     Colors.pink,
//                     const Color.fromARGB(255, 101, 19, 116)
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomCenter,
//                 ),
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       GestureDetector(
//                         onTap: () async {
//                           final updatedAvatarUrl = await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => ProfileScreen(),
//                             ),
//                           );
//                           if (updatedAvatarUrl != null) {
//                             setState(() {
//                               avatarUrl = updatedAvatarUrl;
//                             });
//                           }
//                         },
//                         child: CircleAvatar(
//                           radius: 25,
//                           backgroundColor: Colors.grey[200],
//                           backgroundImage: avatarUrl != null
//                               ? NetworkImage('avatarUrl')
//                               : AssetImage('assets/image/logo_circle.png')
//                                   as ImageProvider,
//                         ),
//                       ),
//                       Text(
//                         _currentTime,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           color: Color.fromARGB(255, 255, 255, 255),
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.notifications,
//                             color: Colors.white),
//                         onPressed: () {
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => NotificationPage()),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     'Welcome Back,\n $name',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const Text(
//                     'Don\'t Forget To Clock In Today ✨',
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 14,
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Column(
//                       children: [
//                         Text(
//                           isLoadingLocation
//                               ? 'Loading your location...'
//                               : 'Your Location Is Now In $currentCity',
//                           style: const TextStyle(color: Colors.black54),
//                         ),
//                         Text(
//                           DateFormat('EEEE, dd MMMM yyyy')
//                               .format(DateTime.now()),
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         if (!hasClockedOut) ...[
//                           // Clock In & Clock Out buttons
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               ElevatedButton.icon(
//                                 onPressed: hasClockedIn
//                                     ? null
//                                     : () async {
//                                         final result = await Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) =>
//                                                 ClockInPage(),
//                                           ),
//                                         );
//                                         if (result == true) {
//                                           _updateClockInStatus(true);
//                                         }
//                                       },
//                                 icon: const Icon(Icons.login),
//                                 label: const Text('Clock In'),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor:
//                                       hasClockedIn ? Colors.grey : Colors.white,
//                                 ),
//                               ),
//                               ElevatedButton.icon(
//                                 onPressed: hasClockedIn && !hasClockedOut
//                                     ? () async {
//                                         final result = await Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) =>
//                                                 const ClockOutScreen(),
//                                           ),
//                                         );
//                                         if (result == true) {
//                                           setState(() {
//                                             hasClockedOut = true;
//                                           });
//                                         }
//                                       }
//                                     : null,
//                                 icon: const Icon(Icons.logout),
//                                 label: const Text('Clock Out'),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: hasClockedIn && !hasClockedOut
//                                       ? Colors.white
//                                       : Colors.grey,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ] else ...[
//                           // Overtime In & Overtime Out buttons
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               ElevatedButton.icon(
//                                 onPressed: isOvertimeIn
//                                     ? null
//                                     : () async {
//                                         final result = await Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                               builder: (context) =>
//                                                   OvertimeInPage()),
//                                         );
//                                         if (result == true) {
//                                           setState(() {
//                                             isOvertimeIn = true;
//                                           });
//                                         }
//                                       },
//                                 icon: const Icon(Icons.timer),
//                                 label: const Text('Overtime In'),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: isOvertimeIn
//                                       ? Colors.grey
//                                       : Colors.white,
//                                 ),
//                               ),
//                               ElevatedButton.icon(
//                                 onPressed: isOvertimeIn && !isOvertimeOut
//                                     ? () async {
//                                         final result = await Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                               builder: (context) =>
//                                                   OvertimeOutPage()),
//                                         );
//                                         if (result == true) {
//                                           setState(() {
//                                             isOvertimeOut = true;
//                                           });
//                                         }
//                                       }
//                                     : null,
//                                 icon: const Icon(Icons.timer_off),
//                                 label: const Text('Overtime Out'),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: isOvertimeIn && !isOvertimeOut
//                                       ? Colors.white
//                                       : Colors.grey,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }