import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // untuk Clipboard

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian header biru atas
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7BD5F5), Color(0xFF787FF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bar atas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Hi, Jonathan!",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Row(
                          children: const [
                            Icon(Icons.notifications_none,
                                color: Colors.white),
                            SizedBox(width: 10),
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 16,
                              child: Icon(Icons.person,
                                  color: Colors.grey, size: 18),
                            )
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Laporkan masalah perairanmu",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Kolom search
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "Search",
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Titik koordinat
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Titik koordinat anda saat ini",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.black87),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            "-7.372103200850368, 112.75061827576478",
                            style: TextStyle(
                                color: Colors.black87, fontSize: 13.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(const ClipboardData(
                                text:
                                    "-7.372103200850368, 112.75061827576478"));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("Koordinat disalin ke clipboard!"),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: const Icon(Icons.copy,
                              color: Colors.black87, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tombol utama (laporkan, daftar, lokasi)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _menuItem(Icons.assignment, "Laporkan"),
                    _menuItem(Icons.group_add, "Mendaftar\nsukarelawan"),
                    _menuItem(Icons.location_pin, "Lokasi\nbermasalah"),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Bagian laporan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  "Laporan di daerahmu saat ini",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),

              const SizedBox(height: 12),

              // List laporan
              _laporanItem(
                context,
                color: Colors.blue.shade50,
                statusColor: Colors.blue,
                title: "Sedang ditangani",
                koordinat: "-7.372071280403217, 112.75091130708668",
                jarak: "1.2 KM",
              ),
              _laporanItem(
                context,
                color: Colors.green.shade50,
                statusColor: Colors.green,
                title: "Sudah ditangani",
                koordinat: "-7.373071655332484, 112.74891733208254",
                jarak: "1.0 KM",
              ),
              _laporanItem(
                context,
                color: Colors.red.shade50,
                statusColor: Colors.red,
                title: "Belum terlaksana",
                koordinat: "-7.373748788249213, 112.74889454775858",
                jarak: "2.1 KM",
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Widget menu utama
  Widget _menuItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Icon(icon, color: Colors.black87, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12.5),
        )
      ],
    );
  }

  // Widget laporan
  Widget _laporanItem(BuildContext context,
      {required Color color,
      required Color statusColor,
      required String title,
      required String koordinat,
      required String jarak}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_pin_circle, color: statusColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  koordinat,
                  style: const TextStyle(fontSize: 13.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: koordinat));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Koordinat disalin: $title"),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: const Icon(Icons.copy, color: Colors.black54, size: 17),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  color: Colors.grey.shade600, size: 14),
              const SizedBox(width: 4),
              Text(jarak,
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              const SizedBox(width: 6),
              Text(title,
                  style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}
