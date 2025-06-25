import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'housekeeping_report_form.dart';

class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({super.key});

  @override
  State<TaskManagerScreen> createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  late Future<Map<String, String?>> _userData;

  @override
  void initState() {
    super.initState();
    _userData = _loadUserData();
  }

  Future<Map<String, String?>> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'nama_karyawan': prefs.getString('nama_karyawan'),
      'nip': prefs.getString('nip'),
      'departemen': prefs.getString('departemen'),
      'jabatan': prefs.getString('role'),
    };
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
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, String?>>(
          future: _userData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final userData = snapshot.data!;
            final namaKaryawan = userData['nama_karyawan'] ?? 'Nama Karyawan';
            final jabatan = userData['jabatan'] ?? 'Jabatan';

            return Column(
              children: [
                // Header with User Info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  color: const Color(0xFF1A73E8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello $namaKaryawan',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            jabatan,
                            style: const TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.menu, color: Colors.white),
                    ],
                  ),
                ),
                
                // Main Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Attendance Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: StatusButton(
                                icon: Icons.login,
                                label: 'Masuk',
                                color: const Color(0xFFB9D9F2),
                                onPressed: (context) => showAbsenDialog(context, 'Masuk'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: StatusButton(
                                icon: Icons.logout,
                                label: 'Pulang',
                                color: const Color(0xFFF7B9B9),
                                onPressed: (context) => showAbsenDialog(context, 'Pulang'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: StatusButton(
                                icon: Icons.description,
                                label: 'Izin',
                                color: const Color(0xFFB9B9F7),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: StatusButton(
                                icon: Icons.medical_services,
                                label: 'Sakit',
                                color: const Color(0xFFF7B9B9),
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
                          color: const Color(0xFFE6F3F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'Riwayat',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Status',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Riwayat items would go here
                          ],
                        ),
                      ),
                    ],
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
  final void Function(BuildContext)? onPressed;

  const StatusButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
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
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.black87),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}