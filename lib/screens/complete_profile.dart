import 'package:flutter/material.dart';
import 'package:stafflink_mobile/screens/home.dart';
import 'package:stafflink_mobile/services/profile_service.dart';
import 'package:stafflink_mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();
  final Color primaryColor = const Color(0xFF23439C);

  // Controllers
  final TextEditingController _nipController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _departemenController = TextEditingController();
  final TextEditingController _jabatanController = TextEditingController();
  final TextEditingController _edukasiController = TextEditingController();
  final TextEditingController _noTeleponController = TextEditingController();

  // State variables
  String _gender = 'male';
  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nipController.dispose();
    _namaController.dispose();
    _alamatController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _departemenController.dispose();
    _jabatanController.dispose();
    _edukasiController.dispose();
    _noTeleponController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _profileService.completeProfile(
        nip: _nipController.text.trim(),
        nama: _namaController.text.trim(),
        alamat: _alamatController.text.trim(),
        tempatLahir: _tempatLahirController.text.trim(),
        tanggalLahir: _selectedDate != null
            ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
            : '',
        departemen: _departemenController.text.trim(),
        detailJabatan: _jabatanController.text.trim(),
        edukasi: _edukasiController.text.trim(),
        gender: _gender,
        noTelepon: _noTeleponController.text.trim(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('profile_completed', true);

      if (!mounted) return;
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => TaskManagerScreen()),
        (Route<dynamic> route) => false,
      );
    } on ApiException catch (e) {
      _showErrorSnackbar(e.message);
    } catch (e) {
      _showErrorSnackbar('Error tidak terduga: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tanggalLahirController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Tambahkan ini untuk background putih
      appBar: AppBar(
        title: const Text('Lengkapi Profil'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.white, // Tambahkan ini untuk background putih
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  "Silakan isi formulir berikut untuk melengkapi profil",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildFormField(
                  controller: _nipController,
                  label: 'NIP',
                  validator: (value) => value?.isEmpty ?? true ? 'Harap masukkan NIP' : null,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _namaController,
                  label: 'Nama Lengkap',
                  validator: (value) => value?.isEmpty ?? true ? 'Harap masukkan nama lengkap' : null,
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _alamatController,
                  label: 'Alamat',
                  validator: (value) => value?.isEmpty ?? true ? 'Harap masukkan alamat' : null,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildFormField(
                        controller: _tempatLahirController,
                        label: 'Tempat Lahir',
                        validator: (value) => value?.isEmpty ?? true ? 'Harap masukkan tempat lahir' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _tanggalLahirController,
                        decoration: InputDecoration(
                          labelText: 'Tanggal Lahir',
                          hintText: 'DD/MM/YYYY',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          prefixIcon: Icon(Icons.calendar_today, color: Colors.grey[500]),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        validator: (value) => value?.isEmpty ?? true ? 'Harap pilih tanggal lahir' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _departemenController,
                  label: 'Departemen',
                  validator: (value) => value?.isEmpty ?? true ? 'Harap masukkan departemen' : null,
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _jabatanController,
                  label: 'Detail Jabatan',
                  validator: (value) => value?.isEmpty ?? true ? 'Harap masukkan detail jabatan' : null,
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _edukasiController,
                  label: 'Pendidikan Terakhir',
                  validator: (value) => value?.isEmpty ?? true ? 'Harap masukkan pendidikan terakhir' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: InputDecoration(
                    labelText: 'Jenis Kelamin',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Laki-laki')),
                    DropdownMenuItem(value: 'female', child: Text('Perempuan')),
                  ],
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _gender = value);
                          }
                        },
                  validator: (value) => value == null ? 'Harap pilih jenis kelamin' : null,
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _noTeleponController,
                  label: 'Nomor Telepon',
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Harap masukkan nomor telepon';
                    if (!RegExp(r'^[0-9]+$').hasMatch(value!)) {
                      return 'Nomor telepon hanya boleh angka';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Simpan Profil',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Masukkan $label',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: !_isLoading,
    );
  }
}