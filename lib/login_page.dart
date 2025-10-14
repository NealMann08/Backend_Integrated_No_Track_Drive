import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'home_page.dart';
import 'ipconfig.dart';
import 'geocodingutils.dart';

class LoginPageWidget extends StatefulWidget {
  const LoginPageWidget({super.key});

  @override
  State<LoginPageWidget> createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends State<LoginPageWidget>
    with TickerProviderStateMixin {

  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFEEEEEE);

  final _formKey = GlobalKey<FormState>();
  late SharedPreferences _prefs;
  bool _isProcessing = false;
  final String _selectedRole = 'user';
  bool _isSignupMode = false;
  // Geocoding state
  bool _isGeocoding = false;
  bool? _zipcodeValid;
  CityCoordinates? _basePoint;

  // Controllers
  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final passwordController = TextEditingController();
  final zipcodeController = TextEditingController();
  final insuranceProviderController = TextEditingController();
  final stateController = TextEditingController();
  final serverNumberController = TextEditingController();
  final idController = TextEditingController();
  final _adminIdController = TextEditingController();
final _serverNumberController = TextEditingController();


  late TabController _tabController;
  final String server = AppConfig.server;

  // remove if not working asap
  final String authEndpoint = 'https://m9yn8bsm3k.execute-api.us-west-1.amazonaws.com/auth-user';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializePrefs();
    
