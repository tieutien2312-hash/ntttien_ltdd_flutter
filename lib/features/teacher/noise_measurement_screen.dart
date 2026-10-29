import 'dart:async';
import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/noise_measurement_service.dart';
import '../../services/class_session_service.dart';
import '../../models/class_session_model.dart';
import '../../core/widgets/loading_widget.dart';

class NoiseMeasurementScreen extends StatefulWidget {
  const NoiseMeasurementScreen({super.key});

  @override
  State<NoiseMeasurementScreen> createState() => _NoiseMeasurementScreenState();
}

class _NoiseMeasurementScreenState extends State<NoiseMeasurementScreen> {
  final NoiseMeasurementService _noiseService = NoiseMeasurementService();
  final ClassSessionService _sessionService = ClassSessionService();
  
  late Future<List<ClassSessionModel>> _sessionsFuture;
  ClassSessionModel? _selectedSession;
  
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  bool _isMeasuring = false;
  double _decibels = 0.0;
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _sessionService.getTeacherSchedule();
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _startMeasuring() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ứng dụng cần quyền truy cập microphone để đo tiếng ồn')),
      );
      return;
    }

    try {
      _noiseMeter = NoiseMeter();
      _noiseSubscription = _noiseMeter?.noise.listen(
        (NoiseReading noiseReading) {
          setState(() {
            _decibels = noiseReading.meanDecibel;
          });
        },
        onError: (error) {
          debugPrint('Noise meter error: $error');
        },
      );
      setState(() => _isMeasuring = true);
    } catch (e) {
      debugPrint('Failed to start noise meter: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể khởi động đo tiếng ồn: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _stopMeasuring() {
    _noiseSubscription?.cancel();
    setState(() => _isMeasuring = false);
  }

  Future<void> _submitMeasurement() async {
    if (_selectedSession == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn buổi học')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _noiseService.submitMeasurement(
        classSessionId: _selectedSession!.id,
        decibelLevel: _decibels > 0 ? _decibels : 45.0,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi kết quả đo tiếng ồn thành công!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đo & Cảnh báo Tiếng ồn')),
      body: FutureBuilder<List<ClassSessionModel>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Đang tải danh sách buổi học...');
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          }

          final sessions = snapshot.data ?? [];
          if (sessions.isEmpty) {
            return const Center(child: Text('Không có buổi học nào được phân công.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  _isMeasuring ? Icons.mic : Icons.mic_off,
                  size: 80,
                  color: _isMeasuring ? Colors.red : Colors.indigo,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Đo lường Tiếng ồn Lớp học qua Microphone',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<ClassSessionModel>(
                  // ignore: deprecated_member_use
                  value: _selectedSession,
                  hint: const Text('Chọn buổi học'),
                  items: sessions.map((s) => DropdownMenuItem(
                    value: s,
                    child: Text('${s.courseName ?? "Môn học"} (${s.room ?? "Phòng học"})'),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedSession = val),
                  decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Buổi học'),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _decibels > 75 ? Colors.red : (_decibels > 60 ? Colors.orange : Colors.green),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${_decibels.toStringAsFixed(1)} dB',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: _decibels > 75 ? Colors.red : (_decibels > 60 ? Colors.orange : Colors.green),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _decibels > 75
                            ? '⚠️ Cảnh báo: Lớp học quá ồn ào!'
                            : (_decibels > 60
                                ? '⚠️ Tiếng ồn ở mức trung bình'
                                : '✅ Môi trường lớp học yên tĩnh'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _decibels > 75 ? Colors.red : (_decibels > 60 ? Colors.orange : Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isMeasuring ? Colors.red : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _isMeasuring ? _stopMeasuring : _startMeasuring,
                        icon: Icon(_isMeasuring ? Icons.stop : Icons.play_arrow),
                        label: Text(_isMeasuring ? 'Dừng đo' : 'Bắt đầu đo'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú tiếng ồn (tùy chọn)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitMeasurement,
                  icon: const Icon(Icons.send),
                  label: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Gửi kết quả đo lên hệ thống', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
