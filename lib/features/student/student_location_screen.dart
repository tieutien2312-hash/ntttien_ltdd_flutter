import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/widgets/loading_widget.dart';

class StudentLocationScreen extends StatefulWidget {
  const StudentLocationScreen({super.key});

  @override
  State<StudentLocationScreen> createState() => _StudentLocationScreenState();
}

class _StudentLocationScreenState extends State<StudentLocationScreen> {
  bool _isLoading = true;
  Position? _currentPosition;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _useDefaultLocation('Dịch vụ GPS đang tắt. Sử dụng vị trí mặc định.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _useDefaultLocation('Quyền vị trí bị từ chối. Sử dụng vị trí mặc định.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _useDefaultLocation('Quyền vị trí bị từ chối vĩnh viễn. Sử dụng vị trí mặc định.');
        return;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 6),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position != null) {
        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });
      } else {
        _useDefaultLocation('Không thể lấy tọa độ GPS thực tế. Sử dụng vị trí mặc định.');
      }
    } catch (e) {
      _useDefaultLocation('Lỗi định vị: $e');
    }
  }

  void _useDefaultLocation(String reason) {
    setState(() {
      _currentPosition = Position(
        latitude: 10.762622,
        longitude: 106.660172,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 1.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
      _errorMessage = reason;
      _isLoading = false;
    });
  }

  void _shareLocation() {
    if (_currentPosition == null) return;
    final text = '📍 Vị trí hiện tại của tôi (Điểm danh sinh viên):\n'
        'Vĩ độ (Latitude): ${_currentPosition!.latitude}\n'
        'Kinh độ (Longitude): ${_currentPosition!.longitude}\n'
        'Độ chính xác: ${_currentPosition!.accuracy.toStringAsFixed(1)} mét\n'
        'Google Maps: https://maps.google.com/?q=${_currentPosition!.latitude},${_currentPosition!.longitude}';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chia sẻ Vị trí GPS')),
      body: _isLoading
          ? const LoadingWidget(message: 'Đang xác định tọa độ GPS của bạn...')
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.my_location, size: 80, color: Colors.indigo),
                  const SizedBox(height: 16),
                  const Text(
                    'Tọa độ Vị trí Hiện tại',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.orange, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          _buildLocationRow('Vĩ độ (Lat)', '${_currentPosition!.latitude}'),
                          const Divider(),
                          _buildLocationRow('Kinh độ (Lng)', '${_currentPosition!.longitude}'),
                          const Divider(),
                          _buildLocationRow('Độ chính xác', '${_currentPosition!.accuracy.toStringAsFixed(1)} mét'),
                          const Divider(),
                          _buildLocationRow('Thời gian', DateTime.now().toLocal().toString().split('.')[0]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _shareLocation,
                    icon: const Icon(Icons.share),
                    label: const Text('Chia sẻ vị trí qua Zalo / Messenger', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _determinePosition,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Làm mới tọa độ GPS'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLocationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
