import 'api_service.dart';

class ProfileService {
  final ApiService _apiService = ApiService();

  Future<void> completeProfile({
    required String nip,
    required String nama,
    required String alamat,
    required String tempatLahir,
    required String tanggalLahir,
    required String departemen,
    required String detailJabatan,
    required String edukasi,
    required String gender,
    required String noTelepon,
  }) async {
    try {
      await _apiService.post(
        'profile/complete',
        body: {
          'nip': nip,
          'nama': nama,
          'alamat': alamat,
          'tempat_lahir': tempatLahir,
          'tanggal_lahir': tanggalLahir,
          'departemen': departemen,
          'detail_jabatan': detailJabatan,
          'edukasi': edukasi,
          'gender': gender,
          'no_telepon': noTelepon,
        },
      );
      // No return needed since it's Future<void>
    } on ApiException catch (e) {
      throw Exception('Failed to complete profile: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      return await _apiService.get('auth/me');
    } on ApiException catch (e) {
      throw Exception('Failed to get profile: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      return await _apiService.put('profiles', body: data);
    } on ApiException catch (e) {
      throw Exception('Failed to update profile: ${e.message}');
    }
  }
}