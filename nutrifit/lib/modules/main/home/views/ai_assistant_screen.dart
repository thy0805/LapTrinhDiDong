import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrifit/modules/main/home/controllers/ai_assistant_controller.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/workout_controller.dart';
import 'package:nutrifit/modules/main/target/nutrition/controllers/nutrition_controller.dart';

class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiAssistantController());
    final TextEditingController textController = TextEditingController();
    final ScrollController scrollController = ScrollController();

    void scrollToBottom() {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                ),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trợ lý ảo NutriTea',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Đang trực tuyến',
                  style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            onPressed: () {
              controller.clearChat();
              scrollToBottom();
            },
            tooltip: 'Xóa trò chuyện',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              scrollToBottom();
              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  final isUser = msg["role"] == "user";
                  final isImage = msg["isImage"] == true;
                  
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isUser) ...[
                           CircleAvatar(
                             radius: 16,
                             backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                             child: const Text('🍵', style: TextStyle(fontSize: 16)),
                           ),
                           const SizedBox(width: 8),
                        ],
                        Column(
                          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                              padding: isImage ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isImage ? Colors.transparent : (isUser
                                    ? null
                                    : (Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade900
                                        : Colors.grey.shade100)),
                                gradient: (!isImage && isUser)
                                    ? LinearGradient(
                                        colors: [
                                          Theme.of(context).colorScheme.primary,
                                          Theme.of(context).colorScheme.secondary,
                                        ],
                                      )
                                    : null,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(20),
                                  topRight: const Radius.circular(20),
                                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                                  bottomRight: Radius.circular(isUser ? 4 : 20),
                                ),
                                boxShadow: (!isImage && isUser)
                                    ? [
                                        BoxShadow(
                                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: isImage && msg["imagePath"] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.file(
                                        File(msg["imagePath"]),
                                        width: 220,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildMessageContent(context, msg["content"] ?? '', isUser),
                                        if (!isUser && msg["planData"] != null && msg["planConfirmed"] != true && msg["planCanceled"] != true)
                                          _buildMiniPlanCard(context, msg["planData"], controller, index),
                                        if (!isUser && msg["planConfirmed"] == true)
                                          Container(
                                            margin: const EdgeInsets.only(top: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                                const SizedBox(width: 6),
                                                const Text("Đã áp dụng lịch", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                                                const SizedBox(width: 12),
                                                GestureDetector(
                                                  onTap: () => controller.deleteConfirmedPlan(index),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red.withValues(alpha: 0.2),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: const Text(
                                                      "Hủy / Xóa lịch",
                                                      style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                            ),
                            if (!isUser && msg["sticker"] != null && msg["sticker"].toString().isNotEmpty)
                              AnimatedSticker(stickerPath: msg["sticker"]),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              final text = controller.isPredicting.value ? 'NutriTea đang ngửi món ăn nhen... 👃' : 'NutriTea đang suy nghĩ nhen... 🤔';
              return Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Obx(() {
            if (controller.isContextLoaded.value) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.psychology, color: Theme.of(context).colorScheme.primary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "NutriTea đang ngậm sẵn data bài tập & món ăn rồi nhen! 🧠",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            height: 48,
            child: Obx(() {
              final step = controller.wizardStep.value;
              if (step == 0) {
                return ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        label: Text(
                          "📋 Nạp Ăn & Tập 🧠",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade700,
                          ),
                        ),
                        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade100,
                        side: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300,
                          width: 0.8,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onPressed: () {
                          controller.startWizard();
                        },
                      ),
                    ),
                    _buildSuggestionChip(context, "Gợi ý lịch ăn 🥗", textController, controller, scrollToBottom),
                    _buildSuggestionChip(context, "Tập gì giảm bụng? 🏋️", textController, controller, scrollToBottom),
                    _buildSuggestionChip(context, "Uống nước sao đúng? 💧", textController, controller, scrollToBottom),
                    _buildSuggestionChip(context, "Món nào ít calo? 🍎", textController, controller, scrollToBottom),
                  ],
                );
              }
              List<String> currentChips = [];
              if (step == 1) {
                currentChips = ["Combo 1 ngày", "Lịch nhỏ"];
              } else if (step == 2) {
                currentChips = ["Nhẹ nhàng", "Vừa sức", "Tập nặng"];
              } else if (step == 3) {
                currentChips = ["3 bài tập", "5 bài tập", "7 bài tập"];
              } else if (step == 4) {
                currentChips = ["Sáng", "Trưa", "Chiều"];
              }
              return ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      label: const Text(
                        "❌ Hủy",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      backgroundColor: Colors.red.withValues(alpha: 0.1),
                      side: const BorderSide(color: Colors.red, width: 0.8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onPressed: () {
                        controller.cancelWizard();
                      },
                    ),
                  ),
                  ...currentChips.map((chipText) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      label: Text(
                        chipText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onPressed: () {
                        controller.addWizardTag(chipText);
                        scrollToBottom();
                      },
                    ),
                  )),
                ],
              );
            }),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    if (controller.selectedImagePath.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8, left: 4),
                      height: 80,
                      width: 80,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(controller.selectedImagePath.value),
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => controller.clearSelectedImage(),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.image_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: () {
                                  controller.sendImage(ImageSource.gallery);
                                  scrollToBottom();
                                },
                              ),
                              Obx(() => PopupMenuButton<String>(
                                initialValue: controller.selectedModel.value,
                                icon: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: controller.selectedModel.value == "pro"
                                        ? Colors.orange.withValues(alpha: 0.15)
                                        : Colors.blue.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: controller.selectedModel.value == "pro"
                                          ? Colors.orange
                                          : Colors.blue,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        controller.selectedModel.value == "pro" ? "Pro" : "Flash",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: controller.selectedModel.value == "pro"
                                              ? Colors.orange
                                              : Colors.blue,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        size: 14,
                                        color: controller.selectedModel.value == "pro"
                                            ? Colors.orange
                                            : Colors.blue,
                                      ),
                                    ],
                                  ),
                                ),
                                onSelected: (String value) {
                                  controller.selectedModel.value = value;
                                },
                                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                    value: 'fast',
                                    child: Row(
                                      children: [
                                        Icon(Icons.bolt, color: Colors.blue, size: 18),
                                        SizedBox(width: 8),
                                        Text('Flash (Local)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'pro',
                                    child: Row(
                                      children: [
                                        Icon(Icons.star, color: Colors.orange, size: 18),
                                        SizedBox(width: 8),
                                        Text('Pro (Colab)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                              Expanded(
                                child: Obx(() {
                                  final active = controller.selectedWizardTags.isNotEmpty;
                                  if (active) {
                                    return SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: controller.selectedWizardTags.map((tag) => Container(
                                          margin: const EdgeInsets.only(right: 6, left: 4),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                tag,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              GestureDetector(
                                                onTap: () {
                                                  controller.removeWizardTag(tag);
                                                },
                                                child: Icon(
                                                  Icons.close,
                                                  size: 13,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )).toList(),
                                      ),
                                    );
                                  } else {
                                    return TextField(
                                      controller: textController,
                                      style: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Hỏi NutriTea gì đi nhen...',
                                        hintStyle: TextStyle(
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.grey.shade500
                                              : Colors.grey.shade400,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                      onSubmitted: (val) {
                                        if (val.trim().isNotEmpty || controller.selectedImageBase64.isNotEmpty) {
                                          controller.sendMessage(val);
                                          textController.clear();
                                          scrollToBottom();
                                        }
                                      },
                                    );
                                  }
                                }),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded, color: Colors.white),
                          onPressed: () {
                            final txt = textController.text;
                            if (txt.trim().isNotEmpty || controller.selectedImageBase64.isNotEmpty) {
                              controller.sendMessage(txt);
                              textController.clear();
                              scrollToBottom();
                            }
                          },
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
    );
  }

  void _showSwapDialog(BuildContext context, bool isExercise, int messageIndex, int dayIndex, int itemIndex, String currentName, String? mealType, AiAssistantController controller) {
    List<dynamic> items = [];
    try {
      if (isExercise) {
        if (Get.isRegistered<WorkoutController>()) {
          items = Get.find<WorkoutController>().allExercises;
        } else {
          items = Get.put(WorkoutController()).allExercises;
        }
      } else {
        if (Get.isRegistered<NutritionController>()) {
          items = Get.find<NutritionController>().allFoods;
        } else {
          items = Get.put(NutritionController()).allFoods;
        }
      }
    } catch (_) {}
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 400,
          child: Column(
            children: [
              Text(isExercise ? "Chọn bài tập thay thế" : "Chọn món ăn thay thế", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: items.isEmpty 
                  ? const Center(child: Text("Đang tải dữ liệu..."))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (ctx, i) {
                        var item = items[i];
                        String name = item.title;
                        int calo = item.calories;
                        return ListTile(
                          leading: Icon(isExercise ? Icons.fitness_center : Icons.restaurant, color: isExercise ? Colors.blue : Colors.green),
                          title: Text(name),
                          subtitle: Text("$calo kcal"),
                          onTap: () {
                            Get.back(); // close dialog
                            Get.back(); // close bottomsheet
                            if (isExercise) {
                              controller.swapExercise(messageIndex, dayIndex, itemIndex, name);
                            } else {
                              controller.swapMeal(messageIndex, dayIndex, itemIndex, name, mealType ?? 'Bữa chính');
                            }
                            Get.snackbar('Thành công', 'Đã đổi thành $name', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
                          },
                        );
                      }
                    ),
              ),
              TextButton(onPressed: () => Get.back(), child: const Text("Hủy")),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniPlanCard(BuildContext context, Map<String, dynamic> planData, AiAssistantController controller, int messageIndex) {
    var days = planData['days'] as List<dynamic>? ?? [];
    if (days.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                "Lộ trình 7 ngày đề xuất",
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (context, i) {
                var d = days[i];
                var w = d['workout']?['exercises'] as List<dynamic>? ?? [];
                var n = d['nutrition']?['meals'] as List<dynamic>? ?? [];
                return GestureDetector(
                  onTap: () {
                    Get.bottomSheet(
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            Text("Chi tiết ${d['dayName']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            const Text("Bài tập", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                            ...List.generate(w.length, (exIdx) {
                              var ex = w[exIdx];
                              return ListTile(
                                leading: const Icon(Icons.fitness_center, color: Colors.blue),
                                title: Text(ex['name'] ?? ''),
                                trailing: IconButton(
                                  icon: const Icon(Icons.swap_horiz), 
                                  onPressed: () {
                                    _showSwapDialog(context, true, messageIndex, i, exIdx, ex['name'] ?? '', null, controller);
                                  }
                                ),
                              );
                            }),
                            const Divider(),
                            const Text("Món ăn", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                            ...List.generate(n.length, (mealIdx) {
                              var meal = n[mealIdx];
                              return ListTile(
                                leading: const Icon(Icons.restaurant, color: Colors.green),
                                title: Text(meal['name'] ?? ''),
                                subtitle: Text(meal['type'] ?? ''),
                                trailing: IconButton(
                                  icon: const Icon(Icons.swap_horiz), 
                                  onPressed: () {
                                    _showSwapDialog(context, false, messageIndex, i, mealIdx, meal['name'] ?? '', meal['type'], controller);
                                  }
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      isScrollControlled: true,
                    );
                  },
                  child: Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d['dayName'] ?? 'Ngày', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text("🏋️ ${w.length} bài tập", style: const TextStyle(fontSize: 11, color: Colors.blue)),
                        Text("🥗 ${n.length} món ăn", style: const TextStyle(fontSize: 11, color: Colors.green)),
                        const Spacer(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.touch_app, size: 14, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.cancelPlan(messageIndex),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Hủy bỏ"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.confirmPlan(planData, messageIndex),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Xác nhận & Lưu", style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(
    BuildContext context,
    String text,
    TextEditingController textController,
    AiAssistantController controller,
    VoidCallback scrollToBottom,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade100,
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300,
          width: 0.8,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {
          controller.sendMessage(text);
          scrollToBottom();
        },
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, String content, bool isUser) {
    if (isUser) {
      return Text(
        content,
        style: const TextStyle(color: Colors.white, fontSize: 14.5, height: 1.4),
      );
    }

    String displayContent = content;
    final planStartIdx = content.indexOf('<PLAN>');
    if (planStartIdx != -1) {
      final planEndIdx = content.indexOf('</PLAN>');
      if (planEndIdx != -1) {
        displayContent = content.substring(0, planStartIdx) + content.substring(planEndIdx + 7);
      } else {
        displayContent = content.substring(0, planStartIdx);
      }
    }
    
    displayContent = displayContent.replaceAll(RegExp(r'\[STICKER:\s*[^\]]+\]'), '').trim();

    final regExp = RegExp(r'\[CARD_EXERCISE:\s*([^\]]+)\]');
    final match = regExp.firstMatch(displayContent);
    
    if (match != null) {
      final exerciseName = match.group(1)!.trim();
      final cleanContent = displayContent
          .replaceAll(RegExp(r'\[CARD_EXERCISE:\s*[^\]]+\]'), '')
          .replaceAll(RegExp(r'\[CARD_MEAL:\s*[^\]]+\]'), '')
          .trim();
      
      Map<String, dynamic>? exerciseData;
      try {
        if (Get.isRegistered<WorkoutController>()) {
          final wController = Get.find<WorkoutController>();
          final e = wController.allExercises.firstWhereOrNull(
            (ex) => ex.title.toLowerCase() == exerciseName.toLowerCase()
          );
          if (e != null) {
            exerciseData = {'title': e.title, 'gifUrl': e.image, 'calories': e.calories};
          }
        } else {
          final wController = Get.put(WorkoutController());
          final e = wController.allExercises.firstWhereOrNull(
            (ex) => ex.title.toLowerCase() == exerciseName.toLowerCase()
          );
          if (e != null) {
            exerciseData = {'title': e.title, 'gifUrl': e.image, 'calories': e.calories};
          }
        }
      } catch (_) {}

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cleanContent.isNotEmpty)
            Text(
              cleanContent,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade100 : Colors.black87,
                fontSize: 14.5,
                height: 1.4,
              ),
            ),
          if (cleanContent.isNotEmpty) const SizedBox(height: 12),
          if (exerciseData != null && exerciseData['gifUrl'] != null)
            Container(
              width: 250,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: Image.network(
                      exerciseData['gifUrl'],
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, _) => const SizedBox(
                        height: 150,
                        child: Center(child: Icon(Icons.fitness_center, color: Colors.grey, size: 40)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exerciseData['title'] ?? exerciseName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department, color: Colors.orange, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              "\${exerciseData['calories'] ?? 0} kcal",
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.fitness_center, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Bài tập: $exerciseName (Không tìm thấy hình ảnh)",
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }
    
    return Text(
      displayContent,
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade100 : Colors.black87,
        fontSize: 14.5,
        height: 1.4,
      ),
    );
  }
}

class AnimatedSticker extends StatefulWidget {
  final String stickerPath;
  const AnimatedSticker({super.key, required this.stickerPath});

  @override
  State<AnimatedSticker> createState() => _AnimatedStickerState();
}

class _AnimatedStickerState extends State<AnimatedSticker> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.elasticOut,
      ),
    );

    _slideAnimation = Tween<double>(begin: -35.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 4, bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: widget.stickerPath.startsWith('http')
              ? Image.network(
                  widget.stickerPath,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                )
              : Image.asset(
                  widget.stickerPath,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}
