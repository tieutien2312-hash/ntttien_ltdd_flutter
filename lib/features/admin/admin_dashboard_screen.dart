import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/dashboard_service.dart';
import '../../services/auth_service.dart';
import '../../models/dashboard_model.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  final AuthService _authService = AuthService();
  late Future<DashboardModel> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _statsFuture = _dashboardService.getAdminDashboardStats();
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
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: FutureBuilder<DashboardModel>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Đang tải thống kê hệ thống...');
          } else if (snapshot.hasError) {
            return AppErrorWidget(
              message: snapshot.error.toString(),
              onRetry: () => setState(() => _loadData()),
            );
          }

          final stats = snapshot.data ?? DashboardModel(totalStudents: 0, totalTeachers: 0, totalCourses: 0, totalSessions: 0);

          return RefreshIndicator(
            onRefresh: () async => setState(() => _loadData()),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text('Tổng quan hệ thống', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard('Sinh viên', stats.totalStudents.toString(), Icons.school, Colors.blue),
                    _buildStatCard('Giáo viên', stats.totalTeachers.toString(), Icons.person, Colors.orange),
                    _buildStatCard('Môn học', stats.totalCourses.toString(), Icons.book, Colors.green),
                    _buildStatCard('Buổi học', stats.totalSessions.toString(), Icons.calendar_today, Colors.purple),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Quản lý chức năng', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.people, color: Colors.indigo),
                  title: const Text('Quản lý tài khoản Sinh viên'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/admin-students'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.book, color: Colors.indigo),
                  title: const Text('Quản lý môn học & Thêm môn'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/admin-courses'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                Icon(icon, color: color, size: 24),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
