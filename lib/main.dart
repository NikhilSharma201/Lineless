// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';

// NOTE: Use 'http://10.0.2.2:5000' for Android Emulator, 'http://localhost:5000' for iOS Simulator/Web
const String baseUrl = 'http://localhost:5000'; 
String? globalStudentId;
String? globalStudentName;
String? globalUserRole; // 'student' or 'admin'
String? globalAdminEmail;

void main() {
  runApp(const LinelessApp());
}

class LinelessTheme {
  static const Color primary = Color(0xFF4A4E69);
  static const Color background = Color(0xFFF9F9F4);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF22223B);
  static const Color textSecondary = Color(0xFF9A8C98);
  static const Color success = Color(0xFF6B9080);
  static const Color danger = Color(0xFFE07A5F);
}

class LinelessApp extends StatelessWidget {
  const LinelessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lineless',
      theme: ThemeData(
        scaffoldBackgroundColor: LinelessTheme.background,
        colorScheme: ColorScheme.fromSeed(seedColor: LinelessTheme.primary),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        useMaterial3: true,
      ),
      home: const LoginSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- SCREENS ---

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: LinelessTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.grid_view_rounded, size: 40, color: LinelessTheme.primary),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Lineless', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: LinelessTheme.textPrimary)),
              const Text('Enterprise Student Portal', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: LinelessTheme.textSecondary)),
              const SizedBox(height: 80),
              
              const Text('Select Login Type', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: LinelessTheme.textPrimary)),
              const SizedBox(height: 24),
              
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: LinelessTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.person_rounded),
                label: const Text('Student Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentLoginScreen()));
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: LinelessTheme.primary, width: 2),
                  foregroundColor: LinelessTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.admin_panel_settings_rounded),
                label: const Text('Admin Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final _idController = TextEditingController(text: '');
  final _pinController = TextEditingController(text: '');
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'student_id': _idController.text,
          'pin': _pinController.text,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        globalStudentId = data['user']['id'];
        globalStudentName = data['user']['name'];
        globalUserRole = 'student';
        if(mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainDashboard()),
          );
        }
      } else {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid Credentials. Try: 24107095/123456 or 24107096/654321')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error connecting to backend: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: LinelessTheme.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Student Authentication', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),
              TextField(
                controller: _idController,
                keyboardType: TextInputType.number,
                maxLength: 8,
                decoration: const InputDecoration(
                  labelText: 'University Student ID',
                  hintText: 'e.g. 24107095',
                  prefixIcon: Icon(Icons.badge_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  filled: true,
                  fillColor: LinelessTheme.surface,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Access PIN',
                  hintText: 'Enter 6-digit PIN',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  filled: true,
                  fillColor: LinelessTheme.surface,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: LinelessTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _login,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Authenticate Identity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController(text: 'admin@apsit.edu.in');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        globalAdminEmail = data['user']['email'];
        globalStudentName = data['user']['name'];
        globalUserRole = 'admin';
        if(mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboard()),
          );
        }
      } else {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid admin credentials')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error connecting to backend: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: LinelessTheme.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Admin Authentication', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Admin Email',
                  hintText: 'email@apsit.edu.in',
                  prefixIcon: Icon(Icons.email_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  filled: true,
                  fillColor: LinelessTheme.surface,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter admin password',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  filled: true,
                  fillColor: LinelessTheme.surface,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: LinelessTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _login,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Admin Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ADMIN DASHBOARD
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<dynamic> _tokens = [];
  String _filterStatus = 'ALL'; // ALL, ACTIVE, COMPLETED, CANCELLED

  @override
  void initState() {
    super.initState();
    _fetchAllTokens();
  }

  Future<void> _fetchAllTokens() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/tokens'));
    if (res.statusCode == 200) {
      setState(() => _tokens = jsonDecode(res.body)['tokens']);
    }
  }

  List<dynamic> get _filteredTokens {
    if (_filterStatus == 'ALL') return _tokens;
    return _tokens.where((t) => t['status'] == _filterStatus).toList();
  }

  Future<void> _markComplete(String tokenId) async {
    final res = await http.post(Uri.parse('$baseUrl/tokens/$tokenId/complete'));
    if (res.statusCode == 200) {
      _fetchAllTokens();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token marked as completed'), backgroundColor: LinelessTheme.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _tokens.where((t) => t['status'] == 'ACTIVE').length;
    final completedCount = _tokens.where((t) => t['status'] == 'COMPLETED').length;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: LinelessTheme.background,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lineless Admin', style: TextStyle(fontWeight: FontWeight.w900, color: LinelessTheme.textPrimary)),
            Text('Queue Management Portal', style: TextStyle(fontSize: 12, color: LinelessTheme.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAllTokens,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Active', style: TextStyle(color: LinelessTheme.textSecondary)),
                        Text('$activeCount', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: LinelessTheme.success)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: LinelessTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Completed', style: TextStyle(color: LinelessTheme.textSecondary)),
                        Text('$completedCount', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: LinelessTheme.primary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('ALL'),
                  const SizedBox(width: 8),
                  _buildFilterChip('ACTIVE'),
                  const SizedBox(width: 8),
                  _buildFilterChip('COMPLETED'),
                  const SizedBox(width: 8),
                  _buildFilterChip('CANCELLED'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const Text('All Tokens', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: LinelessTheme.textPrimary)),
            const SizedBox(height: 16),
            
            ..._filteredTokens.map((token) => _buildAdminTokenCard(token)).toList(),
            if(_filteredTokens.isEmpty) const Center(child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Text("No tokens found.", style: TextStyle(color: LinelessTheme.textSecondary)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String status) {
    bool isSelected = _filterStatus == status;
    return FilterChip(
      label: Text(status),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterStatus = status);
      },
      selectedColor: LinelessTheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : LinelessTheme.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildAdminTokenCard(dynamic token) {
    bool isActive = token['status'] == 'ACTIVE';
    bool isCompleted = token['status'] == 'COMPLETED';
    bool isCancelled = token['status'] == 'CANCELLED';
    
    Color statusColor = isActive ? const Color(0xFFE8F5E9) : 
                       isCompleted ? const Color(0xFFE3F2FD) :
                       const Color(0xFFFFF3E0);
    Color statusTextColor = isActive ? Colors.green[800]! : 
                           isCompleted ? Colors.blue[800]! :
                           Colors.orange[800]!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LinelessTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: LinelessTheme.background, borderRadius: BorderRadius.circular(12)),
                child: Text(token['id'].split('-')[1], style: const TextStyle(fontWeight: FontWeight.bold, color: LinelessTheme.primary, fontSize: 12)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(token['service_name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    Text('${token['student_name']} • ${token['student_id']}', style: const TextStyle(fontSize: 12, color: LinelessTheme.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(token['status'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusTextColor)),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(token['display_time'] ?? token['created_at'], style: const TextStyle(fontSize: 12, color: LinelessTheme.textSecondary)),
              if(isActive) Text('Position: ${token['queue_position']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LinelessTheme.primary)),
            ],
          ),
          if(isActive) const SizedBox(height: 12),
          if(isActive) ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: LinelessTheme.success,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 40),
            ),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Mark as Complete'),
            onPressed: () => _markComplete(token['id']),
          ),
        ],
      ),
    );
  }
}

// STUDENT DASHBOARD
class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});
  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  List<dynamic> _tokens = [];

  @override
  void initState() {
    super.initState();
    _fetchTokens();
  }

  Future<void> _fetchTokens() async {
    final res = await http.get(Uri.parse('$baseUrl/tokens?student_id=$globalStudentId'));
    if (res.statusCode == 200) {
      setState(() => _tokens = jsonDecode(res.body)['tokens']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: LinelessTheme.background,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lineless', style: TextStyle(fontWeight: FontWeight.w900, color: LinelessTheme.textPrimary)),
            Text('Campus Service Portal', style: TextStyle(fontSize: 12, color: LinelessTheme.textSecondary)),
          ],
        ),
        actions: [
          CircleAvatar(
            backgroundColor: LinelessTheme.primary,
            child: Text(globalStudentName?.substring(0,2).toUpperCase() ?? 'JD', style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 20)
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchTokens,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [LinelessTheme.primary, Color(0xFF22223B)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Active Queues', style: TextStyle(color: Colors.white70)),
                      Text('${_tokens.where((t) => t['status'] == 'ACTIVE').length} Services', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const Icon(Icons.confirmation_number_rounded, color: Colors.white, size: 40)
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Your Recent Tokens', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: LinelessTheme.textPrimary)),
            const SizedBox(height: 16),
            ..._tokens.map((token) => _buildTokenCard(token)).toList(),
            if(_tokens.isEmpty) const Text("No tokens generated yet.", style: TextStyle(color: LinelessTheme.textSecondary)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceSelectionScreen()));
          _fetchTokens(); // Refresh after returning
        },
        backgroundColor: LinelessTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Token', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildTokenCard(dynamic token) {
    bool isActive = token['status'] == 'ACTIVE';
    bool isCompleted = token['status'] == 'COMPLETED';
    bool isCancelled = token['status'] == 'CANCELLED';
    
    Color statusColor = isActive ? const Color(0xFFE8F5E9) : 
                       isCompleted ? const Color(0xFFE3F2FD) :
                       const Color(0xFFFFF3E0);
    Color statusTextColor = isActive ? Colors.green[800]! : 
                           isCompleted ? Colors.blue[800]! :
                           Colors.orange[800]!;
    
    return InkWell(
      onTap: isActive ? () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => TokenDetailScreen(token: token)));
        _fetchTokens();
      } : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LinelessTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: LinelessTheme.background, borderRadius: BorderRadius.circular(12)),
              child: Text(token['id'].split('-')[1].substring(0,3), style: const TextStyle(fontWeight: FontWeight.bold, color: LinelessTheme.primary)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(token['service_name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  Text(token['display_time'] ?? token['created_at'], style: const TextStyle(fontSize: 12, color: LinelessTheme.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(token['status'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusTextColor)),
            )
          ],
        ),
      ),
    );
  }
}

