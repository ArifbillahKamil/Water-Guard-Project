import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Import package flutter_map
import 'package:latlong2/latlong.dart'; // Import package latlong2
import 'package:flutter_application_1/models/laporan_model.dart';
import 'package:flutter_application_1/widgets/detail_laporan_sheet.dart'; // Bottom sheet ini BISA DIPAKAI ULANG!

class PetaLaporanScreen extends StatefulWidget {
  const PetaLaporanScreen({super.key});

  @override
  State<PetaLaporanScreen> createState() => _PetaLaporanScreenState();
}

class _PetaLaporanScreenState extends State<PetaLaporanScreen> {
  // Posisi awal kamera (masih sama)
  final LatLng _posisiAwal = LatLng(-7.3386, 112.7508);

  // DATA DUMMY (pastikan koordinatnya sekarang pakai 'LatLng' dari latlong2)
  final List<LaporanMasalah> _laporanList = [
    LaporanMasalah(
      id: 'laporan-01',
      deskripsi:
          'Banyak saluran drainase yang tersumbat oleh endapan lumpur dan sampah, sehingga sering menyebabkan genangan saat hujan deras.',
      koordinat: LatLng(-7.372071280403217, 112.75091130708668),
      status: StatusLaporan.ditangani,
    ),
    LaporanMasalah(
      id: 'laporan-02',
      deskripsi:
          'Pipa PDAM di dekat jembatan bocor, air bersih terbuang ke jalan.',
      koordinat: LatLng(-7.3395, 112.7512),
      status: StatusLaporan.verifikasi,
    ),
    LaporanMasalah(
      id: 'laporan-03',
      deskripsi:
          'Selokan di depan Garasi Gio Re sudah dibersihkan dan diperbaiki.',
      koordinat: LatLng(-7.3410, 112.7525),
      status: StatusLaporan.selesai,
    ),
  ];

  // Fungsi untuk menampilkan pop-up detail (INI TETAP SAMA)
  void _showDetailBottomSheet(LaporanMasalah laporan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // Kita bisa pakai ulang widget sheet yang sama persis
        return DetailLaporanSheet(laporan: laporan);
      },
    );
  }

  // Fungsi untuk mengubah LaporanMasalah menjadi Marker
  List<Marker> _buildMarkers() {
    return _laporanList.map((laporan) {
      return Marker(
        point: laporan.koordinat,
        // 'builder' adalah cara flutter_map untuk membuat pin kustom
        child: GestureDetector(
          onTap: () {
            _showDetailBottomSheet(laporan);
          },
          child: Icon(
            Icons.location_pin,
            color: _getMarkerColor(laporan.status), // Warna berdasarkan status
            size: 40.0,
          ),
        ),
      );
    }).toList();
  }

  // Fungsi helper untuk menentukan warna pin
  Color _getMarkerColor(StatusLaporan status) {
    switch (status) {
      case StatusLaporan.verifikasi:
        return Colors.red;
      case StatusLaporan.ditangani:
        return Colors.blue; // Biru
      case StatusLaporan.selesai:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Laporan (WaterGuard)'),

        // ** INI TOMBOL KEMBALI YANG DITAMBAHKAN **
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Ini akan kembali ke screen sebelumnya (Dashboard)
            Navigator.pop(context);
          },
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _posisiAwal, // Posisi awal
          initialZoom: 15.0, // Zoom awal
        ),
        children: [
          // 1. Layer untuk gambar peta (Tiles)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName:
                "com.example.flutter_application_1", // Pastikan ini benar
          ),

          // 2. Layer untuk Pin/Marker
          MarkerLayer(
            markers: _buildMarkers(), // Panggil fungsi yang kita buat
          ),
        ],
      ),
    );
  }
}
