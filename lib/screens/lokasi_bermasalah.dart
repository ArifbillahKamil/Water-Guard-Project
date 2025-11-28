import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter_application_1/models/laporan_model.dart';
import 'package:flutter_application_1/widgets/detail_laporan_sheet.dart';

class PetaLaporanScreen extends StatefulWidget {
  const PetaLaporanScreen({super.key});

  @override
  State<PetaLaporanScreen> createState() => _PetaLaporanScreenState();
}

class _PetaLaporanScreenState extends State<PetaLaporanScreen> {
  // Posisi awal kamera (Surabaya/Sidoarjo)
  final LatLng _posisiAwal = LatLng(-7.3386, 112.7508);

  // Fungsi Helper: Menentukan Warna Pin berdasarkan String Status dari Database
  Color _getMarkerColor(String status) {
    // Kita samakan string-nya dengan yang kita simpan di report_screen.dart
    if (status == 'Selesai') {
      return Colors.green;
    } else if (status == 'Sedang Proses') {
      return Colors.blue;
    } else {
      // Default: 'Menunggu Konfirmasi' atau status lain
      return Colors.red;
    }
  }

  // Fungsi Helper: Konversi Status String ke Enum (Agar DetailLaporanSheet tidak error)
  // Asumsi: LaporanMasalah model kamu pakai Enum. Jika pakai String, fungsi ini tidak perlu.
  StatusLaporan _parseStatus(String status) {
    if (status == 'Selesai') return StatusLaporan.selesai;
    if (status == 'Sedang Proses') return StatusLaporan.ditangani;
    return StatusLaporan.verifikasi; // Default
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Laporan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // MENGGUNAKAN STREAM BUILDER AGAR REAL-TIME
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('laporan').snapshots(),
        builder: (context, snapshot) {
          // 1. Cek Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Cek Error
          if (snapshot.hasError) {
            return const Center(child: Text("Gagal memuat peta."));
          }

          // 3. Ambil Data Dokumen
          final docs = snapshot.data?.docs ?? [];

          // 4. Buat List Marker dari Data Firestore
          List<Marker> myMarkers = [];

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            // Cek apakah data punya koordinat valid (GeoPoint)
            if (data['koordinat'] is GeoPoint) {
              GeoPoint gp = data['koordinat'];
              LatLng point = LatLng(gp.latitude, gp.longitude);
              String statusString = data['status'] ?? 'Menunggu Konfirmasi';

              // Buat Objek Laporan (untuk dipass ke DetailSheet)
              // Sesuaikan field ini dengan LaporanMasalah model kamu
              LaporanMasalah laporanObj = LaporanMasalah(
                id: doc.id,
                deskripsi: data['deskripsi'] ?? '-',
                koordinat: point,
                status: _parseStatus(statusString),
                // Tambahkan field lain jika modelmu butuh (misal judul, fotoUrl, dll)
              );

              // Buat Marker
              myMarkers.add(
                Marker(
                  point: point,
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () {
                      // Tampilkan Detail saat Pin diklik
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            DetailLaporanSheet(laporan: laporanObj),
                      );
                    },
                    child: Icon(
                      Icons.location_pin,
                      color: _getMarkerColor(statusString),
                      size: 40.0,
                      shadows: const [
                        Shadow(blurRadius: 10, color: Colors.black26),
                      ],
                    ),
                  ),
                ),
              );
            }
          }

          // 5. Tampilkan Peta
          return FlutterMap(
            options: MapOptions(
              initialCenter:
                  _posisiAwal, // Bisa diubah agar center ke marker pertama
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: "com.example.flutter_application_1",
              ),

              // Masukkan marker yang sudah kita generate dari database
              MarkerLayer(markers: myMarkers),
            ],
          );
        },
      ),
    );
  }
}
