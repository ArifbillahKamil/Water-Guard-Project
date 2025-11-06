// Ganti 'package:google_maps_flutter/google_maps_flutter.dart'
// dengan 'package:latlong2/latlong.dart'

import 'package:latlong2/latlong.dart'; // <-- UBAH INI

// Enum untuk status laporan (INI TETAP SAMA)
enum StatusLaporan { verifikasi, ditangani, selesai }

class LaporanMasalah {
  final String id;
  final String deskripsi;
  final LatLng
  koordinat; // <-- Ini sekarang otomatis pakai LatLng dari package 'latlong2'
  final StatusLaporan status;

  LaporanMasalah({
    required this.id,
    required this.deskripsi,
    required this.koordinat,
    required this.status,
  });
}