    // Add listener for zipcode real-time geocoding
    zipcodeController.addListener(_onZipcodeChanged);
  }

  Future<void> _initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Debounced zipcode geocoding
  void _onZipcodeChanged() {
    if (!_isSignupMode || _selectedRole != 'user') return;
    
    final zipcode = zipcodeController.text.trim();
    
    if (zipcode.isEmpty) {
      setState(() {
        _zipcodeValid = null;
        _basePoint = null;
      });
      return;
    }
    
    final isValid = validateZipcode(zipcode);
    setState(() {
      _zipcodeValid = isValid;
    });
    
    if (isValid && zipcode.length == 5) {
      // Debounce geocoding call
      Future.delayed(Duration(milliseconds: 800), () {
        if (zipcodeController.text.trim() == zipcode) {
          _performGeocoding(zipcode);
        }
      });
    } else {
      setState(() {
        _basePoint = null;
      });
    }
  }

  // Perform geocoding
  Future<void> _performGeocoding(String zipcode) async {
    if (_isGeocoding) return;
    
    setState(() {
      _isGeocoding = true;
    });
    
    try {
      final coordinates = await getCityCoordinatesFromZipcode(zipcode);
      setState(() {
        _basePoint = coordinates;
      });
      print('🎯 Base point set: ${coordinates.city}, ${coordinates.state}');
    } catch (error) {
      print('❌ Geocoding error: $error');
      setState(() {
        _basePoint = null;
      });
    } finally {
      setState(() {
        _isGeocoding = false;
      });
    }
  }

  @override
  void dispose() {
    zipcodeController.removeListener(_onZipcodeChanged);
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    passwordController.dispose();
    zipcodeController.dispose();
    insuranceProviderController.dispose();
    stateController.dispose();
    serverNumberController.dispose();
    idController.dispose();
    _tabController.dispose();
    
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (_isProcessing || !_formKey.currentState!.validate()) return;
    
    setState(() => _isProcessing = true);
    
    try {
      if (_isSignupMode) {
        await _signup();
      } else {
        await _login();
      }
    } catch (error) {
      _showErrorDialog(_isSignupMode 
          ? 'An error occurred during signup' 
          : 'The server is down. Please try again later.');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // Future<void> _signup() async {
  //   final url = '$server/signup';
  //   final data = _buildAuthData();

  //   final response = await http.post(
  //     Uri.parse(url),
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode(data),
  //   );

  //   if (response.statusCode == 201) {
  //     await _handleSuccessfulAuth(response.body);
  //   } else {
  //     final responseData = await _parseJson(response.body);
  //     _showErrorDialog(responseData['message'] ?? 'Signup failed');
  //   }
  // }

  // uncomment above code if below ufnction version does not work

  Future<void> _signup() async {
    final url = authEndpoint; // Use your Lambda endpoint
    
    // Map Flutter roles to your backend roles
    String backendRole = 'driver'; // Default
    if (_selectedRole == 'insurance' || _selectedRole == 'admin') {
      backendRole = 'provider';
    }
    
    // Build data structure matching your backend
    final Map<String, dynamic> data = {
      'email': emailController.text.toLowerCase().trim(),
      'password': passwordController.text,
      'mode': 'signup',
      'role': backendRole,
    };
    
    // Add name field (combine first and last name)
    // if (_selectedRole == 'user') {
    //   data['name'] = '${firstNameController.text.trim()} ${lastNameController.text.trim()}';
    // }
    if (_selectedRole == 'user') {
      data['name'] = '${firstNameController.text.trim()} ${lastNameController.text.trim()}';
      data['zipcode'] = zipcodeController.text.trim();
      
      // Add base_point from geocoding
      if (_basePoint != null) {
        data['base_point'] = _basePoint!.toJson();
        print('📍 Including base_point: ${_basePoint!.city}, ${_basePoint!.state}');
      }
    } else if (_selectedRole == 'insurance') {
      data['name'] = insuranceProviderController.text.trim();
      // Store additional fields in metadata if needed
      // data['metadata'] = {
      //   'state': stateController.text.trim(),
      //   'original_role': 'insurance'
      // } as String;
      //revert to above if below failing
      data['metadata'] = jsonEncode({
        'state': stateController.text.trim(),
        'original_role': 'insurance'
      });
    } else if (_selectedRole == 'admin') {
      data['name'] = '${firstNameController.text.trim()} ${lastNameController.text.trim()}';
      // data['metadata'] = {
      //   'admin_id': idController.text.trim(),
      //   'server_number': serverNumberController.text.trim(),
      //   'original_role': 'admin'
      // } as String;
      //revert to above if below failing
      data['metadata'] = jsonEncode({
        'admin_id': idController.text.trim(),
        'server_number': serverNumberController.text.trim(),
        'original_role': 'admin'
      });
    }

    print('Sending signup request: $data');

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      await _handleSuccessfulAuth(response.body);
    } else {
      final responseData = await _parseJson(response.body);
      _showErrorDialog(responseData['error'] ?? 'Signup failed');
    }
  }

  // Future<void> _login() async {
  //   //original code
  //   final url = '$server/login';

  //   //new code for my backend
  //   // final url = '$server/auth-user';
  //   // final url = 'https://m9yn8bsm3k.execute-api.us-west-1.amazonaws.com/auth-user';
  //   final data = _buildAuthData();
  //   print(data);

  //   final response = await http.post(
  //     Uri.parse(url),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode(data), 
  //   );

  //   if (response.statusCode == 202) {
  //     await _handleSuccessfulAuth(response.body);
  //   } else {
  //     final responseData = await _parseJson(response.body);
  //     _showErrorDialog(responseData['message'] ?? 'Login failed');
  //   }
  // }


  //uncomment above code if below ufnction version does not wor
  Future<void> _login() async {
    final url = authEndpoint; // Use your Lambda endpoint
    
    // Build data structure matching your backend
    final data = {
      'email': emailController.text.toLowerCase().trim(),
      'password': passwordController.text,
      'mode': 'signin',
    };

    print('Sending login request: $data');

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      await _handleSuccessfulAuth(response.body);
    } else {
      final responseData = await _parseJson(response.body);
      _showErrorDialog(responseData['error'] ?? 'Login failed');
    }
  }

  Map<String, dynamic> _buildAuthData() {
    final data = {
      'email': emailController.text,
      'password': passwordController.text,
      'role': _selectedRole,
      'mode': _isSignupMode ? 'signup' : 'signin',
    };

    if (_selectedRole == 'user') {
      if (_isSignupMode) {
        data.addAll({
          'first_name': firstNameController.text,
          'last_name': lastNameController.text,
        });
      }
    } 
    else if (_selectedRole == 'admin') {
      if (_isSignupMode) {
        data.addAll({
          'first_name': firstNameController.text,
          'last_name': lastNameController.text,
          'admin_id': idController.text,
          'server_number': serverNumberController.text,
        });
      } else {
        data['admin_id'] = idController.text;
        data['server_number'] = serverNumberController.text;
      }
    } 
    else if (_selectedRole == 'insurance') {
      if (_isSignupMode) {
        data.addAll({
          'first_name': insuranceProviderController.text,
          'last_name': stateController.text,
          'password': idController.text,
        });
      } else {
        data['password'] = idController.text;
      }
    }

    return data;
  }

  // Future<void> _handleSuccessfulAuth(String responseBody) async {
  //   final responseData = json.decode(responseBody);
  //   print('responseData: $responseData');
  //   final token = responseData['access_token'];
  //   await _prefs.setString('access_token', token);
  //   final decodedToken = JwtDecoder.decode(token);
  //   final role = decodedToken['role'];
  //   print('role: $role');

  //   if (mounted) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => HomePage(role: role)),
  //     );
  //   }
  //   print(' 222222');
  // }

  // uncomment above code if below ufnction version does not work

  Future<void> _handleSuccessfulAuth(String responseBody) async {
    final responseData = json.decode(responseBody);
    print('Auth response received: ${responseData['message']}');
    
    // Extract user data from your backend response
    final userData = responseData['user_data'];


    // delete below code if failing

    // Parse the name for first_name and last_name
    String fullName = userData['name'] ?? '';
    List<String> nameParts = fullName.split(' ');
    String firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    
    // Create a pseudo-JWT token containing user data
    // (Since your backend doesn't return JWT, we'll create a simple token)
    final tokenData = {
      'user_id': userData['user_id'],
      'email': userData['email'],
      'name': userData['name'],
      //delete below data sections if failing
      'first_name': firstName,
      'last_name': lastName,
      'role': _selectedRole, // Keep original Flutter role for compatibility
      'backend_role': userData['role'], // Store your backend role too
      'exp': DateTime.now().add(Duration(days: 30)).millisecondsSinceEpoch ~/ 1000,

    };
    
    // Encode as simple base64 (not a real JWT, but maintains app structure)
    final token = base64Encode(utf8.encode(json.encode(tokenData)));
    
    await _prefs.setString('access_token', token);
    await _prefs.setString('user_data', json.encode(userData));

    // Phase 4: Store zipcode if available
    if (userData['zipcode'] != null) {
      await _prefs.setString('user_zipcode', userData['zipcode'].toString());
    }

    
    // // Decode for navigation (maintaining existing app flow)
    // final role = _selectedRole; // Use Flutter's role system for navigation
    //revert to above if below causes issues
    // Determine the correct role for navigation
      // String navigationRole = _selectedRole;

      // // Check if this is actually an admin or insurance account from metadata
      // if (userData['role'] == 'provider' && userData['metadata'] != null) {
      //   try {
      //     Map<String, dynamic> metadata;
      //     if (userData['metadata'] is String) {
      //       // If metadata is a JSON string, parse it
      //       metadata = json.decode(userData['metadata']);
      //     } else if (userData['metadata'] is Map) {
      //       // If metadata is already a Map
      //       metadata = userData['metadata'] as Map<String, dynamic>;
      //     } else {
      //       metadata = {};
      //     }
          
      //     print('Metadata parsed: $metadata');
          
      //     if (metadata['original_role'] == 'admin') {
      //       navigationRole = 'admin';
      //     } else if (metadata['original_role'] == 'insurance') {
      //       navigationRole = 'insurance';
      //     }
      //   } catch (e) {
      //     print('Error parsing metadata: $e');
      //     // Default to insurance for providers
      //     navigationRole = 'insurance';
      //   }
      // } else if (userData['role'] == 'driver') {
      //   navigationRole = 'user';
      // }

      // print('Final navigation role: $navigationRole');
      // final role = navigationRole;
      // revert to above if below causes issues
      // Determine the correct role for navigation
      String navigationRole = 'user'; // Default

      // For LOGIN, we need to detect role from backend response
      if (!_isSignupMode) {
        // During login, detect role from backend data
        if (userData['role'] == 'provider') {
          // Check metadata to determine if insurance or admin
          if (userData['metadata'] != null) {
            try {
              Map<String, dynamic> metadata;
              if (userData['metadata'] is String) {
                metadata = json.decode(userData['metadata']);
              } else if (userData['metadata'] is Map) {
                metadata = userData['metadata'] as Map<String, dynamic>;
              } else {
                metadata = {};
              }
              
              if (metadata['original_role'] == 'admin') {
                navigationRole = 'admin';
              } else if (metadata['original_role'] == 'insurance') {
                navigationRole = 'insurance';
              } else {
                navigationRole = 'insurance'; // Default provider to insurance
              }
            } catch (e) {
              print('Error parsing metadata during login: $e');
              navigationRole = 'insurance';
            }
          } else {
            navigationRole = 'insurance'; // Provider without metadata = insurance
          }
        } else if (userData['role'] == 'driver') {
          navigationRole = 'user';
        }
      } else {
        // For SIGNUP, use the selected role with metadata check
        navigationRole = _selectedRole;
        if (userData['role'] == 'provider' && userData['metadata'] != null) {
          try {
            Map<String, dynamic> metadata;
            if (userData['metadata'] is String) {
              metadata = json.decode(userData['metadata']);
            } else if (userData['metadata'] is Map) {
              metadata = userData['metadata'] as Map<String, dynamic>;
            } else {
              metadata = {};
            }
            
            if (metadata['original_role'] == 'admin') {
              navigationRole = 'admin';
            } else if (metadata['original_role'] == 'insurance') {
              navigationRole = 'insurance';
            }
          } catch (e) {
            print('Error parsing metadata during signup: $e');
          }
        }
      }

      print('Login mode: ${!_isSignupMode}, Backend role: ${userData['role']}, Final navigation role: $navigationRole');
      final role = navigationRole;
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(role: role)),
      );
    }
  }

  Future<Map<String, dynamic>> _parseJson(String responseBody) async {
    return await compute((String jsonString) {
      return json.decode(jsonString) as Map<String, dynamic>;
    }, responseBody);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    final maxWidth = isWeb ? 500.0 : double.infinity;
    
    return Scaffold(
      backgroundColor: lightBlue,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: white,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildTabBar(),
                      const SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            _buildTextField('Email', emailController, Icons.email),
                            const SizedBox(height: 20),
                            ..._buildRoleSpecificFields(),
                            const SizedBox(height: 32),
                            _buildAuthButton(),
                            const SizedBox(height: 24),
                            _buildToggleAuthModeButton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          _isSignupMode ? 'Create Account' : 'Welcome Back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isSignupMode 
              ? 'Fill in your details to get started'
              : 'Login to continue to your account',
          style: TextStyle(
            fontSize: 16,
            color: grey,
          ),
        ),
      ],
    );
  }

