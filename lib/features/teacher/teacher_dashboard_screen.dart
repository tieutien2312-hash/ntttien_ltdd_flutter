import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/class_session_service.dart';
import '../../services/auth_service.dart';
import '../../models/class_session_model.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/empty_state_widget.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final ClassSessionService _sessionService = ClassSessionService();
  final AuthService _authService = AuthService();
  late Future<List<ClassSessionModel>> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  void _loadSchedule() {
    _scheduleFuture = _sessionService.getTeacherSchedule();
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giáo viên Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () => context.push('/teacher-noise'),
            tooltip: 'Đo tiếng ồn',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: FutureBuilder<List<ClassSessionModel>>(
        future: _scheduleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Đang tải lịch dạy...');
          } else if (snapshot.hasError) {
            return AppErrorWidget(
              message: snapshot.error.toString(),
              onRetry: () => setState(() => _loadSchedule()),
            );
          }

          final sessions = snapshot.data ?? [];
          if (sessions.isEmpty) {
            return const EmptyStateWidget(message: 'Không có lịch dạy nào được phân công.', icon: Icons.event_busy);
          }

          return RefreshIndicator(
            onRefresh: () async => setState(() => _loadSchedule()),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              session.courseName ?? 'Môn học',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Chip(
                              label: Text(session.room ?? 'Phòng học'),
                              backgroundColor: Colors.indigo.shade50,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Ngày: ${session.sessionDate.toLocal().toString().split(' ')[0]}'),
                        if (session.startTime != null && session.endTime != null)
                          Text('Thời gian: ${session.startTime} - ${session.endTime}'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  context.push('/teacher-qr', extra: session.id);
                                },
                                icon: const Icon(Icons.qr_code),
                                label: const Text('Tạo QR Điểm danh'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  context.push('/teacher-noise');
                                },
                                icon: const Icon(Icons.volume_up),
                                label: const Text('Đo tiếng ồn'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
