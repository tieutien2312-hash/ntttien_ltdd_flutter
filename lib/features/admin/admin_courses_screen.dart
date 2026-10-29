import 'package:flutter/material.dart';
import '../../services/course_service.dart';
import '../../models/course_model.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/empty_state_widget.dart';

class AdminCoursesScreen extends StatefulWidget {
  const AdminCoursesScreen({super.key});

  @override
  State<AdminCoursesScreen> createState() => _AdminCoursesScreenState();
}

class _AdminCoursesScreenState extends State<AdminCoursesScreen> {
  final CourseService _courseService = CourseService();
  late Future<List<CourseModel>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _loadCourses() {
    _coursesFuture = _courseService.getCourses();
  }

  void _showAddCourseDialog() {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final creditsController = TextEditingController(text: '3');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm Môn học mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: codeController, decoration: const InputDecoration(labelText: 'Mã môn (ví dụ: MMT101)')),
              const SizedBox(height: 12),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên môn học')),
              const SizedBox(height: 12),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Mô tả')),
              const SizedBox(height: 12),
              TextField(controller: creditsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số tín chỉ')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await _courseService.createCourse(
                  code: codeController.text.trim(),
                  name: nameController.text.trim(),
                  description: descController.text.trim(),
                  credits: int.tryParse(creditsController.text) ?? 3,
                );
                nav.pop();
                messenger.showSnackBar(const SnackBar(content: Text('Thêm môn học thành công!')));
                setState(() => _loadCourses());
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Môn học'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCourseDialog,
            tooltip: 'Thêm môn học',
          ),
        ],
      ),
      body: FutureBuilder<List<CourseModel>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Đang tải danh sách môn học...');
          } else if (snapshot.hasError) {
            return AppErrorWidget(
              message: snapshot.error.toString(),
              onRetry: () => setState(() => _loadCourses()),
            );
          }

          final courses = snapshot.data ?? [];
          if (courses.isEmpty) {
            return const EmptyStateWidget(message: 'Chưa có môn học nào.', icon: Icons.book_outlined);
          }

          return RefreshIndicator(
            onRefresh: () async => setState(() => _loadCourses()),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.indigo, child: Icon(Icons.book, color: Colors.white)),
                    title: Text(course.courseName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Mã: ${course.courseCode} • Tín chỉ: ${course.credits ?? 3}'),
                    trailing: Text(course.teacherName ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
