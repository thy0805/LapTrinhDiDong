import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/material.dart';

class MailService {
  static const String _smtpHost = 'smtp.gmail.com';
  static const int _smtpPort = 587;
  static const String _fromEmail = '2001230640phat@gmail.com';
  static const String _fromName = 'Nutritea - NutriFit';
  static const String _smtpUsername = '2001230640phat@gmail.com';
  static const String _smtpPassword = 'scnyfmozfycxedwf';

  static final _smtpServer = SmtpServer(
    _smtpHost,
    port: _smtpPort,
    username: _smtpUsername,
    password: _smtpPassword,
    ignoreBadCertificate: true,
  );

  static Future<bool> sendEmail({
    required String toEmail,
    required String subject,
    required String htmlContent,
  }) async {
    try {
      final message = Message()
        ..from = const Address(_fromEmail, _fromName)
        ..recipients.add(toEmail)
        ..subject = subject
        ..html = htmlContent;

      final sendReport = await send(message, _smtpServer);
      debugPrint('Message sent: ${sendReport.toString()}');
      return true;
    } on MailerException catch (e) {
      debugPrint('Message not sent. \n${e.toString()}');
      for (var p in e.problems) {
        debugPrint('Problem: ${p.code}: ${p.msg}');
      }
      return false;
    }
  }

