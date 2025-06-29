import 'package:stafflink_mobile/services/api_service.dart';

class AbsensiService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> checkAbsensi({
    required String userId,
    required String tanggal,
    required String tipe,
  }) async {
    try {
      return await _apiService.get(
        'absensi/check?user_id=$userId&tanggal=$tanggal&tipe=$tipe',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> absen({
    required String userId,
    required String nama,
    required String tanggal,
    required String tipe,
    String? keterangan,
    String? departemen,
  }) async {
    try {
      return await _apiService.post(
        'absensi',
        body: {
          'user_id': userId,
          'nama': nama,
          'tanggal': tanggal,
          'tipe': tipe,
          if (keterangan != null) 'keterangan': keterangan,
          if (departemen != null) 'departemen': departemen,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getRiwayatAbsensi(String userId) async {
    try {
      final response = await _apiService.get('absensi?user_id=$userId');
      return response['data'] ?? [];
    } catch (e) {
      rethrow;
    }
  }
}