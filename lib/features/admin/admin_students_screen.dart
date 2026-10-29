import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../models/student_model.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/empty_state_widget.dart';

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  final UserService _userService = UserService();
  late Future<List<StudentModel>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() {
    _studentsFuture = _userService.getStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Sinh viên')),
      body: FutureBuilder<List<StudentModel>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Đang tải danh sách sinh viên...');
          } else if (snapshot.hasError) {
            return AppErrorWidget(
              message: snapshot.error.toString(),
              onRetry: () => setState(() => _loadStudents()),
            );
          }

          final students = snapshot.data ?? [];
          if (students.isEmpty) {
            return const EmptyStateWidget(message: 'Chưa có sinh viên nào trong hệ thống.', icon: Icons.person_off);
          }

          return RefreshIndicator(
            onRefresh: () async => setState(() => _loadStudents()),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Mã SV: ${student.studentCode} • Lớp: ${student.className ?? "N/A"}'),
                    trailing: Text(student.email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
