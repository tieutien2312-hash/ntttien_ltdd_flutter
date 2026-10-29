# Hướng dẫn Tích hợp Gửi Email Thực tế bằng MailKit trong ASP.NET Core (.NET 8)

Tài liệu này hướng dẫn cách cấu hình và cài đặt thư viện **MailKit** trong dự án ASP.NET Core Web API trên Visual Studio để gửi mã OTP xác thực thực tế qua Gmail.

---

## Bước 1: Cài đặt NuGet Package MailKit

Mở **Package Manager Console** trong Visual Studio và chạy lệnh:

```shell
Install-Package MailKit
```

---

## Bước 2: Cấu hình `appsettings.json`

Thêm cấu hình SMTP của bạn vào file `appsettings.json`:

```json
{
  "EmailSettings": {
    "Server": "smtp.gmail.com",
    "Port": 587,
    "SenderName": "Hệ thống Điểm danh Sinh viên",
    "SenderEmail": "email_cua_ban@gmail.com",
    "Password": "mat_khau_ung_dung_gmail"
  }
}
```

> **Lưu ý về Mật khẩu ứng dụng Gmail (App Password):**
> 1. Bật xác thực 2 bước (2-Step Verification) cho tài khoản Google của bạn.
> 2. Truy cập [Google App Passwords](https://myaccount.google.com/apppasswords).
> 3. Tạo một App Password mới (chọn thiết bị là Khác / Mail).
> 4. Sao chép chuỗi 16 ký tự dán vào trường `"Password"` ở trên (không dùng mật khẩu đăng nhập thông thường của Gmail).

---

## Bước 3: Tạo lớp `EmailSender.cs`

Tạo thư mục `Services` trong dự án ASP.NET Core và thêm file `EmailSender.cs`:

```csharp
using MailKit.Net.Smtp;
using Microsoft.Extensions.Configuration;
using MimeKit;
using System.Threading.Tasks;

namespace StudentAttendance.Api.Services
{
    public interface IEmailSender
    {
        Task SendEmailAsync(string email, string subject, string message);
    }

    public class EmailSender : IEmailSender
    {
        private readonly IConfiguration _configuration;

        public EmailSender(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public async Task SendEmailAsync(string toEmail, string subject, string htmlMessage)
        {
            var emailSettings = _configuration.GetSection("EmailSettings");
            var server = emailSettings["Server"];
            var port = int.Parse(emailSettings["Port"] ?? "587");
            var senderName = emailSettings["SenderName"];
            var senderEmail = emailSettings["SenderEmail"];
            var password = emailSettings["Password"];

            var email = new MimeMessage();
            email.From.Add(new MailboxAddress(senderName, senderEmail));
            email.To.Add(MailboxAddress.Parse(toEmail));
            email.Subject = subject;

            var builder = new BodyBuilder { HtmlBody = htmlMessage };
            email.Body = builder.ToMessageBody();

            using var client = new SmtpClient();
            try
            {
                // Kết nối với SMTP server (SslOnConnect = false cho cổng 587 dùng StartTls)
                await client.ConnectAsync(server, port, MailKit.Security.SecureSocketOptions.StartTls);
                await client.AuthenticateAsync(senderEmail, password);
                await client.SendAsync(email);
            }
            catch (Exception ex)
            {
                // Ghi log lỗi gửi email
                Console.WriteLine($"Lỗi gửi email: {ex.Message}");
                throw;
            }
            finally
            {
                await client.DisconnectAsync(true);
            }
        }
    }
}
```

---

## Bước 4: Đăng ký dịch vụ trong `Program.cs`

Mở file `Program.cs` và đăng ký `IEmailSender` vào Dependency Injection container:

```csharp
builder.Services.AddTransient<IEmailSender, EmailSender>();
```

---

## Bước 5: Sử dụng trong `AuthController.cs`

Inject `IEmailSender` vào `AuthController` và gọi hàm khi đăng ký tài khoản:

```csharp
[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly IEmailSender _emailSender;

    public AuthController(UserManager<ApplicationUser> userManager, IEmailSender _emailSender)
    {
        _userManager = userManager;
        this._emailSender = _emailSender;
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterDto model)
    {
        var user = new ApplicationUser { UserName = model.Username ?? model.Email, Email = model.Email, FullName = model.FullName };
        var result = await _userManager.CreateAsync(user, model.Password);
        if (!result.Succeeded) return BadRequest(result.Errors);

        await _userManager.AddToRoleAsync(user, "Student");

        // Tạo mã OTP ngẫu nhiên 6 chữ số
        var otp = new Random().Next(100000, 999999).ToString();

        // Lưu OTP vào database hoặc cache gắn liền với email...

        // Gửi email thực tế
        await _emailSender.SendEmailAsync(
            model.Email,
            "Xác thực tài khoản Điểm danh Sinh viên",
            $"<h3>Xin chào {model.FullName},</h3><p>Mã OTP xác thực tài khoản của bạn là: <b>{otp}</b></p>"
        );

        return Ok(new { message = "Đăng ký thành công. Vui lòng kiểm tra email để nhận mã OTP." });
    }
}
```
