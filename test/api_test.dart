import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:explainmylessonai_mobile/services/api_service.dart';

class RealHttpOverrides extends HttpOverrides {
  @override
  // ignore: unnecessary_overrides
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context);
  }
}

void main() {
  setUp(() {
    HttpOverrides.global = RealHttpOverrides();
    ApiService.customBaseUrl = 'http://localhost:4000';
  });

  tearDown(() {
    HttpOverrides.global = null;
    ApiService.customBaseUrl = null;
  });

  test('Sync curriculum modules and active teacher module from live Backend', () async {
    // 1. Cek pengambilan modul kurikulum aktif pengajar
    final activeData = await ApiService.fetchActiveValidatedModule();
    expect(activeData, isNotNull);
    expect(activeData!['chapterCode'], isNotNull);

    // 2. Cek pengambilan seluruh daftar modul dari pengajar
    final modules = await ApiService.fetchCurriculumModules();
    expect(modules, isNotEmpty);
  });

  test('Check teacher point reset status and live classmates from Backend', () async {
    // 1. Cek endpoint status reset poin siswa
    final resetStatus = await ApiService.checkResetStatus();
    expect(resetStatus, isNotNull);
    expect(resetStatus!['isReset'], isNotNull);
    expect(resetStatus['resetAt'], isNotNull);

    // 2. Cek endpoint daftar siswa sekelas dari backend
    final classmates = await ApiService.fetchClassmates();
    expect(classmates, isNotEmpty);
  });
}
