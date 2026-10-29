import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/attendance_session_service.dart';
import '../../models/attendance_session_model.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import 'package:geolocator/geolocator.dart';

class QrSessionScreen extends StatefulWidget {
  final String classSessionId;

  const QrSessionScreen({super.key, required this.classSessionId});

  @override
  State<QrSessionScreen> createState() => _QrSessionScreenState();
}

class _QrSessionScreenState extends State<QrSessionScreen> {
  final AttendanceSessionService _attendanceSessionService = AttendanceSessionService();
  AttendanceSessionModel? _sessionModel;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _timer;
  int _secondsRemaining = 60;

  @override
  void initState() {
    super.initState();
    _createSession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _createSession() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Optional: Get current location for GPS verification if required
      double? lat, lng;
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          Position position = await Geolocator.getCurrentPosition();
          lat = position.latitude;
          lng = position.longitude;
        }
      } catch (_) {}

      final session = await _attendanceSessionService.createAttendanceSession(
        classSessionId: widget.classSessionId,
        latitude: lat,
        longitude: lng,
      );

      setState(() {
        _sessionModel = session;
        _isLoading = false;
        _secondsRemaining = 60;
      });

      _startCountdown();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _refreshQr();
      }
    });
  }

  Future<void> _refreshQr() async {
    if (_sessionModel == null) return;
    try {
      final refreshed = await _attendanceSessionService.refreshQrCode(_sessionModel!.id);
      setState(() {
        _sessionModel = refreshed;
        _secondsRemaining = 60;
      });
    } catch (_) {}
  }

  Future<void> _closeSession() async {
    if (_sessionModel == null) return;
    try {
      await _attendanceSessionService.closeSession(_sessionModel!.id);
      _timer?.cancel();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã đóng phiên điểm danh')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phiên Điểm Danh QR')),
      body: _isLoading
          ? const LoadingWidget(message: 'Đang khởi tạo phiên điểm danh...')
          : _errorMessage != null
              ? AppErrorWidget(message: _errorMessage!, onRetry: _createSession)
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Mã QR Điểm Danh',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              QrImageView(
                                data: _sessionModel?.qrCodeToken ?? 'N/A',
                                version: QrVersions.auto,
                                size: 200.0,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _sessionModel?.qrCodeToken ?? 'N/A',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Mã tự động làm mới sau: $_secondsRemaining giây',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _secondsRemaining < 10 ? Colors.red : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _refreshQr,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Làm mới ngay'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                onPressed: _closeSession,
                                icon: const Icon(Icons.stop),
                                label: const Text('Đóng phiên'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
