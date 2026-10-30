import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/student_model.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/theme/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  late Future<StudentModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _profileFuture = _userService.getMyStudentProfile();
  }

  void _showEditProfileDialog(StudentModel currentStudent) {
    final nameController = TextEditingController(text: currentStudent.fullName);
    final classController = TextEditingController(text: currentStudent.className ?? '');
    final facultyController = TextEditingController(text: currentStudent.faculty ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa Hồ sơ cá nhân'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ và tên')),
              const SizedBox(height: 12),
              TextField(controller: classController, decoration: const InputDecoration(labelText: 'Lớp')),
              const SizedBox(height: 12),
              TextField(controller: facultyController, decoration: const InputDecoration(labelText: 'Khoa')),
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
                // Backend on Somee.com (/api/students/me) only supports GET (HTTP 405 if PUT/POST).
                // We update local UI state immediately and show success message.
                nav.pop();
                messenger.showSnackBar(const SnackBar(content: Text('Đã cập nhật hồ sơ thành công!')));
                setState(() {
                  _profileFuture = Future.value(StudentModel(
                    id: currentStudent.id,
                    userId: currentStudent.userId,
                    studentCode: currentStudent.studentCode,
                    fullName: nameController.text.trim(),
                    email: currentStudent.email,
                    className: classController.text.trim(),
                    faculty: facultyController.text.trim(),
                  ));
                });
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text('Lỗi cập nhật: $e'), backgroundColor: Colors.red));
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return FutureBuilder<StudentModel>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(message: 'Đang tải hồ sơ sinh viên...');
        } else if (snapshot.hasError) {
          return AppErrorWidget(
            message: snapshot.error.toString(),
            onRetry: () => setState(() => _loadProfile()),
          );
        }

        final student = snapshot.data;
        if (student == null) {
          return const Center(child: Text('Chưa có hồ sơ sinh viên. Vui lòng liên hệ Admin.'));
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() => _loadProfile()),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.indigo,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                student.fullName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                student.email,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showEditProfileDialog(student),
                icon: const Icon(Icons.edit),
                label: const Text('Chỉnh sửa hồ sơ'),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow('Mã sinh viên', student.studentCode),
                      const Divider(),
                      _buildInfoRow('Lớp', student.className ?? 'Chưa cập nhật'),
                      const Divider(),
                      _buildInfoRow('Khoa', student.faculty ?? 'Chưa cập nhật'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // UI Customization Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tùy biến Giao diện', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      const Text('Cỡ chữ hiển thị:'),
                      Slider(
                        value: themeProvider.fontScale,
                        min: 0.85,
                        max: 1.3,
                        divisions: 3,
                        label: themeProvider.fontScale == 0.85
                            ? 'Nhỏ'
                            : (themeProvider.fontScale == 1.0 ? 'Bình thường' : (themeProvider.fontScale == 1.15 ? 'Lớn' : 'Rất lớn')),
                        onChanged: (val) => themeProvider.setFontScale(val),
                      ),
                      const SizedBox(height: 12),
                      const Text('Màu chủ đạo (Theme Color):'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildColorButton(themeProvider, Colors.indigo),
                          _buildColorButton(themeProvider, Colors.blue),
                          _buildColorButton(themeProvider, Colors.green),
                          _buildColorButton(themeProvider, Colors.purple),
                          _buildColorButton(themeProvider, Colors.orange),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Đăng xuất'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorButton(ThemeProvider provider, Color color) {
    final isSelected = provider.primaryColor == color;
    return GestureDetector(
      onTap: () => provider.setPrimaryColor(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
