# Hướng dẫn Tạo Dữ liệu mẫu (Seeder) cho Backend ASP.NET Core

Tài liệu này cung cấp mã nguồn C# để tự động khởi tạo (Seed) các tài khoản mẫu (Admin, Giáo viên, Sinh viên), Môn học, Lịch học và Phiên điểm danh khi ứng dụng Backend khởi động trên Visual Studio.

---

## 1. Danh sách Tài khoản Mẫu dự kiến

| Vai trò (Role) | Email | Mật khẩu | Tên hiển thị |
| :--- | :--- | :--- | :--- |
| **Admin** | `admin@student.edu.vn` | `Admin@123` | Quản Trị Viên |
| **Teacher** | `teacher@student.edu.vn` | `Teacher@123` | Giảng Viên Mẫu |
| **Student** | `student@student.edu.vn` | `Student@123` | Sinh Viên Mẫu |

---

## 2. Mã nguồn `DbInitializer.cs`

Tạo file `Data/DbInitializer.cs` trong dự án ASP.NET Core của bạn:

```csharp
using Microsoft.AspNetCore.Identity;
using StudentAttendance.Api.Models;

namespace StudentAttendance.Api.Data
{
    public static class DbInitializer
    {
        public static async Task InitializeAsync(
            ApplicationDbContext context,
            UserManager<ApplicationUser> userManager,
            RoleManager<IdentityRole> roleManager)
        {
            // Đảm bảo database đã được tạo
            await context.Database.EnsureCreatedAsync();

            // 1. Tạo Roles
            string[] roles = { "Admin", "Teacher", "Student" };
            foreach (var role in roles)
            {
                if (!await roleManager.RoleExistsAsync(role))
                {
                    await roleManager.CreateAsync(new IdentityRole(role));
                }
            }

            // 2. Tạo Admin User
            if (await userManager.FindByEmailAsync("admin@student.edu.vn") == null)
            {
                var admin = new ApplicationUser
                {
                    UserName = "admin@student.edu.vn",
                    Email = "admin@student.edu.vn",
                    FullName = "Quản Trị Viên",
                    EmailConfirmed = true
                };
                var result = await userManager.CreateAsync(admin, "Admin@123");
                if (result.Succeeded)
                {
                    await userManager.AddToRoleAsync(admin, "Admin");
                }
            }

            // 3. Tạo Teacher User & Teacher Profile
            ApplicationUser teacherUser = null;
            if (await userManager.FindByEmailAsync("teacher@student.edu.vn") == null)
            {
                teacherUser = new ApplicationUser
                {
                    UserName = "teacher@student.edu.vn",
                    Email = "teacher@student.edu.vn",
                    FullName = "Giảng Viên Mẫu",
                    EmailConfirmed = true
                };
                var result = await userManager.CreateAsync(teacherUser, "Teacher@123");
                if (result.Succeeded)
                {
                    await userManager.AddToRoleAsync(teacherUser, "Teacher");
                }
            }
            else
            {
                teacherUser = await userManager.FindByEmailAsync("teacher@student.edu.vn");
            }

            // Tạo Teacher Profile entity nếu chưa có
            Teacher teacherEntity = null;
            if (teacherUser != null && !context.Teachers.Any(t => t.UserId == teacherUser.Id))
            {
                teacherEntity = new Teacher
                {
                    Id = Guid.NewGuid().ToString(),
                    UserId = teacherUser.Id,
                    TeacherCode = "GV001",
                    FullName = teacherUser.FullName,
                    Email = teacherUser.Email,
                    Department = "Công nghệ Thông tin"
                };
                context.Teachers.Add(teacherEntity);
                await context.SaveChangesAsync();
            }
            else
            {
                teacherEntity = context.Teachers.FirstOrDefault(t => t.UserId == teacherUser.Id);
            }

            // 4. Tạo Student User & Student Profile
            ApplicationUser studentUser = null;
            if (await userManager.FindByEmailAsync("student@student.edu.vn") == null)
            {
                studentUser = new ApplicationUser
                {
                    UserName = "student@student.edu.vn",
                    Email = "student@student.edu.vn",
                    FullName = "Sinh Viên Mẫu",
                    EmailConfirmed = true
                };
                var result = await userManager.CreateAsync(studentUser, "Student@123");
                if (result.Succeeded)
                {
                    await userManager.AddToRoleAsync(studentUser, "Student");
                }
            }
            else
            {
                studentUser = await userManager.FindByEmailAsync("student@student.edu.vn");
            }

            // Tạo Student Profile entity nếu chưa có
            Student studentEntity = null;
            if (studentUser != null && !context.Students.Any(s => s.UserId == studentUser.Id))
            {
                studentEntity = new Student
                {
                    Id = Guid.NewGuid().ToString(),
                    UserId = studentUser.Id,
                    StudentCode = "SV2024001",
                    FullName = studentUser.FullName,
                    Email = studentUser.Email,
                    ClassName = "CNTT K63",
                    Faculty = "Công nghệ Thông tin"
                };
                context.Students.Add(studentEntity);
                await context.SaveChangesAsync();
            }
            else
            {
                studentEntity = context.Students.FirstOrDefault(s => s.UserId == studentUser.Id);
            }

            // 5. Tạo Course mẫu
            if (!context.Courses.Any())
            {
                var course = new Course
                {
                    Id = Guid.NewGuid().ToString(),
                    CourseCode = "MMT101",
                    CourseName = "Lập trình Di động Flutter",
                    Description = "Học phần lập trình ứng dụng di động đa nền tảng với Flutter và ASP.NET Core.",
                    Credits = 3,
                    TeacherName = teacherEntity?.FullName
                };
                context.Courses.Add(course);
                await context.SaveChangesAsync();

                // Ghi danh sinh viên vào môn học
                if (studentEntity != null)
                {
                    context.StudentCourses.Add(new StudentCourse
                    {
                        StudentId = studentEntity.Id,
                        CourseId = course.Id
                    });
                }

                // Tạo ClassSession mẫu
                var classSession = new ClassSession
                {
                    Id = Guid.NewGuid().ToString(),
                    CourseId = course.Id,
                    CourseName = course.CourseName,
                    Room = "Phòng Lab 3",
                    SessionDate = DateTime.Today,
                    StartTime = "08:00",
                    EndTime = "11:30",
                    IsAttendanceOpen = true
                };
                context.ClassSessions.Add(classSession);

                // Tạo AttendanceSession mẫu (QR)
                context.AttendanceSessions.Add(new AttendanceSession
                {
                    Id = Guid.NewGuid().ToString(),
                    ClassSessionId = classSession.Id,
                    QrCodeToken = "QR_SAMPLE_TOKEN_123456",
                    ExpiresAt = DateTime.UtcNow.AddMinutes(60),
                    IsActive = true
                });

                await context.SaveChangesAsync();
            }
        }
    }
}
```

---

## 3. Gọi Seeder trong `Program.cs`

Mở file `Program.cs` và thêm đoạn code sau ngay trước khi gọi `app.Run()`:

```csharp
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<ApplicationDbContext>();
        var userManager = services.GetRequiredService<UserManager<ApplicationUser>>();
        var roleManager = services.GetRequiredService<RoleManager<IdentityRole>>();

        await DbInitializer.InitializeAsync(context, userManager, roleManager);
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "Đã xảy ra lỗi khi tạo dữ liệu mẫu.");
    }
}

app.Run();
```
