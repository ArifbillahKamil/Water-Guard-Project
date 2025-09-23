import 'package:flutter/material.dart';
import '../widgets/double_wave_header.dart';

class WorkerSignUpScreen extends StatefulWidget {
  const WorkerSignUpScreen({super.key});

  @override
  State<WorkerSignUpScreen> createState() => _WorkerSignUpScreenState();
}

class _WorkerSignUpScreenState extends State<WorkerSignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String? cvFileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            const SizedBox(
              height: 180,
              width: double.infinity,
              child: DoubleWaveHeader(),
            ),

            // Judul
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 16),
              child: Text(
                "Mendaftar sukarelawan",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4894FE),
                  shadows: [
                    Shadow(
                      offset: Offset(1, 3),
                      blurRadius: 3,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ),

            // Form
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Nama
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Nama",
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    // Tanggal lahir
                    TextFormField(
                      controller: dobController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Tanggal lahir",
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime(2000),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                dobController.text =
                                    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                              });
                            }
                          },
                        ),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    // Pendidikan
                    TextFormField(
                      controller: educationController,
                      decoration: const InputDecoration(
                        labelText: "Pendidikan",
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    // Nomor Telepon
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Nomor telepon",
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Wajib diisi";
                        }
                        if (!value.contains('@')) {
                          return "Email tidak valid";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Upload CV
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // TODO: implement upload file
                            setState(() {
                              cvFileName = "cv.pdf";
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD9EAFD),
                            minimumSize: const Size(100, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Unggah",
                            style: TextStyle(
                              color: Color(0xFF4894FE),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            cvFileName ?? "Unggah CV",
                            style: const TextStyle(color: Colors.black54),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Tombol Mendaftar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // TODO: aksi daftar
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD9EAFD),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          "Mendaftar",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4894FE),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
