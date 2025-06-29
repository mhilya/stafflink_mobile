import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stafflink_mobile/services/auth_service.dart';
import 'package:stafflink_mobile/services/profile_service.dart';
import 'package:stafflink_mobile/services/absensi_service.dart';
import 'housekeeping_report_form.dart';
import 'setting_page.dart';

class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({super.key});

  @override
  State<TaskManagerScreen> createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  late Future<Map<String, dynamic>> _userProfileFuture;
  late Future<List<dynamic>> _riwayatAbsensiFuture;
  final ProfileService _profileService = ProfileService();
  final AbsensiService _absensiService = AbsensiService();
  final TextEditingController _keteranganController = TextEditingController();
  final Color primaryColor = const Color(0xFF23439C);
  int _currentIndex = 0;
  int _absensiDataLength = 0; // Added to track absensi data length

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadRiwayatAbsensi();
  }

  void _loadUserProfile() {
    setState(() {
      _userProfileFuture = _profileService.getProfile();
    });
  }

  void _loadRiwayatAbsensi() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId != null) {
      setState(() {
        _riwayatAbsensiFuture = _absensiService.getRiwayatAbsensi(userId);
      });
    }
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

  Future<void> _handleAbsen(BuildContext context, String tipe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final nama = prefs.getString('nama') ?? 'Karyawan';

      if (userId == null) throw Exception('User ID tidak ditemukan');

      // Dapatkan profile lengkap termasuk departemen
      final profile = await _profileService.getProfile();
      final karyawanData = profile['user']['karyawan'] ?? {};
      final departemen = karyawanData['departemen']?.toString() ?? '-';

      final now = DateTime.now();
      final tanggal = DateFormat('yyyy-MM-dd').format(now);

      final cekAbsen = await _absensiService.checkAbsensi(
        userId: userId,
        tanggal: tanggal,
        tipe: tipe,
      );

      if (cekAbsen['exists'] == true) {
        throw Exception('Anda sudah absen $tipe hari ini');
      }

      String? keterangan;
      if (tipe == 'izin' || tipe == 'sakit') {
        keterangan = await showDialog<String>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Keterangan $tipe'),
                content: TextField(
                  controller: _keteranganController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan alasan $tipe',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, _keteranganController.text);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );

        if (keterangan == null || keterangan.isEmpty) {
          return;
        }
      }

      await _absensiService.absen(
        userId: userId,
        nama: nama,
        tanggal: tanggal,
        tipe: tipe,
        keterangan: keterangan,
        departemen: departemen,
      );

      _loadRiwayatAbsensi();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Absen $tipe berhasil'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal absen: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HousekeepingReportForm()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
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
        selectedItemColor: const Color(0xFF23439C),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _userProfileFuture,
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF23439C)),
              );
            }

            if (profileSnapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${profileSnapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadUserProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF23439C),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (!profileSnapshot.hasData || profileSnapshot.data == null) {
              return const Center(child: Text('Data profil tidak ditemukan.'));
            }

            final userData = profileSnapshot.data!['user'] ?? {};
            final karyawanData = userData['karyawan'] ?? {};

            final nama = karyawanData['nama'] ?? userData['name'] ?? 'Nama';
            final jabatan =
                userData['role']?['name']?.toString().toUpperCase() ??
                'JABATAN';
            final nip = karyawanData['nip']?.toString() ?? '-';
            final formattedNip = _formatNIP(nip);

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  color: const Color(0xFF23439C),
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
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'NIP: $formattedNip',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
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
                                _loadRiwayatAbsensi();
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

                Expanded(
                  child: RefreshIndicator(
                    color: const Color(0xFF23439C),
                    onRefresh: () async {
                      _loadUserProfile();
                      _loadRiwayatAbsensi();
                    },
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
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
                                  iconColor: const Color(0xFF23439C),
                                  onPressed:
                                      (context) =>
                                          _handleAbsen(context, 'masuk'),
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
                                  iconColor: const Color(0xFF23439C),
                                  onPressed:
                                      (context) =>
                                          _handleAbsen(context, 'pulang'),
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
                                  iconColor: const Color(0xFF23439C),
                                  onPressed:
                                      (context) =>
                                          _handleAbsen(context, 'izin'),
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
                                  iconColor: const Color(0xFF23439C),
                                  onPressed:
                                      (context) =>
                                          _handleAbsen(context, 'sakit'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF23439C).withOpacity(0.2),
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
                                    'Riwayat Absensi',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF23439C),
                                    ),
                                  ),
                                  Text(
                                    'Status',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF23439C),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              FutureBuilder<List<dynamic>>(
                                future: _riwayatAbsensiFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 24,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  if (snapshot.hasError) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 24,
                                      ),
                                      child: Text('Error: ${snapshot.error}'),
                                    );
                                  }

                                  final data = snapshot.data ?? [];
                                  _absensiDataLength =
                                      data.length; // Update the length

                                  if (data.isEmpty) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 24,
                                      ),
                                      child: Text(
                                        'Belum ada riwayat absensi',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    );
                                  }

                                  return Column(
                                    children:
                                        data
                                            .take(5)
                                            .map(
                                              (absensi) =>
                                                  AbsensiItem(absensi: absensi),
                                            )
                                            .toList(),
                                  );
                                },
                              ),
                              if (_absensiDataLength >
                                  5) // Use the stored length here
                                TextButton(
                                  onPressed: () {
                                    // Navigasi ke halaman riwayat lengkap
                                  },
                                  child: Text(
                                    'Lihat Semua',
                                    style: TextStyle(
                                      color: const Color(0xFF23439C),
                                    ),
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

class AbsensiItem extends StatelessWidget {
  final dynamic absensi;

  const AbsensiItem({super.key, required this.absensi});

  @override
  Widget build(BuildContext context) {
    try {
      // Initialize timezone database
      tz.initializeTimeZones();
      final jakarta = tz.getLocation('Asia/Jakarta');

      // Format tanggal
      final tanggal = _parseTanggal(absensi['tanggal'], jakarta);
      final formattedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(tanggal);

      // Format waktu
      final waktuMasuk = _formatWaktuWIB(absensi['waktu_masuk'], jakarta);
      final waktuKeluar = _formatWaktuWIB(absensi['waktu_keluar'], jakarta);
      final keterangan = absensi['keterangan']?.toString() ?? '';
      final tipe = absensi['tipe']?.toString() ?? '';

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                _buildStatusBadge(tipe),
              ],
            ),
            if (waktuMasuk != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Masuk: $waktuMasuk WIB',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            if (waktuKeluar != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Pulang: $waktuKeluar WIB',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            if (keterangan.isNotEmpty && keterangan != '-')
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Keterangan: $keterangan',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error in AbsensiItem: $e');
      return Container(
        padding: const EdgeInsets.all(8),
        color: Colors.red[50],
        child: const Text('Gagal memuat data absensi'),
      );
    }
  }

  tz.TZDateTime _parseTanggal(dynamic tanggal, tz.Location location) {
    try {
      if (tanggal == null) return tz.TZDateTime.now(location);
      
      if (tanggal is DateTime) {
        return tz.TZDateTime.from(tanggal, location);
      }
      
      if (tanggal is String) {
        final dateTime = DateTime.parse(tanggal);
        return tz.TZDateTime.from(dateTime, location);
      }
      
      return tz.TZDateTime.now(location);
    } catch (e) {
      debugPrint('Error parsing tanggal: $e');
      return tz.TZDateTime.now(location);
    }
  }

  String? _formatWaktuWIB(dynamic waktu, tz.Location location) {
    if (waktu == null) return null;
    
    try {
      tz.TZDateTime parsedTime;
      
      if (waktu is DateTime) {
        parsedTime = tz.TZDateTime.from(waktu, location);
      } else if (waktu is String) {
        if (waktu.contains('+') || waktu.endsWith('Z')) {
          final dateTime = DateTime.parse(waktu);
          parsedTime = tz.TZDateTime.from(dateTime, location);
        } else if (waktu.contains(':')) {
          final now = tz.TZDateTime.now(location);
          final parts = waktu.split(':');
          parsedTime = tz.TZDateTime(
            location,
            now.year,
            now.month,
            now.day,
            int.parse(parts[0]),
            parts.length > 1 ? int.parse(parts[1]) : 0,
          );
        } else if (waktu.contains('T')) {
          final dateTime = DateTime.parse(waktu);
          parsedTime = tz.TZDateTime.from(dateTime, location);
        } else {
          return null;
        }
      } else {
        return null;
      }

      return DateFormat('HH:mm').format(parsedTime);
    } catch (e) {
      debugPrint('Error formatting waktu WIB: $e');
      return null;
    }
  }

  Widget _buildStatusBadge(String tipe) {
    final (color, icon, label) = _getStatusAttributes(tipe);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData, String) _getStatusAttributes(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'masuk':
        return (Colors.green, Icons.login, 'MASUK');
      case 'pulang':
        return (Colors.blue, Icons.logout, 'PULANG');
      case 'izin':
        return (Colors.orange, Icons.description, 'IZIN');
      case 'sakit':
        return (Colors.red, Icons.medical_services, 'SAKIT');
      default:
        return (Colors.grey, Icons.help, 'UNKNOWN');
    }
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
          border: Border.all(color: const Color(0xFF23439C).withOpacity(0.2)),
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