class ServiceSelectionScreen extends StatefulWidget {
  const ServiceSelectionScreen({super.key});
  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  List<dynamic> _services = [];

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    final res = await http.get(Uri.parse('$baseUrl/services'));
    if (res.statusCode == 200) {
      setState(() => _services = jsonDecode(res.body)['services']);
    }
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'school': return Icons.school_rounded;
      case 'train': return Icons.train_rounded;
      case 'payments': return Icons.payments_rounded;
      default: return Icons.description_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Services'), backgroundColor: LinelessTheme.background),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _services.length,
        itemBuilder: (context, index) {
          final s = _services[index];
          int queueCount = s['queue_count'] ?? 0;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: LinelessTheme.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: LinelessTheme.background, borderRadius: BorderRadius.circular(12)),
                child: Icon(_getIcon(s['icon']), color: LinelessTheme.primary),
              ),
              title: Text(s['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s['desc']),
                  const SizedBox(height: 4),
                  Text('$queueCount in queue', style: TextStyle(fontSize: 12, color: queueCount > 0 ? LinelessTheme.primary : LinelessTheme.textSecondary, fontWeight: FontWeight.w600)),
                ],
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: LinelessTheme.primary, foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => TokenGenerationScreen(serviceName: s['name'])));
                },
                child: const Text('Select'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TokenGenerationScreen extends StatefulWidget {
  final String serviceName;
  const TokenGenerationScreen({super.key, required this.serviceName});

  @override
  State<TokenGenerationScreen> createState() => _TokenGenerationScreenState();
}

class _TokenGenerationScreenState extends State<TokenGenerationScreen> {
  bool _isLoading = false;

  Future<void> _generateToken() async {
    setState(() => _isLoading = true);
    final res = await http.post(
      Uri.parse('$baseUrl/tokens'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'student_id': globalStudentId,
        'service_name': widget.serviceName,
      }),
    );
    setState(() => _isLoading = false);
    if (res.statusCode == 200) {
      if(mounted) {
        Navigator.pop(context); // Go back to services
        Navigator.pop(context); // Go back to dashboard
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.serviceName), backgroundColor: LinelessTheme.background),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Confirm Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: TextEditingController(text: globalStudentName),
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder(), filled: true, fillColor: LinelessTheme.surface),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: globalStudentId),
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Student ID', border: OutlineInputBorder(), filled: true, fillColor: LinelessTheme.surface),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_2_rounded),
              label: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Generate Queue Token', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: LinelessTheme.textPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isLoading ? null : _generateToken,
            )
          ],
        ),
      ),
    );
  }
}