Widget _buildTabBar() {
  return Container(
    height: 50,
    decoration: BoxDecoration(
      color: lightGrey,
      borderRadius: BorderRadius.circular(12),
    ),
    child: TabBar(
      controller: _tabController,
      tabs: [
        Container(
          alignment: Alignment.center,
          child: Text('Login', style: TextStyle(fontSize: 16)),
        ),
        Container(
          alignment: Alignment.center,
          child: Text('Sign Up', style: TextStyle(fontSize: 16)),
        ),
      ],
      onTap: (index) => setState(() => _isSignupMode = index == 1),
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: primaryBlue,
      ),
      labelColor: white,
      unselectedLabelColor: grey,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorPadding: EdgeInsets.zero,
      labelPadding: EdgeInsets.zero,
    ),
  );
}

  List<Widget> _buildRoleSpecificFields() {
    final fields = <Widget>[];
    
    if (_selectedRole == 'user') {
      if (_isSignupMode) {
        fields.addAll([
          _buildTextField('First Name', firstNameController, Icons.person),
          const SizedBox(height: 16),
          _buildTextField('Last Name', lastNameController, Icons.person),
          const SizedBox(height: 16),
          _buildZipcodeField(),
          const SizedBox(height: 16),
        ]);
      }
      fields.add(_buildTextField('Password', passwordController, Icons.lock));
    } 
    else if (_selectedRole == 'insurance') {
      if (_isSignupMode) {
        fields.addAll([
          _buildTextField('Insurance Name', insuranceProviderController, Icons.business),
          const SizedBox(height: 16),
          _buildTextField('State', stateController, Icons.location_city),
          const SizedBox(height: 16),
        ]);
      }
      fields.add(_buildTextField('ID', idController, Icons.badge));
    } 
    else if (_selectedRole == 'admin') {
      if (_isSignupMode) {
        fields.addAll([
          _buildTextField('First Name', firstNameController, Icons.person),
          const SizedBox(height: 16),
          _buildTextField('Last Name', lastNameController, Icons.person),
          const SizedBox(height: 16),
          _buildTextField('Admin ID', idController, Icons.admin_panel_settings),
          const SizedBox(height: 16),
          _buildTextField('Server Number', serverNumberController, Icons.computer),
          const SizedBox(height: 16),
        ]);
      }
      fields.add(_buildTextField('Password', passwordController, Icons.lock));
    }

    return fields;
  }

 Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: label.toLowerCase().contains('password'),
      style: TextStyle(color: black, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: grey),
        prefixIcon: Icon(icon, color: primaryBlue, size: 24),
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: grey.withAlpha(75)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: grey.withAlpha(75)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildZipcodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: zipcodeController,
          keyboardType: TextInputType.number,
          maxLength: 5,
          style: TextStyle(color: black, fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Zipcode',
            labelStyle: TextStyle(color: grey),
            prefixIcon: Icon(Icons.location_on, color: primaryBlue, size: 24),
            suffixIcon: _isGeocoding
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _zipcodeValid == true && _basePoint != null
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : _zipcodeValid == false
                        ? Icon(Icons.error, color: Colors.red)
                        : null,
            filled: true,
            fillColor: white,
            counterText: '', // Hide the character counter
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: grey.withAlpha(75)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: grey.withAlpha(75)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryBlue, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your zipcode';
            }
            if (value.length != 5) {
              return 'Zipcode must be 5 digits';
            }
            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
              return 'Zipcode must contain only numbers';
            }
            if (_basePoint == null && !_isGeocoding) {
              return 'Unable to verify zipcode';
            }
            return null;
          },
        ),
        // Show resolved location
        if (_basePoint != null && _basePoint!.source != 'fallback')
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green),
                SizedBox(width: 6),
                Text(
                  '${_basePoint!.city}, ${_basePoint!.state}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        if (_isGeocoding)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Text(
              'Verifying zipcode...',
              style: TextStyle(fontSize: 12, color: Colors.blue[600]),
            ),
          ),
      ],
    );
  }


  Widget _buildAuthButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _handleAuth,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: primaryBlue.withAlpha(75),
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: white,
                  strokeWidth: 3,
                ),
              )
            : Text(
                _isSignupMode ? 'Sign Up' : 'Login',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildToggleAuthModeButton() {
    return TextButton(
      onPressed: () {
        setState(() => _isSignupMode = !_isSignupMode);
        _tabController.animateTo(_isSignupMode ? 1 : 0);
      },
      style: TextButton.styleFrom(
        foregroundColor: primaryBlue,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      child: Text(
        _isSignupMode
            ? 'Already have an account? Login'
            : 'Need an account? Sign Up',
        style: const TextStyle(
          fontSize: 16,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
