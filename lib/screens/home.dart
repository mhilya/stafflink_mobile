import 'package:flutter/material.dart';
import 'package:stafflink_mobile/services/auth_service.dart';
import 'package:stafflink_mobile/services/profile_service.dart';
import 'housekeeping_report_form.dart';

class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({super.key});

  @override
  State<TaskManagerScreen> createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  late Future<Map<String, dynamic>> _userProfileFuture;
  final ProfileService _profileService = ProfileService();
  final Color primaryColor = const Color(0xFF23439C); // Warna tema utama

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    setState(() {
      _userProfileFuture = _profileService.getProfile();
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await AuthService.logout();
      if (!mounted) return;
      navigator.pushReplacementNamed('/login');
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}')),
      );
    }
  }

  void showAbsenDialog(BuildContext context, String status) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Absen $status'),
      content: Text('Absen $status berhasil!'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF23439C),
          ),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

  String _formatNIP(String nip) {
    if (nip.length >= 8) {
      return '${nip.substring(0, 8)} ${nip.substring(8)}';
    }
    return nip;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HousekeepingReportForm()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Form'),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Prediksi',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: const Color(0xFF23439C), // Warna tema
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _userProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF23439C), // Warna tema
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadUserProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF23439C), // Warna tema
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final userData = snapshot.data!['user'] ?? {};
            final karyawanData = userData['karyawan'] ?? {};

            final nama = karyawanData['nama'] ?? userData['name'] ?? 'Nama';
            final jabatan =
                userData['role']?['name']?.toString().toUpperCase() ??
                'JABATAN';
            final nip = karyawanData['nip']?.toString() ?? '-';
            final formattedNip = _formatNIP(nip);

            return Column(
              children: [
                // Header with User Info
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  color: const Color(0xFF23439C), // Warna tema
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nama,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'NIP: $formattedNip',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  jabatan,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            itemBuilder:
                                (context) => [
                                  const PopupMenuItem(
                                    value: 'refresh',
                                    child: Text('Refresh Data'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'logout',
                                    child: Text('Logout'),
                                  ),
                                ],
                            onSelected: (value) async {
                              if (value == 'refresh') {
                                _loadUserProfile();
                              } else if (value == 'logout') {
                                await _handleLogout(context);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: RefreshIndicator(
                    color: const Color(0xFF23439C), // Warna tema
                    onRefresh: () async {
                      _loadUserProfile();
                    },
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Attendance Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: StatusButton(
                                  icon: Icons.login,
                                  label: 'Masuk',
                                  color: Colors.white,
                                  iconColor: const Color(
                                    0xFF23439C,
                                  ), // Warna tema
                                  onPressed:
                                      (context) =>
                                          showAbsenDialog(context, 'Masuk'),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: StatusButton(
                                  icon: Icons.logout,
                                  label: 'Pulang',
                                  color: Colors.white,
                                  iconColor: const Color(
                                    0xFF23439C,
                                  ), // Warna tema
                                  onPressed:
                                      (context) =>
                                          showAbsenDialog(context, 'Pulang'),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: StatusButton(
                                  icon: Icons.description,
                                  label: 'Izin',
                                  color: Colors.white,
                                  iconColor: const Color(
                                    0xFF23439C,
                                  ), // Warna tema
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: StatusButton(
                                  icon: Icons.medical_services,
                                  label: 'Sakit',
                                  color: Colors.white,
                                  iconColor: const Color(
                                    0xFF23439C,
                                  ), // Warna tema
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // History Section
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF23439C).withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Riwayat',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(
                                        0xFF23439C,
                                      ), // Warna tema
                                    ),
                                  ),
                                  Text(
                                    'Status',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(
                                        0xFF23439C,
                                      ), // Warna tema
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                ),
                                child: Text(
                                  'No attendance history yet',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class StatusButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final void Function(BuildContext)? onPressed;

  const StatusButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.iconColor = Colors.black87,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onPressed?.call(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.12),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: const Color(0xFF23439C).withValues(alpha: 0.2) // Warna tema
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: iconColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
