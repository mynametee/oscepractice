import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/sample_data.dart';
import '../models/case_model.dart';
import '../utils/constants.dart';
import 'department_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final SampleDataService _sampleDataService = SampleDataService();
  
  List<Department> _departments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    try {
      final departments = await _firestoreService.getDepartments();
      if (departments.isEmpty) {
        // Seed departments and sample cases if none exist
        await _sampleDataService.seedAllSampleData();
        final seededDepartments = await _firestoreService.getDepartments();
        setState(() {
          _departments = seededDepartments;
          _isLoading = false;
        });
      } else {
        // Check if we need to seed sample cases
        await _sampleDataService.seedSampleCases();
        setState(() {
          _departments = departments;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await _authService.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildDepartmentsGrid() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              'Failed to load departments',
              style: AppTextStyles.heading3.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              _error!,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadDepartments();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.paddingMedium,
        mainAxisSpacing: AppDimensions.paddingMedium,
        childAspectRatio: 1.1,
      ),
      itemCount: _departments.length,
      itemBuilder: (context, index) {
        final department = _departments[index];
        return _DepartmentCard(
          department: department,
          onTap: () => _navigateToDepartment(department),
        );
      },
    );
  }

  void _navigateToDepartment(Department department) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DepartmentScreen(department: department),
      ),
    );
  }

  Widget _buildProgressView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: AppDimensions.paddingMedium),
          Text(
            'Progress Tracking',
            style: AppTextStyles.heading2,
          ),
          SizedBox(height: AppDimensions.paddingSmall),
          Text(
            'Coming soon...',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    final user = _authService.currentUser;
    
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      user?.displayName?.isNotEmpty == true
                          ? user!.displayName![0].toUpperCase()
                          : user?.email?[0].toUpperCase() ?? 'U',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  Text(
                    user?.displayName ?? 'User',
                    style: AppTextStyles.heading3,
                  ),
                  Text(
                    user?.email ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: _handleSignOut,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: AppTextStyles.heading2.copyWith(color: AppColors.surface),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        actions: _selectedIndex == 0 ? [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _onNavItemTapped(3),
          ),
        ] : null,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDepartmentsGrid(),
          const Center(child: Text('Cases', style: AppTextStyles.heading2)),
          _buildProgressView(),
          _buildProfileView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.surface,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Cases',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Departments';
      case 1:
        return 'My Cases';
      case 2:
        return 'Progress';
      case 3:
        return 'Profile';
      default:
        return AppConstants.appName;
    }
  }
}

class _DepartmentCard extends StatelessWidget {
  final Department department;
  final VoidCallback onTap;

  const _DepartmentCard({
    required this.department,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                ),
                child: Center(
                  child: Text(
                    department.icon,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              Text(
                department.name,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}