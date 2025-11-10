import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'trip_helper.dart';
import 'current_trip_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../data_manager.dart'; // Add this import


class PreviousTripsPage extends StatefulWidget {
  const PreviousTripsPage({super.key});

  @override
  PreviousTripsPageState createState() => PreviousTripsPageState();
}

class PreviousTripsPageState extends State<PreviousTripsPage> {
  String _selectedTimeFilter = 'All';

  final List<String> _timeFilters = [
    'All',
    'Past Year',
    'Past Month',
    'Past Week',
    'Past Day',
  ];

  List<dynamic> trips = [];
  late String role;
  bool isLoading = true;
  String? _filter;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    fetchPreviousTrips();
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    role = prefs.getString('role')!;
    setState(() => isLoading = false);
  }

  // Future<void> fetchPreviousTrips() async {
  //   setState(() => isLoading = true);
  //   List<dynamic> data = await TripService.fetchPreviousTrips();
  //   if (mounted) {
  //     setState(() {
  //       trips = data;
  //       _sortTrips();
  //       isLoading = false;
  //     });
  //   }
  // }
  // revert to above if below causes issues
  // Future<void> fetchPreviousTrips() async {
  //   if (!mounted) return;  // ADD THIS LINE
  //   setState(() => isLoading = true);
    
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? userDataJson = prefs.getString('user_data');
    
  //   if (userDataJson == null) {
  //     if (mounted) setState(() => isLoading = false);  // ADD mounted check
  //     return;
  //   }
    
  //   Map<String, dynamic> userData = json.decode(userDataJson);
  //   String userEmail = userData['email'] ?? '';
    
  //   try {
  //     final response = await http.get(
  //       Uri.parse('https://m9yn8bsm3k.execute-api.us-west-1.amazonaws.com/analyze-driver?email=$userEmail'),
  //       headers: {
  //         'Authorization': 'Bearer ${prefs.getString('access_token')}',
  //       },
  //     );
      
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       if (mounted) {  // ADD mounted check
  //         setState(() {
  //           trips = data['trips'] ?? [];
  //           _sortTrips();
  //           isLoading = false;
  //         });
  //       }
  //     } else {
  //       if (mounted) setState(() => isLoading = false);  // ADD mounted check
  //     }
  //   } catch (error) {
  //     print('Error fetching trips: $error');
  //     if (mounted) setState(() => isLoading = false);  // ADD mounted check
  //   }
  // }
  // revert to above if below causes issues
  Future<void> fetchPreviousTrips() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    
    try {
      Map<String, dynamic>? analytics = await DataManager.getDriverAnalytics();
      
      if (analytics != null) {
        setState(() {
          trips = analytics['trips'] ?? [];
          _sortTrips();
          isLoading = false;
        });
      } else {
        setState(() {
          trips = [];
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching trips: $error');
      if (mounted) setState(() => isLoading = false);
    }
  }


  void _sortTrips() {
    if (_filter == 'recent') {
      trips.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    } else if (_filter == 'longest') {
      trips.sort((a, b) => b['distance'].compareTo(a['distance']));
    }
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue[800]),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
  }

  // List<Map<String, dynamic>> getFilteredTrips() {
  //   final now = DateTime.now();

  //   return trips
  //       .whereType<Map<String, dynamic>>() // ✅ filters and casts
  //       .where((trip) {
  //         final timestamp =
  //             trip['timestamp'] is int
  //                 ? trip['timestamp']
  //                 : DateTime.parse(trip['timestamp']).millisecondsSinceEpoch ~/
  //                     1000;
  //         final tripDate = DateTime.fromMillisecondsSinceEpoch(
  //           timestamp * 1000,
  //         );

  //         switch (_selectedTimeFilter) {
  //           case 'Past Year':
  //             return tripDate.isAfter(now.subtract(Duration(days: 365)));
  //           case 'Past Month':
  //             return tripDate.isAfter(now.subtract(Duration(days: 30)));
  //           case 'Past Week':
  //             return tripDate.isAfter(now.subtract(Duration(days: 7)));
  //           case 'Past Day':
  //             return tripDate.isAfter(now.subtract(Duration(days: 1)));
  //           default:
  //             return true;
  //         }
  //       })
  //       .toList();
  // }
  // revert to above if below causes issues
  List<Map<String, dynamic>> getFilteredTrips() {
    final now = DateTime.now();

    return trips
        .whereType<Map<String, dynamic>>()
        .where((trip) {
          // Handle both your backend and Ryan's formats safely
          dynamic timestampValue = trip['start_timestamp'] ?? trip['timestamp'];
          
          if (timestampValue == null) return true; // Include trips without timestamps
          
          DateTime tripDate;
          try {
            if (timestampValue is String) {
              tripDate = DateTime.parse(timestampValue);
            } else if (timestampValue is int) {
              tripDate = DateTime.fromMillisecondsSinceEpoch(timestampValue * 1000);
            } else {
              return true; // Include if we can't parse
            }
          } catch (e) {
            return true; // Include if parsing fails
          }

          switch (_selectedTimeFilter) {
            case 'Past Year':
              return tripDate.isAfter(now.subtract(Duration(days: 365)));
            case 'Past Month':
              return tripDate.isAfter(now.subtract(Duration(days: 30)));
            case 'Past Week':
              return tripDate.isAfter(now.subtract(Duration(days: 7)));
            case 'Past Day':
              return tripDate.isAfter(now.subtract(Duration(days: 1)));
            default:
              return true;
          }
        })
        .toList();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final filteredTrips = getFilteredTrips();

    return Scaffold(
      appBar:
          isLoading
              ? null
              : CustomAppBar(
                selectedIndex: 1,
                onItemTapped: _onItemTapped,
                role: role,
              ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: fetchPreviousTrips,
                child:
                    trips.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions_car,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No trips recorded yet",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.blue[800],
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CurrentTripPage(),
                                    ),
                                  );
                                },
                                child: const Text("Start a new trip"),
                              ),
                            ],
                          ),
                        )
                        : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Trips",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Card(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  elevation: 4,
  color: Colors.white,
  child: Padding(
    padding: const EdgeInsets.all(12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Filter Trips By Time',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          initialValue: _selectedTimeFilter,
          items: _timeFilters.map((String filter) {
            return DropdownMenuItem<String>(
              value: filter,
              child: Text(filter),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedTimeFilter = newValue!;
            });
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: Text(
                "Recent",
                style: TextStyle(
                  color: _filter == 'recent' ? Colors.white : Colors.blue[800],
                ),
              ),
              selected: _filter == 'recent',
              selectedColor: Colors.blue[800],
              backgroundColor: Colors.white,
              shape: StadiumBorder(
                side: BorderSide(color: Colors.blue[800]!),
              ),
              onSelected: (bool selected) {
                setState(() {
                  _filter = selected ? 'recent' : null;
                  _sortTrips();
                });
              },
            ),
            FilterChip(
              label: Text(
                "Longest",
                style: TextStyle(
                  color: _filter == 'longest' ? Colors.white : Colors.blue[800],
                ),
              ),
              selected: _filter == 'longest',
              selectedColor: Colors.blue[800],
              backgroundColor: Colors.white,
              shape: StadiumBorder(
                side: BorderSide(color: Colors.blue[800]!),
              ),
              onSelected: (bool selected) {
                setState(() {
                  _filter = selected ? 'longest' : null;
                  _sortTrips();
                });
              },
            ),
          ],
        ),
      ],
    ),
  ),
),

                              const SizedBox(height: 16),
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: () async {
                                    await DataManager.getDriverAnalytics(forceRefresh: true);
                                    await fetchPreviousTrips();
                                  },
                                  child: filteredTrips.isEmpty
                                      ? ListView(
                                          children: [
                                            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                                            Center(
                                              child: Column(
                                                children: [
                                                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                                                  SizedBox(height: 16),
                                                  Text(
                                                    'No trips found',
                                                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'Pull down to refresh',
                                                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : ListView.separated(
                                          itemCount: filteredTrips.length,
                                          separatorBuilder:
                                              (context, index) =>
                                                  const Divider(height: 1),

                                          itemBuilder: (context, index) {
                                    final trip = filteredTrips[index];
                                    
                                    // Parse date from your backend format
                                    String dateDisplay = "No date";
                                    String timeDisplay = "";
                                    DateTime? tripDate;
                                    
                                    String startTimeStr = trip['start_timestamp'] ?? '';
                                    if (startTimeStr.isNotEmpty) {
                                      try {
                                        tripDate = DateTime.parse(startTimeStr).toLocal();
                                        dateDisplay = DateFormat('MMM dd, yyyy').format(tripDate);
                                        timeDisplay = DateFormat('hh:mm a').format(tripDate);
                                      } catch (e) {
                                        print('Error parsing date: $e');
                                      }
                                    }
                                    
                                    // Get distance and score from your backend
                                    double distance = (trip['total_distance_miles'] ?? 0.0).toDouble();
                                    int tripScore = (trip['behavior_score'] ?? 0).toInt();
                                    
                                    // Determine score color
                                    Color scoreColor = tripScore >= 80 ? Colors.green : 
                                                      tripScore >= 60 ? Colors.orange : Colors.red;
                                    
                                    return Card(
                                      elevation: 2,
                                      color: Colors.white,
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.blue[100]!),
                                          ),
                                          child: Icon(
                                            Icons.directions_car,
                                            color: Colors.blue[800],
                                          ),
                                        ),
                                        title: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                dateDisplay,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: scoreColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: scoreColor),
                                              ),
                                              child: Text(
                                                'Score: $tripScore',
                                                style: TextStyle(
                                                  color: scoreColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Text(
                                          "${distance.toStringAsFixed(2)} miles • $timeDisplay",
                                          style: TextStyle(color: Colors.grey[800]),
                                        ),
                                        trailing: Icon(
                                          Icons.chevron_right,
                                          color: Colors.blue[800],
                                        ),
                                        onTap: () => TripService.showTripDetails(context, trip),
                                      ),
                                    );
                                  },
                                ),
                                ),
                              ),
                            ],
                          ),
                        ),
              ),
      bottomNavigationBar:
          isLoading
              ? null
              : CustomAppBar(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
                role: role,
              ).buildBottomNavBar(context),
    );
  }
}