class TokenDetailScreen extends StatefulWidget {
  final dynamic token;
  const TokenDetailScreen({super.key, required this.token});

  @override
  State<TokenDetailScreen> createState() => _TokenDetailScreenState();
}

class _TokenDetailScreenState extends State<TokenDetailScreen> {
  Future<void> _cancelToken(BuildContext context) async {
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Token?'),
        content: const Text('Are you sure you want to cancel this token? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel', style: TextStyle(color: LinelessTheme.danger)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final res = await http.post(Uri.parse('$baseUrl/tokens/${widget.token['id']}/cancel'));
      if(res.statusCode == 200 && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token cancelled successfully'), backgroundColor: LinelessTheme.danger),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Token Detail'), backgroundColor: LinelessTheme.background),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: LinelessTheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TOKEN ID', style: TextStyle(fontSize: 12, color: LinelessTheme.textSecondary)),
                          Text(widget.token['id'], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: LinelessTheme.primary)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
                        child: Text(widget.token['status'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800])),
                      )
                    ],
                  ),
                  const Divider(height: 32),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Service Category'), Text(widget.token['service_name'], style: const TextStyle(fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Student Name'), Text(globalStudentName ?? '', style: const TextStyle(fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Student ID'), Text(globalStudentId ?? '', style: const TextStyle(fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 32),
                  QrImageView(data: widget.token['id'], version: QrVersions.auto, size: 200.0),
                  const SizedBox(height: 16),
                  const Text('Scan at Counter', style: TextStyle(color: LinelessTheme.textSecondary, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: LinelessTheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Queue Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${widget.token['queue_position']}${_getPositionSuffix(widget.token['queue_position'])} in Line', style: const TextStyle(color: LinelessTheme.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: 0.75, backgroundColor: LinelessTheme.background, color: LinelessTheme.primary, minHeight: 8, borderRadius: BorderRadius.circular(4)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [const Text('Est. Wait Time', style: TextStyle(fontSize: 12)), Text(widget.token['est_wait'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))],
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: LinelessTheme.danger),
                foregroundColor: LinelessTheme.danger,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _cancelToken(context),
              child: const Text('Cancel Token'),
            )
          ],
        ),
      ),
    );
  }
  
  String _getPositionSuffix(int position) {
    if (position % 100 >= 11 && position % 100 <= 13) return 'th';
    switch (position % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }
}