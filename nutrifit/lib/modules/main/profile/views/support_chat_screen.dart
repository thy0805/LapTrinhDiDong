import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final String _userEmail = FirebaseAuth.instance.currentUser?.email ?? 'anonymous';

  Future<void> _pickAndSendMedia(bool isVideo) async {
    final picker = ImagePicker();
    XFile? file;
    
    if (isVideo) {
      file = await picker.pickVideo(source: ImageSource.gallery);
    } else {
      file = await picker.pickImage(source: ImageSource.gallery);
    }

    if (file == null) return;

    final docRef = await FirebaseFirestore.instance
        .collection('chats')
        .doc(_userEmail)
        .collection('messages')
        .add({
      'sender': _userEmail,
      'timestamp': FieldValue.serverTimestamp(),
      'type': isVideo ? 'video' : 'image',
      'mediaUrl': '',
      'isUploading': true,
    });

    try {
      final uploadUrl = await _uploadToCloudinary(file.path, isVideo);
      if (uploadUrl != null) {
        await docRef.update({
          'mediaUrl': uploadUrl,
          'isUploading': false,
        });

        FirebaseFirestore.instance.collection('chats').doc(_userEmail).set({
          'lastMessage': '[Gửi một ${isVideo ? 'video' : 'hình ảnh'}]',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'userEmail': _userEmail,
        }, SetOptions(merge: true));
      } else {
        await docRef.delete();
        Get.snackbar('Lỗi', 'Không thể tải file lên Cloudinary');
      }
    } catch (e) {
      await docRef.delete();
      Get.snackbar('Lỗi', 'Có lỗi xảy ra: $e');
    }
  }

  Future<String?> _uploadToCloudinary(String filePath, bool isVideo) async {
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
        Get.snackbar('Lỗi Cloudinary', 'Status: ${response.statusCode} - $responseData', duration: const Duration(seconds: 5));
      }
    } catch (e) {
      Get.snackbar('Lỗi Cloudinary', 'Exception: $e', duration: const Duration(seconds: 5));
    }
    return null;
  }

  void _sendMessage({String? mediaUrl, String type = 'text'}) {
    if (type == 'text' && _messageController.text.trim().isEmpty) return;

    final docData = {
      'sender': _userEmail,
      'timestamp': FieldValue.serverTimestamp(),
      'type': type,
    };

    if (type == 'text') {
      docData['text'] = _messageController.text.trim();
    } else {
      docData['mediaUrl'] = mediaUrl!;
    }

    FirebaseFirestore.instance.collection('chats').doc(_userEmail).collection('messages').add(docData);

    FirebaseFirestore.instance.collection('chats').doc(_userEmail).set({
      'lastMessage': type == 'text' ? _messageController.text.trim() : '[Gửi một ${type == 'video' ? 'video' : 'hình ảnh'}]',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'userEmail': _userEmail,
    }, SetOptions(merge: true));

    if (type == 'text') {
      _messageController.clear();
    }
  }

  void _showMediaPicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.image, color: Get.theme.colorScheme.primary),
              title: const Text('Gửi Hình Ảnh'),
              onTap: () {
                Get.back();
                _pickAndSendMedia(false);
              },
            ),
            ListTile(
              leading: Icon(Icons.video_collection, color: Get.theme.colorScheme.primary),
              title: const Text('Gửi Video'),
              onTap: () {
                Get.back();
                _pickAndSendMedia(true);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat với Nutritea'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(_userEmail)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    
                    final messages = snapshot.data!.docs;
                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index].data() as Map<String, dynamic>;
                        final isMe = msg['sender'] == _userEmail;
                        final time = msg['timestamp'] != null 
                            ? (msg['timestamp'] as Timestamp).toDate() 
                            : DateTime.now();
                        
                        return _buildChatBubble(msg, isMe, time);
                      },
                    );
                  },
                ),
              ),
              _buildMessageInput(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg, bool isMe, DateTime time) {
    final bubbleColor = isMe 
        ? Get.theme.colorScheme.primary 
        : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.grey.shade200);
    
    final textColor = isMe 
        ? Colors.white 
        : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black);

    final timeStr = DateFormat('HH:mm').format(time);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.purpleAccent,
              child: Text('🍵', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                      bottomLeft: !isMe ? const Radius.circular(0) : const Radius.circular(16),
                    ),
                  ),
                  child: _buildMessageContent(msg, textColor),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(timeStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMessageContent(Map<String, dynamic> msg, Color textColor) {
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
                child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
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
          width: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
        ),
      );
    } else if (type == 'video') {
      return ChatVideoPlayer(videoUrl: msg['mediaUrl']);
    }
    return Text(msg['text'] ?? '', style: TextStyle(color: textColor, fontSize: 14));
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.image, color: Get.theme.colorScheme.primary),
              onPressed: _showMediaPicker,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: Get.theme.colorScheme.primary),
              onPressed: () => _sendMessage(),
            ),
          ],
        ),
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