  static String _wrapHtml(String content, String userName) {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { 
            margin: 0; 
            padding: 0; 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background-color: #FFF0F5; 
            color: #333; 
          }
          .email-wrapper { 
            width: 100%; 
            background-color: #FFF0F5; 
            padding: 40px 0; 
          }
          .container { 
            max-width: 600px; 
            margin: 0 auto; 
            background: #ffffff; 
            border-radius: 30px; 
            overflow: hidden; 
            box-shadow: 0 10px 30px rgba(204, 143, 237, 0.2); 
            border: 2px solid #CC8FED;
          }
          .header { 
            background: linear-gradient(135deg, #CC8FED 0%, #6B50F6 100%); 
            padding: 40px 20px; 
            text-align: center; 
          }
          .header h1 { 
            color: white;
            margin: 0; 
            font-size: 28px; 
            text-transform: uppercase;
            letter-spacing: 2px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
          }
          .header .mascot {
            font-size: 50px;
            margin-bottom: 10px;
          }
          .content { 
            padding: 40px; 
            line-height: 1.8; 
            font-size: 16px;
          }
          .content p { margin-bottom: 20px; }
          .highlight {
            color: #6B50F6;
            font-weight: bold;
          }
          .footer { 
            background: #F7F8F8; 
            padding: 30px; 
            text-align: center; 
            font-size: 13px; 
            color: #7B6F72; 
            border-top: 1px solid #eee;
          }
          .btn { 
            display: inline-block; 
            padding: 15px 35px; 
            background: linear-gradient(135deg, #CC8FED 0%, #6B50F6 100%); 
            color: #ffffff !important; 
            text-decoration: none; 
            border-radius: 50px; 
            font-weight: bold; 
            margin-top: 20px; 
            box-shadow: 0 5px 15px rgba(107, 80, 246, 0.3);
          }
          .divider {
            height: 2px;
            background: #eee;
            margin: 30px 0;
          }
          .stats-box {
            background: #F8F4FF;
            border-radius: 20px;
            padding: 20px;
            margin: 20px 0;
            border: 1px dashed #CC8FED;
          }
          .stats-item {
            margin: 10px 0;
            font-weight: bold;
          }
        </style>
      </head>
      <body>
        <div class="email-wrapper">
          <div class="container">
            <div class="header">
              <div class="mascot">🍵</div>
              <h1>NutriFit - Nutritea</h1>
            </div>
            <div class="content">
              $content
            </div>
            <div class="footer">
              Email này được gửi tự động từ tổ đội <strong>NutriFit</strong>.<br>
              Nếu $userName thấy phiền thì cứ ngó lơ nhen, nhưng Nutritea sẽ buồn lắm đó! 🥺<br><br>
              © 2024 NutriFit Team. Made with 💖 for $userName.
            </div>
          </div>
        </div>
      </body>
      </html>
    ''';
  }

  static Future<void> sendWelcomeEmail(String toEmail, String userName) async {
    const subject =
        '🎉 Ting ting! Chào mừng bạn đến với nhà NutriFit! Nutritea đã đợi bạn mãi nè! 🍵';
    final content =
        '''
      <p>Chào <span class="highlight">$userName</span> nha! 👋</p>
      <p>Cuối cùng thì bạn cũng chịu gia nhập vũ trụ <span class="highlight">NutriFit</span> rồi! Mình là <strong>Nutritea</strong> 🍵 - linh vật kiêm "bảo mẫu" túc trực 24/7 để đồng hành cùng bạn trên con đường ăn ngon, ngủ kỹ, dáng xinh đây.</p>
      <p>Từ hôm nay, chúng mình sẽ cùng nhau lập kế hoạch tập luyện và ăn uống thật xịn xò nhé. Đừng lo lắng nếu thấy khó, vì đã có Nutritea ở đây cổ vũ bạn mỗi ngày rồi!</p>
      <p>Bạn đã sẵn sàng chưa? Mở app lên và bắt đầu hành trình ngay thôi nào! ✨</p>
      <center><a href="#" class="btn">VÀO APP NGAY LUÔN!</a></center>
    ''';
    await sendEmail(
      toEmail: toEmail,
      subject: subject,
      htmlContent: _wrapHtml(content, userName),
    );
  }

  static Future<void> sendPasswordChangeEmail(
    String toEmail,
    String userName,
  ) async {
    const subject =
        '🤫 Suỵt! Có ai đó vừa đổi chìa khóa nhà NutriFit đúng không ta?';
    final content =
        '''
      <p>Éc éc <span class="highlight">$userName</span> ơi! 🐷</p>
      <p>Nutritea vừa nhận được tin báo là mật khẩu tài khoản NutriFit của bạn vừa được thay đổi áo mới đó. Nếu đây đúng là bạn tự đổi thì tuyệt vời, ngó lơ chiếc email này đi nha!</p>
      <p>Nhưng mà... nếu bạn đang ngơ ngác không hiểu chuyện gì xảy ra, thì ôi thôi, <span class="highlight">có kẻ gian đột nhập rồi! 🚨</span> Hãy mau mau bấm vào nút bên dưới để giành lại quyền kiểm soát ngay và luôn nha!</p>
      <center><a href="#" class="btn">KHÔI PHỤC MẬT KHẨU</a></center>
    ''';
    await sendEmail(
      toEmail: toEmail,
      subject: subject,
      htmlContent: _wrapHtml(content, userName),
    );
  }

  static Future<void> sendNewDeviceEmail(
    String toEmail,
    String userName,
    String device,
    String time,
    String location,
  ) async {
    const subject =
        '🕵️‍♂️ Ủa alo? Nutritea phát hiện tín hiệu lạ từ một thiết bị mới!';
    final content =
        '''
      <p><span class="highlight">$userName</span> ơi, Nutritea vừa thấy tài khoản của bạn được đăng nhập từ một nơi lạ hoắc lạ huơ nè:</p>
      <div class="stats-box">
        <div class="stats-item">📱 Thiết bị: $device</div>
        <div class="stats-item">⏰ Thời gian: $time</div>
        <div class="stats-item">📍 Địa điểm: $location</div>
      </div>
      <p>Là bạn mua điện thoại mới, hay mượn máy bạn bè lướt app vậy ta? Nếu là bạn thì cho Nutritea thở phào nhẹ nhõm nha. Còn nếu không phải, thì mau chóng đổi mật khẩu để bảo vệ ngôi nhà chung của chúng mình nhé! 🛡️</p>
      <center><a href="#" class="btn">BẢO VỆ TÀI KHOẢN</a></center>
    ''';
    await sendEmail(
      toEmail: toEmail,
      subject: subject,
      htmlContent: _wrapHtml(content, userName),
    );
  }

  static Future<void> sendReminderEmail(
    String toEmail,
    String userName,
    String type,
  ) async {
    final subject = '⏰ Reng reng reng! Tới giờ vàng rồi $userName ơi!';
    final content =
        '''
      <p>Dậy đi, dậy đi, dậy đi!!! 📢</p>
      <p>Đã đến giờ <span class="highlight">$type</span> theo lịch trình rồi nè. Nutritea đã pha sẵn một ly trà tinh thần cực mạnh để tiếp sức cho bạn rồi đây!</p>
      <p>Đừng có viện cớ lười biếng nha, mục tiêu dáng đẹp sức khỏe vàng đang vẫy gọi kìa. Bấm vào app và check-in ngay cho Nutritea vui lòng đi nào! Xong việc Nutritea sẽ thưởng cho một ngàn nụ hôn! 😘</p>
      <center><a href="#" class="btn">CON ĐƯỜNG CỦA TÔI</a></center>
    ''';
    await sendEmail(
      toEmail: toEmail,
      subject: subject,
      htmlContent: _wrapHtml(content, userName),
    );
  }

  static Future<void> sendMissedGoalEmail(
    String toEmail,
    String userName,
    String goal,
  ) async {
    const subject =
        '🌧️ Nutritea buồn thiu... Hôm nay chúng mình chưa ngoan rồi...';
    final content =
        '''
      <p><span class="highlight">$userName</span> ơi... 🥺</p>
      <p>Hôm nay Nutritea ngồi đợi mãi mà không thấy bạn tick hoàn thành mục tiêu <span class="highlight">$goal</span>. Bạn bận rộn quá hay là lười biếng nhõng nhẽo một chút vậy?</p>
      <p>Buồn thì có buồn, nhưng Nutritea không giận lâu đâu. Dù sao thì hôm nay cũng qua rồi, nhưng ngày mai bạn nhất định phải hứa với Nutritea là sẽ cố gắng gấp đôi, gấp ba để bù lại đó nha! Cố lên, Nutritea luôn tin bạn làm được mà! 💪✨</p>
      <center><a href="#" class="btn">HỨA SẼ NGOAN</a></center>
    ''';
    await sendEmail(
      toEmail: toEmail,
      subject: subject,
      htmlContent: _wrapHtml(content, userName),
    );
  }

  static Future<void> sendPraiseEmail(String toEmail, String userName) async {
    const subject =
        '🔥 Oa oa oa! 100 điểm không có nhưng! Quá là cháy luôn! 🏆';
    final content =
        '''
      <p>Trời ơiii, ai mà xuất sắc quá vậy nè?! Chắc chắn là <span class="highlight">$userName</span> rồi! 🎉</p>
      <p>Nutritea đang vui muốn rớt nước mắt đây! Bạn không chỉ hoàn thành mục tiêu mà còn <span class="highlight">vượt chỉ tiêu quá trời quá đất</span> luôn. Tinh thần thép, nghị lực kim cương là đây chứ đâu!</p>
      <p>Phải ôm bạn một cái thật chặt mới được! Cứ giữ vững phong độ chói lọi này nhé, mục tiêu của chúng mình sắp thành hiện thực đến nơi rồi! Tự thưởng cho bản thân một phút tự hào đi nào! 🥰💖</p>
      <center><a href="#" class="btn">TÔI QUÁ ĐỈNH!</a></center>
    ''';
    await sendEmail(
      toEmail: toEmail,
      subject: subject,
      htmlContent: _wrapHtml(content, userName),
    );
  }

  static Future<void> sendInactivityEmail(
    String toEmail,
    String userName,
  ) async {
    const subject = '😤 Giận tím người! Bỏ bê Nutritea 3 ngày rồi đó nha! 💔';
    final content =
        '''
      <p>Alo alo, thuê bao quý khách hiện đang vùng phủ mền hay vùng phủ sóng vậy? 📞</p>
      <p><span class="highlight">$userName</span> đi đâu mà lặn mất tăm mất tích tròn 3 ngày không thèm ngó ngàng gì đến NutriFit vậy hả? Nutritea giận trét phấn không ăn luôn rồi đây nè! 😡</p>
      <p>Kế hoạch của chúng mình đang dang dở, bạn định bỏ cuộc giữa chừng sao? Không có chuyện đó đâu nha! Mau mau mở app lên, nhận lỗi với Nutritea rồi tiếp tục tập luyện đi. Chỉ cần bạn quay lại, Nutritea sẽ tha thứ hết! Lên là lên là lên!!! 🚀</p>
      <center><a href="#" class="btn">QUAY LẠI NGAY</a></center>
    ''';
    await sendEmail(
      toEmail: toEmail,
      subject: subject,
      htmlContent: _wrapHtml(content, userName),
    );
  }

  static Future<void> sendWeeklyReportEmail(
    String toEmail,
    String userName,
    String completedDays,
    String workoutMinutes,
    String message,
  ) async {
    const subject =
        '🎀 Cuối tuần rảnh rỗi, cùng Nutritea ngó lại thành quả 7 ngày qua nha!';
    final content =
        '''
      <p>Cuối tuần tới rồi <span class="highlight">$userName</span> ơi! 🌈</p>
      <p>Tạm gác lại mọi lo âu mệt mỏi, mình cùng ngồi xuống nhâm nhi tách trà và nhìn lại xem tuần qua chúng mình đã "đỉnh" cỡ nào nha:</p>
      <div class="stats-box">
        <div class="stats-item">✅ Số ngày hoàn thành: $completedDays ngày</div>
        <div class="stats-item">⏳ Tổng thời gian tập: $workoutMinutes phút</div>
      </div>
      <p><strong>Lời nhắn từ Nutritea:</strong> $message</p>
      <p>Tuần mới năng lượng mới, chúng mình cùng bùng nổ tiếp nha! ✨</p>
      <center><a href="#" class="btn">XEM CHI TIẾT TUẦN</a></center>
    ''';
    await sendEmail(
      toEmail: toEmail,
      subject: subject,
      htmlContent: _wrapHtml(content, userName),
    );
  }

  static Future<void> sendLevelUpEmail(
    String toEmail,
    String userName,
    int newLevel,
    String title,
  ) async {
    final subject =
        '🎊 Chúc mừng $userName đã thăng cấp Level $newLevel rực rỡ! 🎊';
    final content =
        '''
      <p>Oa oa oa! <span class="highlight">$userName</span> ơi, Nutritea vừa nhận được tin cực hót nè! 🔥</p>
      <p>Bạn đã chính thức cán mốc <span class="highlight">Level $newLevel</span> và nhận được danh hiệu cao quý: <strong>"$title"</strong>! 🏆</p>
      <div class="stats-box">
        <div class="stats-item">⭐ Cấp độ mới: Level $newLevel</div>
        <div class="stats-item">📜 Danh hiệu: $title</div>
      </div>
      <p>Chặng đường vừa qua bạn đã nỗ lực rất nhiều, Nutritea tự hào về bạn lắm đó! Đừng dừng lại nha, những thử thách thú vị và phần thưởng xịn xò khác đang chờ bạn ở phía trước kìa. Cố lênnnnn! 🚀✨</p>
      <center><a href="#" class="btn">TIẾP TỤC CHINH PHỤC</a></center>
    ''';
    await sendEmail(
      toEmail: toEmail,
      subject: subject,
      htmlContent: _wrapHtml(content, userName),
    );
  }

  static Future<void> sendAchievementEmail(
    String toEmail,
    String userName,
    String achievementName,
    String description,
    int expReward,
  ) async {
    final subject =
        '🏆 Đỉnh của chóp! Bạn vừa mở khóa thành tựu "$achievementName"!';
    final content =
        '''
      <p>Tin vui! Tin vui! <span class="highlight">$userName</span> vừa làm được một điều tuyệt vời nè! 🌟</p>
      <p>Nutritea xin chúc mừng bạn đã đạt được thành tựu: <span class="highlight">"$achievementName"</span>!</p>
      <div class="stats-box">
        <div class="stats-item">🏆 Thành tựu: $achievementName</div>
        <div class="stats-item">💡 Mô tả: $description</div>
        <div class="stats-item">🎮 Thưởng nóng: +$expReward EXP</div>
      </div>
      <p>Thành công này là minh chứng cho sự kiên trì và kỷ luật của bạn đó. Hãy tiếp tục "thu thập" thêm nhiều huy hiệu nữa để lấp đầy bộ sưu tập của mình nha! Nutritea sẽ luôn ở đây cổ vũ nhiệt tình! 💖🍵</p>
      <center><a href="#" class="btn">XEM BỘ SƯU TẬP</a></center>
    ''';
    await sendEmail(
      toEmail: toEmail,
      subject: subject,
      htmlContent: _wrapHtml(content, userName),
    );
  }

  static Future<bool> sendOtpEmail(
    String toEmail,
    String userName,
    String otpCode,
  ) async {
    final subject = 'NutriFit - Yeu cau thay doi mat khau';
    final content =
        '''
      <p>Chào $userName,</p>
      <p>Bạn vừa có yêu cầu thay đổi mật khẩu.</p>
      <p>Mã xác nhận 4 chữ số của bạn là: <strong>$otpCode</strong></p>
      <p>Vui lòng không chia sẻ mã này cho ai khác.</p>
    ''';
    return await sendEmail(
      toEmail: toEmail,
      subject: subject,
      htmlContent: _wrapHtml(content, userName),
    );
  }

  static Future<bool> sendEmailVerificationOtp(
    String toEmail,
    String userName,
    String otpCode,
  ) async {
    final subject = '🍵 Mã xác thực tài khoản NutriFit của bạn nè!';
    final content =
        '''
      <p>Chào <span class="highlight">$userName</span> nha! 👋</p>
      <p>Để hoàn tất đăng ký hoặc bảo mật tài khoản NutriFit, vui lòng nhập mã OTP xác thực bên dưới nhé:</p>
      <div class="stats-box" style="text-align: center; font-size: 24px; letter-spacing: 4px; font-weight: bold; color: #6B50F6;">
        $otpCode
      </div>
      <p>Mã này có hiệu lực trong vòng 5 phút. Vui lòng không chia sẻ mã này cho bất kỳ ai khác nha!</p>
    ''';
    return await sendEmail(
      toEmail: toEmail,
      subject: subject,
      htmlContent: _wrapHtml(content, userName),
    );
  }

  static Future<void> sendCuteScoldingEmail(
    String toEmail,
    String userName,
    String scoldingContent,
  ) async {
    final subject =
        '😤 Giận tím người! NutriTea gửi tối hậu thư trách móc $userName nè! 💔';
    final content =
        '''
      <p>Alo <span class="highlight">$userName</span> ơi! 📢</p>
      <p>$scoldingContent</p>
      <div class="divider"></div>
      <p>Mau mở app <strong>NutriFit</strong> lên hoàn thành mục tiêu ngay cho tui vui lòng đi nha! 😘</p>
      <center><a href="https://trasuatrantrau.id.vn" class="btn">MỞ NUTRIFIT NGAY LUÔN!</a></center>
    ''';
    await sendEmail(
      toEmail: toEmail,
      subject: subject,
      htmlContent: _wrapHtml(content, userName),
    );
  }
}
