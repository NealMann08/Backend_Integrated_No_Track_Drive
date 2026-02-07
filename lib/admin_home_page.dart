import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'ipconfig.dart';
import 'geocodingutils.dart';

// AdminHomePage is the main dashboard for administrators, providing:
// - System statistics overview
// - User and insurance company management
// - Server status monitoring
// - Account creation functionality
// Responsively designed for both web and mobile platforms
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  // STATE MANAGEMENT SECTION

  // Admin name for personalized greeting
  String _adminName = '';

  // Quick Stats State - Tracks system-wide statistics
  Map<String, dynamic> _quickStats = {
    'total_users': 0,
    'total_admins': 0,
    'total_insurance': 0,
  };
  bool _isLoadingStats = false;
  String _statsError = '';

  // Insurance Search State - Manages insurance company search functionality
  List<Map<String, dynamic>> _insuranceResults = [];
  bool _isLoadingInsurance = false;
  String _insuranceSearchError = '';
  String _insuranceSearchQuery = '';

  // User Search State - Manages user search functionality
  List<Map<String, dynamic>> _userResults = [];
  bool _isLoadingUsers = false;
  String _userSearchError = '';
  String _userSearchQuery = '';

  // Account Creation State - Manages form state for new account creation
  final _createAccountFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Driver-specific controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _zipcodeController = TextEditingController();  // ✅ Dedicated zipcode controller
  bool _isGeocodingZipcode = false;
  bool? _zipcodeValidAdmin;
  CityCoordinates? _basePointAdmin;

  // Admin-specific controllers
  final _adminIdController = TextEditingController();
  final _serverNumberController = TextEditingController();

  // ISP-specific controllers
  final _companyNameController = TextEditingController();
  final _stateController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _licenseNumberController = TextEditingController();

  String _selectedRole = 'user'; // Default role selection
  bool _isCreatingAccount = false;
  String _createAccountError = '';

  // Web-specific hover states for interactive elements
  bool _isHoveringCreateAccount = false;
  bool _isHoveringSearchUsers = false;
  bool _isHoveringSearchInsurance = false;
  bool _isHoveringAnalytics = false;

  // LIFECYCLE METHODS

  @override
  void initState() {
    super.initState();
    // Load initial data when widget is created
    _loadAdminName();
    _fetchQuickStats();
    // Add listener for zipcode geocoding when creating drivers
    _zipcodeController.addListener(_onAdminZipcodeChanged);  // ✅ Use dedicated controller
  }

  Future<void> _loadAdminName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataStr = prefs.getString('user_data');
      if (userDataStr != null) {
        final userData = jsonDecode(userDataStr);
        final name = userData['name'] ?? '';
        if (name.isNotEmpty && mounted) {
          setState(() {
            _adminName = name.split(' ').first;
          });
        }
      }
    } catch (e) {
      print('Could not load admin name: $e');
    }
  }

  // Debounced zipcode geocoding for admin creating drivers
  void _onAdminZipcodeChanged() {
    if (_selectedRole != 'user') return;

    final zipcode = _zipcodeController.text.trim();  // ✅ Use dedicated controller
    
    if (zipcode.isEmpty) {
      setState(() {
        _zipcodeValidAdmin = null;
        _basePointAdmin = null;
      });
      return;
    }
    
    final isValid = validateZipcode(zipcode);
    setState(() {
      _zipcodeValidAdmin = isValid;
    });
    
    if (isValid && zipcode.length == 5) {
      Future.delayed(Duration(milliseconds: 800), () {
        if (_zipcodeController.text.trim() == zipcode) {  // ✅ Use dedicated controller
          _performAdminGeocoding(zipcode);
        }
      });
    } else {
      setState(() {
        _basePointAdmin = null;
      });
    }
  }

  Future<void> _performAdminGeocoding(String zipcode) async {
    if (_isGeocodingZipcode) return;
    
    setState(() {
      _isGeocodingZipcode = true;
    });
    
    try {
      final coordinates = await getCityCoordinatesFromZipcode(zipcode);
      setState(() {
        _basePointAdmin = coordinates;
      });
      print('🎯 Admin: Base point set: ${coordinates.city}, ${coordinates.state}');
    } catch (error) {
      print('❌ Admin: Geocoding error: $error');
      setState(() {
        _basePointAdmin = null;
      });
    } finally {
      setState(() {
        _isGeocodingZipcode = false;
      });
    }
  }

  @override
  void dispose() {
    _zipcodeController.removeListener(_onAdminZipcodeChanged);
    // Clean up all controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _zipcodeController.dispose();
    _adminIdController.dispose();
    _serverNumberController.dispose();
    // ISP controllers
    _companyNameController.dispose();
    _stateController.dispose();
    _contactPersonController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  // MAIN BUILD METHOD

  @override
  Widget build(BuildContext context) {
    // Responsive layout calculations
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800;

    return Scaffold(
      // Web-specific app bar
      appBar: isWeb ? _buildWebAppBar() : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(isWeb ? 24 : 12),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 1400,
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mobile-only welcome card
                    if (!isWeb) _buildWelcomeCard(isWeb: isWeb),
                    SizedBox(height: isLargeScreen ? 32 : 16),
                    // Quick stats display
                    _buildQuickStatsRow(),
                    SizedBox(height: isLargeScreen ? 32 : 16),
                    // Platform-specific dashboard layout
                    if (isWeb)
                      _buildWebDashboard(isLargeScreen, isMediumScreen)
                    else
                      _buildMobileDashboard(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // WEB-SPECIFIC COMPONENTS SECTION

  // Builds the web-specific app bar with admin controls
  AppBar _buildWebAppBar() {
    return AppBar(
      title: Row(
        children: [
          Icon(Icons.admin_panel_settings, size: 32),
          SizedBox(width: 12),
          Text(
            _adminName.isNotEmpty ? 'Welcome, $_adminName' : 'Admin Dashboard',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
      elevation: 4,
      actions: [
        // Refresh data button
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {
            _fetchQuickStats();
          },
          tooltip: 'Refresh Data',
        ),
        // Logout button
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: _logout,
          tooltip: 'Logout',
        ),
      ],
    );
  }

  // Builds the web dashboard layout with responsive grid
  Widget _buildWebDashboard(bool isLargeScreen, bool isMediumScreen) {
    final cardSpacing = isLargeScreen ? 24.0 : 16.0;
    final cardHeight = isLargeScreen ? 220.0 : 180.0;

    return Column(
      children: [
        // Action cards grid
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: isLargeScreen ? 4 : (isMediumScreen ? 2 : 1),
          childAspectRatio: isLargeScreen ? 1.2 : 1.5,
          crossAxisSpacing: cardSpacing,
          mainAxisSpacing: cardSpacing,
          padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 24 : 0),
          children: [
            _buildAdminActionCard(
              icon: Icons.person_add,
              title: 'Create Account',
              description: 'Register new users, admins, or insurance companies',
              color: Colors.blue,
              onTap: () => _showCreateAccountModal(),
              isWeb: true,
              isHovering: _isHoveringCreateAccount,
              onHover: (hovering) => setState(() => _isHoveringCreateAccount = hovering),
              height: cardHeight,
            ),
            _buildAdminActionCard(
              icon: Icons.search,
              title: 'Search Users',
              description: 'Find and manage user accounts',
              color: Colors.green,
              onTap: () => _showUserSearch(),
              isWeb: true,
              isHovering: _isHoveringSearchUsers,
              onHover: (hovering) => setState(() => _isHoveringSearchUsers = hovering),
              height: cardHeight,
            ),
            _buildAdminActionCard(
              icon: Icons.business,
              title: 'Search Insurance',
              description: 'Manage insurance company accounts',
              color: Colors.orange,
              onTap: () => _showInsuranceSearch(),
              isWeb: true,
              isHovering: _isHoveringSearchInsurance,
              onHover: (hovering) => setState(() => _isHoveringSearchInsurance = hovering),
              height: cardHeight,
            ),
            _buildAdminActionCard(
              icon: Icons.analytics,
              title: 'View Analytics',
              description: 'System usage and activity reports',
              color: Colors.purple,
              onTap: () => _showAnalytics(),
              isWeb: true,
              isHovering: _isHoveringAnalytics,
              onHover: (hovering) => setState(() => _isHoveringAnalytics = hovering),
              height: cardHeight,
            ),
          ],
        ),
      ],
    );
  }

  String _formatRelativeTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoString);
      final now = DateTime.now().toUtc();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${(diff.inDays / 7).floor()}w ago';
    } catch (_) {
      return '';
    }
  }

  // MOBILE COMPONENTS SECTION

  // Builds the mobile-optimized dashboard layout
  Widget _buildMobileDashboard() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      padding: EdgeInsets.symmetric(horizontal: 8),
      children: _buildActionCards(),
    );
  }

  // Generates action cards for mobile view
  List<Widget> _buildActionCards() {
    return [
      _buildAdminActionCard(
        icon: Icons.person_add,
        title: 'Create Account',
        description: 'Register new users',
        color: Colors.blue,
        onTap: () => _showCreateAccountModal(),
        isWeb: false,
      ),
      _buildAdminActionCard(
        icon: Icons.search,
        title: 'Search Users',
        description: 'Find user accounts',
        color: Colors.green,
        onTap: () => _showUserSearch(),
        isWeb: false,
      ),
      _buildAdminActionCard(
        icon: Icons.business,
        title: 'Search Insurance',
        description: 'Manage companies',
        color: Colors.orange,
        onTap: () => _showInsuranceSearch(),
        isWeb: false,
      ),
      _buildAdminActionCard(
        icon: Icons.analytics,
        title: 'Analytics',
        description: 'View reports',
        color: Colors.purple,
        onTap: () => _showAnalytics(),
        isWeb: false,
      ),
    ];
  }

  // SHARED COMPONENTS SECTION

  // Builds a reusable admin action card component
  Widget _buildAdminActionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
    required bool isWeb,
    bool isHovering = false,
    Function(bool)? onHover,
    double? height,
  }) {
    final isLargeScreen = MediaQuery.of(context).size.width > 800;

    return MouseRegion(
      onEnter: onHover != null ? (_) => onHover(true) : null,
      onExit: onHover != null ? (_) => onHover(false) : null,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: isWeb ? (isHovering ? 8 : 4) : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isWeb && isHovering ? color.withOpacity(0.05) : Colors.white,
              border: isWeb && isHovering
                  ? Border.all(color: color.withOpacity(0.3), width: 1)
                  : null,
            ),
            padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon container
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                SizedBox(height: 12),
                // Title text
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isLargeScreen ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                // Description text
                Expanded(
                  child: Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isLargeScreen ? 14 : 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Web-specific forward arrow indicator
                if (isWeb) ...[
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(
                      Icons.arrow_forward,
                      color: isHovering ? color : Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // DATA DISPLAY COMPONENTS SECTION

  // Builds the quick stats row showing system metrics
  Widget _buildQuickStatsRow() {
    if (_isLoadingStats) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_statsError.isNotEmpty) {
      return Card(
        child: Padding(padding: EdgeInsets.all(24), child: Text(_statsError)),
      );
    }

    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1000;
    final maxStatWidth = isWeb ? 1200.0 : 800.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxStatWidth),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 24,
              horizontal: isLargeScreen ? 40 : 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  Icons.people,
                  'Total Users',
                  _quickStats['total_users'].toString(),
                  Colors.blue,
                  isLargeScreen,
                ),
                _buildStatItem(
                  Icons.admin_panel_settings,
                  'Total Admins',
                  _quickStats['total_admins'].toString(),
                  Colors.green,
                  isLargeScreen,
                ),
                _buildStatItem(
                  Icons.business,
                  'Insurance Cos',
                  _quickStats['total_insurance'].toString(),
                  Colors.orange,
                  isLargeScreen,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builds the welcome card for mobile view
  Widget _buildWelcomeCard({required bool isWeb}) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: double.infinity),
      child: Card(
        elevation: isWeb ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
        ),
        child: Container(
          padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade700, Colors.blue.shade400],
            ),
            borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.dashboard,
                size: isLargeScreen ? 48 : 36,
                color: Colors.white,
              ),
              SizedBox(width: isLargeScreen ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _adminName.isNotEmpty ? 'Welcome, $_adminName' : 'Admin Dashboard',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: isLargeScreen ? 8 : 4),
                    Text(
                      'Manage users, insurance companies, and system status',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 16 : 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UTILITY COMPONENTS SECTION

  // Builds a statistic display item with icon
  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
    bool isLarge,
  ) {
    final iconSize = isLarge ? 36.0 : 28.0;
    final numberSize = isLarge ? 28.0 : 22.0;
    final labelSize = isLarge ? 16.0 : 14.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon container
        Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: iconSize),
        ),
        SizedBox(height: 12),
        // Value display
        Text(
          value,
          style: TextStyle(fontSize: numberSize, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 6),
        // Label display
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: labelSize),
        ),
      ],
    );
  }

  // MODAL DIALOGS SECTION

  // Shows the account creation modal (platform-specific)
  void _showCreateAccountModal() {
    final isWeb = kIsWeb;

    if (isWeb) {
      showDialog(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, dialogSetState) => Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 600,
                maxHeight: MediaQuery.of(dialogContext).size.height * 0.9,
              ),
              child: Dialog(
                insetPadding: EdgeInsets.all(20),
                child: _buildCreateAccountForm(dialogSetState),
              ),
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, dialogSetState) => Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.9,
            ),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: _buildCreateAccountForm(dialogSetState),
                );
              },
            ),
          ),
        ),
      );
    }
  }

  // Builds the account creation form with role-specific fields
  Widget _buildCreateAccountForm(StateSetter dialogSetState) {
    final isWeb = kIsWeb;
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
      ),
      padding: EdgeInsets.all(isWeb ? 24 : 16),
      child: SingleChildScrollView(
        child: Form(
          key: _createAccountFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create New Account',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 22 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Role selection dropdown
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 93, 175, 233),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Account Type',
                  labelStyle: TextStyle(color: Colors.blue[800], fontSize: 14),
                ),
                style: TextStyle(fontSize: 14),
                dropdownColor: const Color.fromARGB(255, 93, 175, 233),
                icon: Icon(Icons.arrow_drop_down, color: Colors.blue[800]),
                items: [
                  DropdownMenuItem(value: 'user', child: Text('User Account')),
                  DropdownMenuItem(
                    value: 'insurance',
                    child: Text('Insurance Company'),
                  ),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Admin Account'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  // Update parent state
                  _selectedRole = value;
                  _emailController.clear();
                  _passwordController.clear();
                  _firstNameController.clear();
                  _lastNameController.clear();
                  _zipcodeController.clear();
                  _adminIdController.clear();
                  _serverNumberController.clear();
                  _companyNameController.clear();
                  _stateController.clear();
                  _contactPersonController.clear();
                  _contactEmailController.clear();
                  _contactPhoneController.clear();
                  _licenseNumberController.clear();
                  _basePointAdmin = null;
                  _zipcodeValidAdmin = null;
                  _createAccountError = '';

                  // Rebuild the dialog UI
                  dialogSetState(() {});
                },
              ),
            ),
            SizedBox(height: 16),

            // Dynamic form fields based on selected role
            Column(
              key: ValueKey('role_fields_$_selectedRole'),
              children: [
                // Common fields (email and password)
                _buildFormField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),

                _buildFormField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),

                // Role-specific fields
                // if (_selectedRole == 'user') ...[
                //   _buildFormField(
                //     controller: _firstNameController,
                //     label: 'First Name',
                //     icon: Icons.person,
                //     validator: (value) {
                //       if (value == null || value.isEmpty) {
                //         return 'Please enter first name';
                //       }
                //       return null;
                //     },
                //   ),
                //   SizedBox(height: 12),
                //   _buildFormField(
                //     controller: _lastNameController,
                //     label: 'Last Name',
                //     icon: Icons.person_outline,
                //     validator: (value) {
                //       if (value == null || value.isEmpty) {
                //         return 'Please enter last name';
                //       }
                //       return null;
                //     },
                //   ),
                // ],
                // ✅ DRIVER FIELDS (Clean and proper)
                if (_selectedRole == 'user') ...[
                  _buildFormField(
                    controller: _firstNameController,
                    label: 'First Name',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter first name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  _buildFormField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter last name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormField(
                        controller: _zipcodeController,  // ✅ Dedicated zipcode controller
                        label: 'Zipcode',
                        icon: Icons.location_on,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter zipcode';
                          }
                          if (value.length != 5 || !RegExp(r'^\d+$').hasMatch(value)) {
                            return 'Please enter a valid 5-digit zipcode';
                          }
                          if (_basePointAdmin == null && !_isGeocodingZipcode) {
                            return 'Unable to verify zipcode';
                          }
                          return null;
                        },
                      ),
                      // Show resolved location
                      if (_basePointAdmin != null && _basePointAdmin!.source != 'fallback')
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 14, color: Colors.green),
                              SizedBox(width: 6),
                              Text(
                                '📍 ${_basePointAdmin!.city}, ${_basePointAdmin!.state}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_isGeocodingZipcode)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Verifying zipcode...',
                                style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],

                // ✅ ISP FIELDS (Complete and proper)
                if (_selectedRole == 'insurance') ...[
                  _buildFormField(
                    controller: _companyNameController,
                    label: 'Company Name',
                    icon: Icons.business,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter company name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  _buildFormField(
                    controller: _stateController,
                    label: 'Primary State',
                    icon: Icons.location_city,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter state';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  _buildFormField(
                    controller: _contactPersonController,
                    label: 'Contact Person Name',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter contact person name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  _buildFormField(
                    controller: _contactEmailController,
                    label: 'Contact Email',
                    icon: Icons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter contact email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  _buildFormField(
                    controller: _contactPhoneController,
                    label: 'Contact Phone',
                    icon: Icons.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter contact phone';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  _buildFormField(
                    controller: _licenseNumberController,
                    label: 'Insurance License Number',
                    icon: Icons.verified,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter license number';
                      }
                      return null;
                    },
                  ),
                ],
                if (_selectedRole == 'admin') ...[
                  _buildFormField(
                    controller: _firstNameController,
                    label: 'First Name',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter first name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  _buildFormField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter last name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  _buildFormField(
                    controller: _adminIdController,
                    label: 'Admin ID',
                    icon: Icons.admin_panel_settings,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter admin ID';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  _buildFormField(
                    controller: _serverNumberController,
                    label: 'Server Number',
                    icon: Icons.computer,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter server number';
                      }
                      return null;
                    },
                  ),
                ],
              ],
            ),
            SizedBox(height: 16),

            // Error message display
            if (_createAccountError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  _createAccountError,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isCreatingAccount ? null : _createAccount,
                child: _isCreatingAccount
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  // Builds a reusable form field with consistent styling
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    required String? Function(String?)? validator,
  }) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(color: Colors.black, fontSize: isLargeScreen ? 16 : 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        prefixIcon: Icon(icon, color: Colors.blue[800]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[800]!, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red[400]!),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: isLargeScreen ? 16 : 14,
          horizontal: 16,
        ),
      ),
    );
  }

  // Shows the user search modal (platform-specific)
  void _showUserSearch() {
    final isWeb = kIsWeb;

    if (isWeb) {
      showDialog(
        context: context,
        builder: (context) => Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Dialog(
              insetPadding: EdgeInsets.all(20),
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  return _buildUserSearchForm(setModalState);
                },
              ),
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.8,
                minChildSize: 0.5,
                maxChildSize: 0.95,
                builder: (context, scrollController) {
                  return SingleChildScrollView(
                    controller: scrollController,
                    child: _buildUserSearchForm(setModalState),
                  );
                },
              );
            },
          );
        },
      );
    }
  }

  // Shows detailed user information dialog
  // void _showUserDetailsDialog(Map<String, dynamic> user) {
  //   final isWeb = kIsWeb;
  //   final maxDialogWidth = isWeb ? 500.0 : double.infinity;

  //   showDialog(
  //     context: context,
  //     builder: (context) => Dialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(16),
  //       ),
  //       insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
  //       child: ConstrainedBox(
  //         constraints: BoxConstraints(maxWidth: maxDialogWidth),
  //         child: Padding(
  //           padding: const EdgeInsets.all(24.0),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               // User header with avatar
  //               Row(
  //                 children: [
  //                   CircleAvatar(
  //                     radius: 28,
  //                     backgroundColor: Colors.blue[100],
  //                     child: Icon(
  //                       Icons.person,
  //                       color: Colors.blue[700],
  //                       size: 30,
  //                     ),
  //                   ),
  //                   SizedBox(width: 16),
  //                   Expanded(
  //                     child: Text(
  //                       '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}',
  //                       style: TextStyle(
  //                         fontSize: 20,
  //                         fontWeight: FontWeight.bold,
  //                         color: Colors.blue[900],
  //                       ),
  //                     ),
  //                   ),
  //                   IconButton(
  //                     icon: Icon(Icons.close),
  //                     onPressed: () => Navigator.pop(context),
  //                   ),
  //                 ],
  //               ),
  //               SizedBox(height: 16),
  //               Divider(),
  //               SizedBox(height: 8),
  //               // User details rows
  //               _buildUserDetailRow('Email', user['email']),
  //               _buildUserDetailRow('Role', user['role']),
  //               _buildUserDetailRow('User ID', user['user_id']),
  //               if (user.containsKey('policy_number'))
  //                 _buildUserDetailRow('Policy Number', user['policy_number']),
  //               SizedBox(height: 20),
  //               // Close button
  //               Align(
  //                 alignment: Alignment.centerRight,
  //                 child: TextButton.icon(
  //                   onPressed: () => Navigator.pop(context),
  //                   icon: Icon(Icons.check),
  //                   label: Text('Close'),
  //                   style: TextButton.styleFrom(
  //                     foregroundColor: Colors.blue[800],
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  // Shows user details dialog, fetching analytics for drivers on-demand
  void _showUserDetailsDialog(Map<String, dynamic> user) {
    final isWeb = kIsWeb;
    final maxDialogWidth = isWeb ? 800.0 : double.infinity;
    final isDriver = user['role'] == 'driver';
    final isProvider = user['role'] == 'provider';

    // Display name: use company name for providers, full name for drivers
    String displayName;
    if (isProvider) {
      // Try metadata first for company name, fall back to first+last
      String? companyName;
      if (user['metadata'] != null) {
        try {
          final meta = user['metadata'] is String ? jsonDecode(user['metadata']) : user['metadata'];
          companyName = meta['company_name'];
        } catch (_) {}
      }
      displayName = companyName ?? '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    } else {
      displayName = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        // Analytics state managed inside the dialog
        Map<String, dynamic>? analytics;
        bool isLoadingAnalytics = isDriver; // Start loading immediately for drivers
        String analyticsError = '';

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            // Fetch analytics for drivers on first build
            if (isDriver && analytics == null && isLoadingAnalytics && analyticsError.isEmpty) {
              _fetchUserAnalytics(user['email']).then((data) {
                if (dialogContext.mounted) {
                  setDialogState(() {
                    analytics = data;
                    isLoadingAnalytics = false;
                  });
                }
              }).catchError((e) {
                if (dialogContext.mounted) {
                  setDialogState(() {
                    analyticsError = e.toString().replaceAll('Exception: ', '');
                    isLoadingAnalytics = false;
                  });
                }
              });
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxDialogWidth, maxHeight: 600),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User header with avatar
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: isProvider ? Colors.orange[100] : Colors.blue[100],
                              child: Icon(
                                isProvider ? Icons.business : Icons.person,
                                color: isProvider ? Colors.orange[700] : Colors.blue[700],
                                size: 30,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                  if (analytics != null && analytics!['overall_behavior_score'] != null)
                                    Container(
                                      margin: EdgeInsets.only(top: 4),
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (analytics!['overall_behavior_score'] as num) >= 80 ? Colors.green[100] :
                                              (analytics!['overall_behavior_score'] as num) >= 60 ? Colors.orange[100] : Colors.red[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Score: ${(analytics!['overall_behavior_score'] as num).toInt()}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: (analytics!['overall_behavior_score'] as num) >= 80 ? Colors.green[800] :
                                                (analytics!['overall_behavior_score'] as num) >= 60 ? Colors.orange[800] : Colors.red[800],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => Navigator.pop(dialogContext),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Divider(),
                        SizedBox(height: 8),

                        // Basic user details
                        _buildUserDetailRow('Email', user['email']),
                        _buildUserDetailRow('Role', user['role']),
                        _buildUserDetailRow('User ID', user['user_id']),
                        if (user['created_at'] != null && user['created_at'].toString().isNotEmpty)
                          _buildUserDetailRow('Joined', _formatRelativeTime(user['created_at'])),

                        // Provider-specific metadata
                        if (isProvider && user['metadata'] != null) ...[
                          SizedBox(height: 16),
                          Text('Company Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange[900])),
                          SizedBox(height: 8),
                          Builder(builder: (context) {
                            try {
                              final meta = user['metadata'] is String ? jsonDecode(user['metadata']) : user['metadata'];
                              return Column(
                                children: [
                                  if (meta['state'] != null) _buildUserDetailRow('State', meta['state']),
                                  if (meta['contact_person'] != null) _buildUserDetailRow('Contact', meta['contact_person']),
                                  if (meta['contact_email'] != null) _buildUserDetailRow('Contact Email', meta['contact_email']),
                                  if (meta['contact_phone'] != null) _buildUserDetailRow('Phone', meta['contact_phone']),
                                  if (meta['license_number'] != null) _buildUserDetailRow('License #', meta['license_number']),
                                ],
                              );
                            } catch (_) {
                              return SizedBox.shrink();
                            }
                          }),
                        ],

                        // Driver analytics section
                        if (isDriver) ...[
                          SizedBox(height: 16),
                          Text('Driver Analytics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                          SizedBox(height: 8),
                          if (isLoadingAnalytics)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 8),
                                  Text('Loading driver analytics...', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                ],
                              )),
                            )
                          else if (analyticsError.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                analytics == null ? 'No trips analyzed yet' : 'Error: $analyticsError',
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              ),
                            )
                          else if (analytics != null) ...[
                            _buildUserDetailRow('Behavior Score', '${(analytics!['overall_behavior_score'] as num?)?.toInt() ?? 0}/100'),
                            _buildUserDetailRow('Total Trips', analytics!['total_trips']?.toString() ?? '0'),
                            _buildUserDetailRow('Total Distance', '${(analytics!['total_distance_miles'] as num?)?.toStringAsFixed(1) ?? '0'} miles'),
                            _buildUserDetailRow('Risk Level', analytics!['risk_level'] ?? 'Unknown'),
                            _buildUserDetailRow('Avg Speed', '${(analytics!['overall_moving_avg_speed_mph'] as num?)?.toStringAsFixed(1) ?? '0'} mph'),
                            _buildUserDetailRow('Harsh Events/100mi', analytics!['harsh_events_per_100_miles']?.toStringAsFixed(1) ?? '0'),

                            if (analytics!['trips'] != null && (analytics!['trips'] as List).isNotEmpty) ...[
                              SizedBox(height: 16),
                              Text('Recent Trips', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                              SizedBox(height: 8),
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListView.builder(
                                  itemCount: (analytics!['trips'] as List).take(5).length,
                                  itemBuilder: (context, index) {
                                    var trip = (analytics!['trips'] as List)[index];
                                    return ListTile(
                                      dense: true,
                                      title: Text('Trip ${index + 1}', style: TextStyle(fontSize: 13)),
                                      subtitle: Text(
                                        'Distance: ${(trip['total_distance_miles'] as num?)?.toStringAsFixed(1) ?? '0'} mi | Score: ${(trip['behavior_score'] as num?)?.toInt() ?? 0}',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                      trailing: Text(
                                        trip['start_timestamp'] != null
                                          ? trip['start_timestamp'].toString().substring(0, 10)
                                          : '',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ],

                        SizedBox(height: 20),
                        // Close button
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: Icon(Icons.check),
                            label: Text('Close'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Fetches analytics for a specific user by email from the analyze-driver endpoint
  Future<Map<String, dynamic>> _fetchUserAnalytics(String email) async {
    final response = await http.get(
      Uri.parse('${AppConfig.server}/analyze-driver?email=$email'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load analytics');
    }
  }

  // Builds a user detail row for the details dialog
  Widget _buildUserDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Builds the user search form with results display
  Widget _buildUserSearchForm([void Function(VoidCallback fn)? setModalState]) {
    final isWeb = kIsWeb;
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(isWeb ? 20 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isWeb ? 16 : 12),
            topRight: Radius.circular(isWeb ? 16 : 12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search Users',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 20 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Search input
            TextField(
              decoration: InputDecoration(
                labelText: 'Search by email address',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _searchUsers(setModalState, context),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
              ),
              onChanged: (value) => _userSearchQuery = value,
              onSubmitted: (value) {
                _userSearchQuery = value;
                if (setModalState != null) {
                  _searchUsers(setModalState);
                } else {
                  _searchUsers();
                }
              },
            ),
            SizedBox(height: 16),
            // Results display
            Builder(
              builder: (context) {
                if (_isLoadingUsers) {
                  return Center(child: CircularProgressIndicator());
                } else if (_userSearchError.isNotEmpty) {
                  return Text(
                    _userSearchError,
                    style: TextStyle(color: Colors.red),
                  );
                } else if (_userResults.isEmpty && _userSearchQuery.isNotEmpty) {
                  return Text('No users found matching "$_userSearchQuery".');
                } else {
                  return _buildUserList();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Builds the list of user search results
  Widget _buildUserList() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _userResults.length,
        separatorBuilder: (_, __) => SizedBox(height: 8),
        itemBuilder: (context, index) {
          final user = _userResults[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: CircleAvatar(
                backgroundColor: Colors.green[100],
                child: Icon(Icons.person, color: Colors.green[800]),
              ),
              title: Text(
                '${user['first_name']} ${user['last_name']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    user['email'],
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    'Role: ${user['role'] ?? 'N/A'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () => _showUserDetailsDialog(user),
            ),
          );
        },
      ),
    );
  }

  // Shows the insurance search modal (platform-specific)
  void _showInsuranceSearch() {
    final isWeb = kIsWeb;

    if (isWeb) {
      showDialog(
        context: context,
        builder: (context) => Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Dialog(
              insetPadding: EdgeInsets.all(20),
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  return _buildInsuranceSearchForm(setModalState);
                },
              ),
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.8,
                minChildSize: 0.5,
                maxChildSize: 0.95,
                builder: (context, scrollController) {
                  return SingleChildScrollView(
                    controller: scrollController,
                    child: _buildInsuranceSearchForm(setModalState),
                  );
                },
              );
            },
          );
        },
      );
    }
  }

  // Builds the insurance search form with results display
  Widget _buildInsuranceSearchForm([
    void Function(VoidCallback fn)? setModalState,
  ]) {
    final isWeb = kIsWeb;
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(isWeb ? 20 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isWeb ? 16 : 12),
            topRight: Radius.circular(isWeb ? 16 : 12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search Insurance Users',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 20 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Search input
            TextField(
              decoration: InputDecoration(
                labelText: 'Search by email address',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _searchInsurance(setModalState, context),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
              ),
              onChanged: (value) => _insuranceSearchQuery = value,
              onSubmitted: (value) {
                _insuranceSearchQuery = value;
                _searchInsurance(setModalState, context);
              },
            ),
            SizedBox(height: 16),
            // Results display
            Builder(
              builder: (context) {
                if (_isLoadingInsurance) {
                  return Center(child: CircularProgressIndicator());
                } else if (_insuranceSearchError.isNotEmpty) {
                  return Text(
                    _insuranceSearchError,
                    style: TextStyle(color: Colors.red),
                  );
                } else if (_insuranceResults.isEmpty &&
                    _insuranceSearchQuery.isNotEmpty) {
                  return Text('No users found for "$_insuranceSearchQuery".');
                } else {
                  return _buildInsuranceUserList();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Builds the list of insurance search results
  Widget _buildInsuranceUserList() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _insuranceResults.length,
        separatorBuilder: (_, __) => SizedBox(height: 8),
        itemBuilder: (context, index) {
          final user = _insuranceResults[index];

          // Get company name from metadata (preferred) or fall back to name fields
          String companyName = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
          if (user['metadata'] != null) {
            try {
              final meta = user['metadata'] is String ? jsonDecode(user['metadata']) : user['metadata'];
              if (meta['company_name'] != null && meta['company_name'].toString().isNotEmpty) {
                companyName = meta['company_name'];
              }
            } catch (_) {}
          }

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: CircleAvatar(
                backgroundColor: Colors.orange[100],
                child: Icon(Icons.business, color: Colors.orange[800]),
              ),
              title: Text(
                companyName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    user['email'],
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    'Insurance Provider',
                    style: TextStyle(color: Colors.orange[700], fontSize: 12),
                  ),
                ],
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () => _showUserDetailsDialog(user),
            ),
          );
        },
      ),
    );
  }

  // Shows the analytics modal (platform-specific)
  void _showAnalytics() {
    final isWeb = kIsWeb;
    // Refresh stats when opening analytics
    _fetchQuickStats();

    if (isWeb) {
      showDialog(
        context: context,
        builder: (context) => Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 800,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: Dialog(
              insetPadding: EdgeInsets.all(20),
              child: _buildAnalyticsDashboard(),
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: _buildAnalyticsDashboard(),
            );
          },
        ),
      );
    }
  }

  // Builds the analytics dashboard content
  Widget _buildAnalyticsDashboard() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1000;

    return Container(
      padding: EdgeInsets.all(isWeb ? 24.0 : 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isWeb ? 16 : 12),
          topRight: Radius.circular(isWeb ? 16 : 12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'System Analytics',
                style: TextStyle(
                  fontSize: isLargeScreen ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 24 : 16),
          // User statistics card
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'User Statistics',
                        style: TextStyle(
                          fontSize: isLargeScreen ? 20 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isLoadingStats)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (_statsError.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Error loading stats: $_statsError',
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          Icons.people,
                          'Total Users',
                          _quickStats['total_users'].toString(),
                          Colors.blue,
                          isLargeScreen,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          Icons.admin_panel_settings,
                          'Admins',
                          _quickStats['total_admins'].toString(),
                          Colors.green,
                          isLargeScreen,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          Icons.business,
                          'Insurance',
                          _quickStats['total_insurance'].toString(),
                          Colors.orange,
                          isLargeScreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isLargeScreen ? 24 : 16),
          // Recent signup activity card
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Signup Activity',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 20 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Builder(builder: (context) {
                    final recentSignups = (_quickStats['recent_signups'] as List?)
                        ?.cast<Map<String, dynamic>>() ?? [];
                    if (recentSignups.isEmpty) {
                      return Container(
                        height: 100,
                        child: Center(child: Text('No recent signups')),
                      );
                    }
                    return Column(
                      children: recentSignups.map((signup) {
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: signup['role'] == 'admin'
                                ? Colors.green[100]
                                : signup['role'] == 'provider'
                                    ? Colors.orange[100]
                                    : Colors.blue[100],
                            child: Icon(
                              signup['role'] == 'admin'
                                  ? Icons.admin_panel_settings
                                  : signup['role'] == 'provider'
                                      ? Icons.business
                                      : Icons.person,
                              size: 16,
                              color: signup['role'] == 'admin'
                                  ? Colors.green[800]
                                  : signup['role'] == 'provider'
                                      ? Colors.orange[800]
                                      : Colors.blue[800],
                            ),
                          ),
                          title: Text(
                            signup['name']?.isNotEmpty == true
                                ? signup['name']
                                : signup['email'] ?? '',
                            style: TextStyle(fontSize: 14),
                          ),
                          subtitle: Text(
                            '${signup['role'] ?? ''} - ${_formatRelativeTime(signup['created_at'])}',
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: Text(
                            signup['email'] ?? '',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
          SizedBox(height: isLargeScreen ? 24 : 16),
          if (isWeb) SizedBox(height: 24),
        ],
      ),
    );
  }

  // DATA METHODS SECTION

  // Fetches quick stats from the server
  Future<void> _fetchQuickStats() async {
    setState(() {
      _isLoadingStats = true;
      _statsError = '';
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.server}/auth-user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mode': 'admin_stats'}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _quickStats = {
            'total_users': data['total_users'] ?? 0,
            'total_admins': data['total_admins'] ?? 0,
            'total_insurance': data['total_insurance'] ?? 0,
            'recent_signups': data['recent_signups'] ?? [],
            'role_breakdown': data['role_breakdown'] ?? {},
          };
        });
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _statsError = 'Failed to load stats: $e';
      });
    } finally {
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  void _searchUsers([
    void Function(VoidCallback fn)? modalSetState,
    BuildContext? context,
  ]) async {
    if (context != null) FocusScope.of(context).unfocus();
    final setStateFn = modalSetState ?? setState;

    setStateFn(() {
      _isLoadingUsers = true;
      _userSearchError = '';
      _userResults = [];
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.server}/auth-user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mode': 'search_users',
          'query': _userSearchQuery.trim().toLowerCase(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = data['users'] as List? ?? [];
        setStateFn(() {
          _userResults = List<Map<String, dynamic>>.from(users);
        });
      } else {
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['error'] ?? 'Search failed';
        throw Exception(errorMsg);
      }
    } catch (e) {
      setStateFn(() {
        _userSearchError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setStateFn(() {
        _isLoadingUsers = false;
      });
    }
  }

  // Searches for insurance users based on query
  Future<void> _searchInsurance([
    void Function(VoidCallback fn)? modalSetState,
    BuildContext? context,
  ]) async {
    if (context != null) FocusScope.of(context).unfocus();

    final setStateFn = modalSetState ?? setState;

    setStateFn(() {
      _isLoadingInsurance = true;
      _insuranceSearchError = '';
      _insuranceResults = [];
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.server}/auth-user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mode': 'search_users',
          'query': _insuranceSearchQuery.trim().toLowerCase(),
          'role_filter': 'provider',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = data['users'] as List? ?? [];
        setStateFn(() {
          _insuranceResults = List<Map<String, dynamic>>.from(users);
        });
      } else {
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['error'] ?? 'Search failed';
        throw Exception(errorMsg);
      }
    } catch (e) {
      setStateFn(() {
        _insuranceSearchError = 'Search failed: ${e.toString()}';
      });
    } finally {
      setStateFn(() {
        _isLoadingInsurance = false;
      });
    }
  }

  // Creates a new account with form data
  // Future<void> _createAccount() async {
  //   if (!_createAccountFormKey.currentState!.validate()) {
  //     return;
  //   }

  //   setState(() {
  //     _isCreatingAccount = true;
  //     _createAccountError = '';
  //   });

  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String? token = prefs.getString('access_token');

  //     if (token == null) {
  //       throw Exception('No authentication token found');
  //     }

  //     Map<String, dynamic> requestBody = {
  //       'email': _emailController.text,
  //       'password': _passwordController.text,
  //       'role': _selectedRole,
  //     };

  //     // Add role-specific fields
  //     if (_selectedRole == 'user') {
  //       requestBody['first_name'] = _firstNameController.text;
  //       requestBody['last_name'] = _lastNameController.text;
  //     } else if (_selectedRole == 'insurance') {
  //       requestBody['company_name'] = _firstNameController.text;
  //       requestBody['state'] = _lastNameController.text;
  //     }

  //     final response = await http.post(
  //       Uri.parse('${AppConfig.server}/create-account'),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode(requestBody),
  //     );

  //     if (response.statusCode == 201) {
  //       Navigator.pop(context);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Account created successfully'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //       _clearCreateAccountForm();
  //     } else {
  //       throw Exception('Failed to create account: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _createAccountError = 'Failed to create account: $e';
  //     });
  //   } finally {
  //     setState(() {
  //       _isCreatingAccount = false;
  //     });
  //   }
  // }
  //revert to above code if below fails:
  Future<void> _createAccount() async {
    if (!_createAccountFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreatingAccount = true;
      _createAccountError = '';
    });

    try {
      // Prepare the request body for your backend
      Map<String, dynamic> requestBody = {
        'mode': 'signup',
        'email': _emailController.text.toLowerCase().trim(),
        'password': _passwordController.text,
      };

      // ✅ Add role-specific fields based on _selectedRole
      if (_selectedRole == 'user') {
        // Creating a driver account
        requestBody['role'] = 'driver';
        requestBody['name'] = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
        requestBody['zipcode'] = _zipcodeController.text.trim();  // ✅ Use dedicated zipcode controller

        // Add base_point from geocoding
        if (_basePointAdmin != null) {
          requestBody['base_point'] = _basePointAdmin!.toJson();
          print('📍 Admin: Including base_point: ${_basePointAdmin!.city}, ${_basePointAdmin!.state}');
        }
      } else if (_selectedRole == 'insurance') {
        // ✅ Creating an insurance provider account with complete info
        requestBody['role'] = 'provider';
        requestBody['name'] = _companyNameController.text.trim();  // Company name
        requestBody['metadata'] = jsonEncode({
          'original_role': 'insurance',
          'company_name': _companyNameController.text.trim(),
          'state': _stateController.text.trim(),
          'contact_person': _contactPersonController.text.trim(),
          'contact_email': _contactEmailController.text.trim(),
          'contact_phone': _contactPhoneController.text.trim(),
          'license_number': _licenseNumberController.text.trim()
        });
      } else if (_selectedRole == 'admin') {
        // ✅ Creating another admin account with proper 'admin' role
        requestBody['role'] = 'admin';  // ✅ Use 'admin' role directly!
        requestBody['name'] = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
        requestBody['metadata'] = jsonEncode({
          'admin_id': _adminIdController.text.trim(),
          'server_number': _serverNumberController.text.trim(),
          'permissions': 'standard',  // Not super admin
          'first_login': true  // Prompt password change
        });
      }

      // Call your auth-user Lambda endpoint
      final response = await http.post(
        Uri.parse('https://m9yn8bsm3k.execute-api.us-west-1.amazonaws.com/auth-user'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Success
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _clearCreateAccountForm();

          // Refresh stats if needed
          _fetchQuickStats();
        }
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to create account');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _createAccountError = e.toString().replaceAll('Exception: ', '');
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingAccount = false;
        });
      }
    }
  }

  // Clears the account creation form
  void _clearCreateAccountForm() {
    // Clear common fields
    _emailController.clear();
    _passwordController.clear();

    // Clear driver fields
    _firstNameController.clear();
    _lastNameController.clear();
    _zipcodeController.clear();

    // Clear admin fields
    _adminIdController.clear();
    _serverNumberController.clear();

    // Clear ISP fields
    _companyNameController.clear();
    _stateController.clear();
    _contactPersonController.clear();
    _contactEmailController.clear();
    _contactPhoneController.clear();
    _licenseNumberController.clear();

    // Reset state
    setState(() {
      _selectedRole = 'user';
      _basePointAdmin = null;
      _zipcodeValidAdmin = null;
      _createAccountError = '';
    });
  }

  // Logs out the current admin user
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}