import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/course_service.dart';
import '../../models/course_model.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../attendance/attendance_history_screen.dart';
import '../profile/profile_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  final CourseService _courseService = CourseService();
  late Future<List<CourseModel>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _loadCourses() {
    _coursesFuture = _courseService.getMyEnrolledCourses();
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
        title: const Text('Sinh viên Dashboard'),
        actions: [
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
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Tab 0: Home / Courses
          FutureBuilder<List<CourseModel>>(
            future: _coursesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingWidget(message: 'Đang tải môn học đã đăng ký...');
              } else if (snapshot.hasError) {
                return AppErrorWidget(
                  message: snapshot.error.toString(),
                  onRetry: () => setState(() => _loadCourses()),
                );
              }

              final courses = snapshot.data ?? [];
              return RefreshIndicator(
                onRefresh: () async => setState(() => _loadCourses()),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Colors.indigo.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Quét mã QR Điểm Danh', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                            const SizedBox(height: 8),
                            const Text('Sử dụng camera để quét mã QR điểm danh buổi học trực tiếp trên lớp.'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => context.push('/student-qr-scanner'),
                              icon: const Icon(Icons.qr_code_scanner),
                              label: const Text('Quét QR Ngay'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Môn học đã đăng ký (${courses.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (courses.isEmpty)
                      const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('Chưa có môn học nào được ghi danh.')))
                    else
                      ...courses.map((course) => Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(course.courseName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Mã môn: ${course.courseCode} ${course.teacherName != null ? "• GV: ${course.teacherName}" : ""}'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                // Course details
                              },
                            ),
                          )),
                  ],
                ),
              );
            },
          ),
          // Tab 1: Attendance History
          const AttendanceHistoryScreen(),
          // Tab 2: Profile
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Trang chủ'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'Điểm danh'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}
