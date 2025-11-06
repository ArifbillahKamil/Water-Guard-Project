import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart'; // Penting, karena model kita pakai ini
import '../models/laporan_model.dart'; // Impor model laporan

class DetailLaporanSheet extends StatelessWidget {
  final LaporanMasalah laporan;

  const DetailLaporanSheet({super.key, required this.laporan});

  // Helper untuk mendapatkan data UI berdasarkan status
  Map<String, dynamic> _getStatusData(StatusLaporan status) {
    switch (status) {
      case StatusLaporan.verifikasi:
        return {
          'text': 'Lokasi dilaporkan sedang diverifikasi',
          'icon': Icons.analytics_outlined, // Mirip ikon di Frame 35171
          'color': Colors.blueGrey,
        };
      case StatusLaporan.ditangani:
        return {
          'text': 'Lokasi dilaporkan sedang ditangani',
          'icon': Icons.settings_outlined, // Ikon cog di Frame 35170
          'color': Colors.blue,
        };
      case StatusLaporan.selesai:
        return {
          'text': 'Laporan telah selesai ditangani',
          'icon': Icons.check_circle_outline,
          'color': Colors.green,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusData = _getStatusData(laporan.status);

    // Container ini adalah dasar dari bottom sheet
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Membuat sheet setinggi kontennya
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Garis handle abu-abu di tengah atas
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // --- Bagian Stepper Status ---
          _buildStatusStepper(laporan.status),
          const SizedBox(height: 24),

          // --- Bagian Lokasi yang dilaporkan ---
          const Text(
            'Lokasi yang dilaporkan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusData['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(statusData['icon'], color: statusData['color'], size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusData['text'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: statusData['color'],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Menampilkan koordinat dari package latlong2
                      Text(
                        '${laporan.koordinat.latitude}, ${laporan.koordinat.longitude}',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- Bagian Deskripsi masalah ---
          const Text(
            'Deskripsi masalah',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              'Catatan: ${laporan.deskripsi}',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
          // Padding tambahan di bawah agar tidak terlalu mepet
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  // --- Widget Internal untuk Stepper ---
  // Ini adalah widget untuk membuat Tampilan Stepper
  // (Verifikasi -> Sedang ditangani -> Selesai)
  Widget _buildStatusStepper(StatusLaporan currentStatus) {
    int currentStep;
    switch (currentStatus) {
      case StatusLaporan.verifikasi:
        currentStep = 0;
        break;
      case StatusLaporan.ditangani:
        currentStep = 1;
        break;
      case StatusLaporan.selesai:
        currentStep = 2;
        break;
    }

    return Row(
      children: [
        _buildStep('Diverifikasi', currentStep, 0),
        const Expanded(child: Divider(thickness: 1.5)), // Garis pemisah
        _buildStep('Sedang ditangani', currentStep, 1),
        const Expanded(child: Divider(thickness: 1.5)), // Garis pemisah
        _buildStep('Selesai', currentStep, 2),
      ],
    );
  }

  // Widget Internal untuk satu bulatan step
  Widget _buildStep(String title, int currentStep, int stepIndex) {
    bool isActive = currentStep == stepIndex;
    bool isCompleted = currentStep > stepIndex;

    Color circleColor = Colors.grey[300]!;
    Widget circleChild = Container();

    if (isActive) {
      // Warna biru untuk step yang "Sedang aktif"
      circleColor = Colors.blue;
      // Ini membuat lingkaran putih di dalam (seperti di gambar Frame 35170)
      circleChild = const Padding(
        padding: EdgeInsets.all(3.0),
        child: CircleAvatar(backgroundColor: Colors.white),
      );
    } else if (isCompleted) {
      // Warna hijau untuk step yang "Sudah selesai"
      circleColor = Colors.green;
      circleChild = const Icon(Icons.check, color: Colors.white, size: 16);
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: circleColor,
          child: circleChild,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.blue : Colors.black54,
          ),
        ),
      ],
    );
  }
}
