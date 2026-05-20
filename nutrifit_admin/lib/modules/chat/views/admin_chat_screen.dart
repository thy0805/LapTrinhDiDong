import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:nutrifit_admin/core/theme/tailadmin_design_system.dart';
import 'package:nutrifit_admin/modules/chat/controllers/admin_chat_controller.dart';
import 'package:video_player/video_player.dart';

class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({super.key});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final _chatController = Get.put(AdminChatController());
  final _messageController = TextEditingController();

  Future<void> _pickAndSendMedia() async {
    final result = await FilePicker.pickFiles(
      type: FileType.media,
      allowMultiple: false,
      withData: true,
    );

    if (result == null) return;
    final file = result.files.single;
    final isVideo =
        file.name.toLowerCase().endsWith('.mp4') ||
        file.name.toLowerCase().endsWith('.mov') ||
        file.name.toLowerCase().endsWith('.avi');

    final tempDoc = await _chatController.createTempMediaMessage(
      isVideo ? 'video' : 'image',
    );
    if (tempDoc == null) return;

    try {
      String? uploadUrl;
      if (file.bytes != null) {
        uploadUrl = await _uploadBytesToCloudinary(
          file.bytes!,
          file.name,
          isVideo,
        );
      } else if (!kIsWeb && file.path != null) {
        uploadUrl = await _uploadPathToCloudinary(file.path!, isVideo);
      }

      if (uploadUrl != null) {
        await _chatController.updateMediaMessage(
          tempDoc,
          uploadUrl,
          isVideo ? 'video' : 'image',
        );
      } else {
        await _chatController.deleteMessage(tempDoc);
        Get.snackbar('Lỗi', 'Không thể tải file lên Cloudinary');
      }
    } catch (e) {
      await _chatController.deleteMessage(tempDoc);
      Get.snackbar('Lỗi', 'Có lỗi xảy ra: $e');
    }
  }

  Future<String?> _uploadBytesToCloudinary(
    Uint8List bytes,
    String fileName,
    bool isVideo,
  ) async {
    try {
      final typeStr = 'auto';
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/dhhhclbra/$typeStr/upload'),
      );
      request.fields['upload_preset'] = 'ml_default';
      request.fields['folder'] = 'chat';
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        return json.decode(responseData)['secure_url'];
      } else {
        Get.snackbar(
          'Lỗi Cloudinary',
          'Status: ${response.statusCode} - $responseData',
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi Cloudinary',
        'Exception: $e',
        duration: const Duration(seconds: 5),
      );
    }
    return null;
  }

  Future<String?> _uploadPathToCloudinary(String filePath, bool isVideo) async {
    try {
      final typeStr = 'auto';
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/dhhhclbra/$typeStr/upload'),
      );
      request.fields['upload_preset'] = 'ml_default';
      request.fields['folder'] = 'chat';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        return json.decode(responseData)['secure_url'];
      } else {
        Get.snackbar(
          'Lỗi Cloudinary',
          'Status: ${response.statusCode} - $responseData',
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi Cloudinary',
        'Exception: $e',
        duration: const Duration(seconds: 5),
      );
    }
    return null;
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    _chatController.sendAdminMessage(_messageController.text.trim());
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 120,
      decoration: BoxDecoration(
        color: TailAdminDesign.bgCard,
        borderRadius: BorderRadius.circular(TailAdminDesign.radiusLg),
        boxShadow: TailAdminDesign.shadowDefault,
      ),
      child: Stack(
        children: [
          Row(
            children: [
              _buildChatListPane(),
              const VerticalDivider(width: 1),
              Expanded(child: _buildChatRoomPane()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatListPane() {
    return SizedBox(
      width: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Hộp thoại Chat Live',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TailAdminDesign.textMain,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Obx(() {
              if (_chatController.isLoadingChats.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_chatController.chats.isEmpty) {
                return Center(
                  child: Text(
                    'Chưa có cuộc trò chuyện nào',
                    style: GoogleFonts.outfit(
                      color: TailAdminDesign.textMuted,
                      fontSize: 14,
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: _chatController.chats.length,
                itemBuilder: (context, index) {
                  final chat = _chatController.chats[index];
                  final email = chat['userEmail'] ?? 'anonymous';
                  final lastMsg = chat['lastMessage'] ?? '';
                  final isSelected =
                      _chatController.selectedChatId.value == chat['id'];

                  final avatarUrl =
                      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(email)}&background=465FFF&color=fff';

                  return Container(
                    color: isSelected
                        ? TailAdminDesign.brand500.withValues(alpha: 0.08)
                        : Colors.transparent,
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(avatarUrl),
                      ),
                      title: Text(
                        email,
                        style: GoogleFonts.outfit(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: TailAdminDesign.textMain,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        lastMsg,
                        style: GoogleFonts.outfit(
                          color: isSelected
                              ? TailAdminDesign.brand500
                              : TailAdminDesign.textMuted,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _chatController.selectChat(chat['id']),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoomPane() {
    return Obx(() {
      final activeChat = _chatController.selectedChatId.value;
      if (activeChat.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.forum_outlined,
                size: 60,
                color: TailAdminDesign.textMuted.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Hãy chọn một cuộc trò chuyện từ danh sách\nbên trái để bắt đầu chat live với người dùng nhen!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: TailAdminDesign.textMuted,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }

      final chatUser = _chatController.chats.firstWhereOrNull(
        (c) => c['id'] == activeChat,
      );
      final email = chatUser?['userEmail'] ?? 'anonymous';
      final avatarUrl =
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(email)}&background=465FFF&color=fff';

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: TailAdminDesign.border)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      email,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: TailAdminDesign.textMain,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Người dùng NutriFit - Đang trực tuyến',
                      style: GoogleFonts.outfit(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_chatController.isLoadingMessages.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: _chatController.messages.length,
                itemBuilder: (context, index) {
                  final msg = _chatController.messages[index];
                  final isMe = msg['sender'] != email;
                  final time = msg['timestamp'] != null
                      ? (msg['timestamp'] as Timestamp).toDate()
                      : DateTime.now();

                  return _buildAdminBubble(msg, isMe, time, avatarUrl);
                },
              );
            }),
          ),
          _buildAdminInputArea(),
        ],
      );
    });
  }

  Widget _buildAdminBubble(
    Map<String, dynamic> msg,
    bool isMe,
    DateTime time,
    String userAvatar,
  ) {
    final bubbleColor = isMe
        ? TailAdminDesign.brand500
        : (TailAdminDesign.isDark
              ? const Color(0xFF1E293B)
              : Colors.grey.shade100);

    final textColor = isMe ? Colors.white : TailAdminDesign.textMain;
    final timeStr = DateFormat('HH:mm').format(time);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(radius: 14, backgroundImage: NetworkImage(userAvatar)),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight: isMe
                          ? const Radius.circular(0)
                          : const Radius.circular(16),
                      bottomLeft: !isMe
                          ? const Radius.circular(0)
                          : const Radius.circular(16),
                    ),
                  ),
                  child: _buildAdminMessageContent(msg, textColor),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    timeStr,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: TailAdminDesign.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(
                'https://ui-avatars.com/api/?name=Admin&background=465FFF&color=fff',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdminMessageContent(Map<String, dynamic> msg, Color textColor) {
    final type = msg['type'] ?? 'text';
    final isUploading = msg['isUploading'] ?? false;

    if (isUploading) {
      return SizedBox(
        width: 150,
        height: 100,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Đang gửi...',
                style: TextStyle(color: textColor, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    if (type == 'image') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          msg['mediaUrl'],
          width: 250,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 50),
        ),
      );
    } else if (type == 'video') {
      return ChatVideoPlayer(videoUrl: msg['mediaUrl']);
    }
    return Text(
      msg['text'] ?? '',
      style: GoogleFonts.outfit(color: textColor, fontSize: 14),
    );
  }

  Widget _buildAdminInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: TailAdminDesign.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.image_outlined, color: TailAdminDesign.brand500),
            onPressed: _pickAndSendMedia,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _messageController,
              style: GoogleFonts.outfit(color: TailAdminDesign.textMain),
              decoration: InputDecoration(
                hintText: 'Nhập phản hồi live cho người dùng...',
                hintStyle: GoogleFonts.outfit(color: TailAdminDesign.textMuted),
                filled: true,
                fillColor: TailAdminDesign.isDark
                    ? TailAdminDesign.darkBg
                    : Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send_rounded, color: TailAdminDesign.brand500),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class ChatVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const ChatVideoPlayer({super.key, required this.videoUrl});

  @override
  State<ChatVideoPlayer> createState() => _ChatVideoPlayerState();
}

class _ChatVideoPlayerState extends State<ChatVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _isDragging = false;
  double _dragValue = 0.0;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      });
    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    if (mounted && !_isDragging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _openFullscreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullscreenVideoPlayer(
          controller: _controller,
          videoUrl: widget.videoUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        width: 250,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.purpleAccent),
        ),
      );
    }

    final duration = _controller.value.duration;
    final position = _isDragging 
        ? Duration(milliseconds: _dragValue.toInt()) 
        : _controller.value.position;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 250,
        color: Colors.black,
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showControls = !_showControls;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),
                AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: IgnorePointer(
                    ignoring: !_showControls,
                    child: Stack(
                      children: [
                        Container(
                          color: Colors.black45,
                        ),
                        Center(
                          child: IconButton(
                            iconSize: 56,
                            icon: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              color: Colors.white,
                            ),
                            onPressed: _togglePlay,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  _isMuted ? Icons.volume_off : Icons.volume_up,
                                  color: Colors.white,
                                ),
                                onPressed: _toggleMute,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.fullscreen,
                                  color: Colors.white,
                                ),
                                onPressed: _openFullscreen,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, Colors.black87],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _formatDuration(position),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          trackHeight: 4,
                                          thumbShape: const RoundSliderThumbShape(
                                            enabledThumbRadius: 6,
                                          ),
                                          overlayShape: const RoundSliderOverlayShape(
                                            overlayRadius: 14,
                                          ),
                                          activeTrackColor: Colors.purpleAccent,
                                          inactiveTrackColor: Colors.white30,
                                          thumbColor: Colors.purpleAccent,
                                        ),
                                        child: Slider(
                                          value: position.inMilliseconds
                                              .toDouble()
                                              .clamp(
                                                0.0,
                                                duration.inMilliseconds.toDouble(),
                                              ),
                                          max: duration.inMilliseconds.toDouble(),
                                          onChangeStart: (value) {
                                            setState(() {
                                              _isDragging = true;
                                              _dragValue = value;
                                            });
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                              _dragValue = value;
                                            });
                                          },
                                          onChangeEnd: (value) {
                                            _controller.seekTo(
                                              Duration(milliseconds: value.toInt()),
                                            ).then((_) {
                                              setState(() {
                                                _isDragging = false;
                                              });
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(duration),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FullscreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final String videoUrl;
  const FullscreenVideoPlayer({
    super.key,
    required this.controller,
    required this.videoUrl,
  });

  @override
  State<FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  bool _showControls = true;
  bool _isDragging = false;
  double _dragValue = 0.0;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _isMuted = widget.controller.value.volume == 0.0;
    widget.controller.addListener(_videoListener);
  }

  void _videoListener() {
    if (mounted && !_isDragging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_videoListener);
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _togglePlay() {
    setState(() {
      if (widget.controller.value.isPlaying) {
        widget.controller.pause();
      } else {
        widget.controller.play();
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      widget.controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.controller.value.duration;
    final position = _isDragging 
        ? Duration(milliseconds: _dragValue.toInt()) 
        : widget.controller.value.position;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio,
                child: VideoPlayer(widget.controller),
              ),
            ),
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: Stack(
                  children: [
                    Container(
                      color: Colors.black26,
                    ),
                    Positioned(
                      top: 40,
                      left: 16,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Center(
                      child: IconButton(
                        iconSize: 72,
                        icon: Icon(
                          widget.controller.value.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: Colors.white,
                        ),
                        onPressed: _togglePlay,
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 16,
                      child: IconButton(
                        icon: Icon(
                          _isMuted ? Icons.volume_off : Icons.volume_up,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: _toggleMute,
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _formatDuration(position),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 6,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 18,
                                  ),
                                  activeTrackColor: Colors.purpleAccent,
                                  inactiveTrackColor: Colors.white30,
                                  thumbColor: Colors.purpleAccent,
                                ),
                                child: Slider(
                                  value: position.inMilliseconds
                                      .toDouble()
                                      .clamp(
                                        0.0,
                                        duration.inMilliseconds.toDouble(),
                                      ),
                                  max: duration.inMilliseconds.toDouble(),
                                  onChangeStart: (value) {
                                    setState(() {
                                      _isDragging = true;
                                      _dragValue = value;
                                    });
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _dragValue = value;
                                    });
                                  },
                                  onChangeEnd: (value) {
                                    widget.controller.seekTo(
                                      Duration(milliseconds: value.toInt()),
                                    ).then((_) {
                                      setState(() {
                                        _isDragging = false;
                                      });
                                    });
                                  },
                                ),
                              ),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
