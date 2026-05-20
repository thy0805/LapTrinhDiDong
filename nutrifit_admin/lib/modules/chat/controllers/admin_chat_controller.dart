import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminChatController extends GetxController {
  var chats = <Map<String, dynamic>>[].obs;
  var messages = <Map<String, dynamic>>[].obs;
  var isLoadingChats = true.obs;
  var isLoadingMessages = false.obs;
  var selectedChatId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToChats();
  }

  void _listenToChats() {
    FirebaseFirestore.instance
        .collection('chats')
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .listen((snapshot) {
      chats.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      isLoadingChats.value = false;
    });
  }

  void selectChat(String chatId) {
    selectedChatId.value = chatId;
    isLoadingMessages.value = true;
    _listenToMessages(chatId);
  }

  void _listenToMessages(String chatId) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      messages.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      isLoadingMessages.value = false;
    });
  }

  Future<void> sendAdminMessage(String text) async {
    if (selectedChatId.value.isEmpty || text.trim().isEmpty) return;

    final docData = {
      'sender': 'admin@nutrifit.com',
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'text',
      'text': text.trim(),
    };

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(selectedChatId.value)
        .collection('messages')
        .add(docData);

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(selectedChatId.value)
        .set({
      'lastMessage': text.trim(),
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<DocumentReference?> createTempMediaMessage(String type) async {
    if (selectedChatId.value.isEmpty) return null;

    final docData = {
      'sender': 'admin@nutrifit.com',
      'timestamp': FieldValue.serverTimestamp(),
      'type': type,
      'mediaUrl': '',
      'isUploading': true,
    };

    return await FirebaseFirestore.instance
        .collection('chats')
        .doc(selectedChatId.value)
        .collection('messages')
        .add(docData);
  }

  Future<void> updateMediaMessage(DocumentReference docRef, String mediaUrl, String type) async {
    await docRef.update({
      'mediaUrl': mediaUrl,
      'isUploading': false,
    });

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(selectedChatId.value)
        .set({
      'lastMessage': '[Gửi một ${type == 'video' ? 'video' : 'hình ảnh'}]',
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteMessage(DocumentReference docRef) async {
    await docRef.delete();
  }
}
