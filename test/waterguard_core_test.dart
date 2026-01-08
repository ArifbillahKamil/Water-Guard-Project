import 'package:flutter_test/flutter_test.dart';

// ===============================================================
// KELAS LOGIKA (Simulasi Logic yang ada di UI kamu saat ini)
// ===============================================================
class AppValidator {
  // 1. Logic Login/Register
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) return 'Email wajib diisi';
    if (!email.contains('@')) return 'Format email salah';
    return null; // Valid
  }

  static String? validatePassword(String? pass) {
    if (pass == null || pass.isEmpty) return 'Sandi wajib diisi';
    if (pass.length < 8) return 'Sandi minimal 8 karakter';
    return null; // Valid
  }

  // 2. Logic Laporan Masalah
  static String? validateReportInput(
    String title,
    String desc,
    String? location,
  ) {
    if (title.isEmpty) return 'Judul laporan tidak boleh kosong';
    if (desc.isEmpty) return 'Deskripsi tidak boleh kosong';
    if (location == null || location == 'Mencari lokasi...')
      return 'Lokasi belum ditemukan';
    return null; // Valid (Siap Kirim)
  }

  // 3. Logic Daftar Sukarelawan (File Size Check)
  // Return true jika file aman, false jika file ditolak
  static String checkFileSize(int sizeInBytes) {
    if (sizeInBytes == 0) return 'File kosong (0 bytes)';
    double sizeInKb = sizeInBytes / 1024;
    if (sizeInKb > 500) return 'File terlalu besar (>500KB)';
    return 'OK'; // Aman
  }

  // 4. Logic Lokasi Bermasalah (Parsing Koordinat)
  static Map<String, double>? parseCoordinate(String geoString) {
    try {
      // Input misal: "-7.1234, 112.5678"
      List<String> parts = geoString.split(',');
      if (parts.length != 2) return null;

      double lat = double.parse(parts[0].trim());
      double long = double.parse(parts[1].trim());

      return {'lat': lat, 'long': long};
    } catch (e) {
      return null; // Gagal parse
    }
  }
}

// ===============================================================
// UNIT TESTING SUITE
// ===============================================================
void main() {
  // FITUR 1: LOGIN & REGISTER
  group('Fitur 1 - Login & Register Logic', () {
    test('Email kosong harus ditolak', () {
      expect(AppValidator.validateEmail(''), 'Email wajib diisi');
    });
    test('Email tanpa @ harus ditolak', () {
      expect(AppValidator.validateEmail('budi.com'), 'Format email salah');
    });
    test('Password pendek harus ditolak', () {
      expect(AppValidator.validatePassword('123'), 'Sandi minimal 8 karakter');
    });
    test('Login valid harus lolos', () {
      expect(AppValidator.validateEmail('admin@waterguard.com'), null);
      expect(AppValidator.validatePassword('password123'), null);
    });
  });

  // FITUR 2: LAPORKAN MASALAH
  group('Fitur 2 - Validasi Laporan Masalah', () {
    test('Gagal jika judul kosong', () {
      var result = AppValidator.validateReportInput(
        '',
        'Ada banjir',
        '-7.5, 112.5',
      );
      expect(result, 'Judul laporan tidak boleh kosong');
    });
    test('Gagal jika lokasi belum didapat GPS', () {
      var result = AppValidator.validateReportInput(
        'Banjir',
        'Parah',
        'Mencari lokasi...',
      );
      expect(result, 'Lokasi belum ditemukan');
    });
    test('Laporan valid siap kirim', () {
      var result = AppValidator.validateReportInput(
        'Pipa Bocor',
        'Air meluap di jalan',
        '-7.25, 112.75',
      );
      expect(result, null); // Null artinya sukses validasi
    });
  });

  // FITUR 3: DAFTAR SUKARELAWAN
  group('Fitur 3 - Logika Upload File CV', () {
    test('File 0 Byte (Kosong) harus ditolak', () {
      expect(AppValidator.checkFileSize(0), 'File kosong (0 bytes)');
    });
    test('File 1 MB (1024*1024 bytes) harus ditolak (Limit 500KB)', () {
      expect(
        AppValidator.checkFileSize(1048576),
        'File terlalu besar (>500KB)',
      );
    });
    test('File 200 KB harus diterima', () {
      // 200 KB * 1024 = 204800 bytes
      expect(AppValidator.checkFileSize(204800), 'OK');
    });
  });

  // FITUR 4: LOKASI BERMASALAH (PETA)
  group('Fitur 4 - Parsing Data Lokasi', () {
    test('String koordinat valid harus jadi angka', () {
      var result = AppValidator.parseCoordinate("-7.123, 112.456");
      expect(result!['lat'], -7.123);
      expect(result['long'], 112.456);
    });

    test('String koordinat sampah harus return null (Error Handling)', () {
      var result = AppValidator.parseCoordinate("Lokasi Tidak Diketahui");
      expect(result, null);
    });
  });
}
