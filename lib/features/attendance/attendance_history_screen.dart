import 'package:flutter/material.dart';
import '../../services/attendance_service.dart';
import '../../models/attendance_record_model.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/empty_state_widget.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  late Future<List<AttendanceRecordModel>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    _historyFuture = _attendanceService.getMyAttendanceHistory();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AttendanceRecordModel>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(message: 'Đang tải lịch sử điểm danh...');
        } else if (snapshot.hasError) {
          return AppErrorWidget(
            message: snapshot.error.toString(),
            onRetry: () => setState(() => _loadHistory()),
          );
        }

        final records = snapshot.data ?? [];
        if (records.isEmpty) {
          return const EmptyStateWidget(message: 'Chưa có lịch sử điểm danh nào.', icon: Icons.history);
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() => _loadHistory()),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final isPresent = record.status == 'Present';
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isPresent ? Colors.green.shade100 : Colors.orange.shade100,
                    child: Icon(
                      isPresent ? Icons.check : Icons.access_time,
                      color: isPresent ? Colors.green : Colors.orange,
                    ),
                  ),
                  title: Text('Trạng thái: ${record.status}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Thời gian: ${record.checkInTime.toLocal()}'),
                  trailing: Chip(
                    label: Text(record.status),
                    backgroundColor: isPresent ? Colors.green.shade50 : Colors.orange.shade50,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
