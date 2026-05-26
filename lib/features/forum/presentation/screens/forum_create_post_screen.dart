import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/core/widgets/molecules/vesto_app_bar.dart';
import 'package:mobile/features/forum/presentation/providers/forum_providers.dart';

class ForumCreatePostScreen extends ConsumerStatefulWidget {
  const ForumCreatePostScreen({super.key});

  @override
  ConsumerState<ForumCreatePostScreen> createState() => _ForumCreatePostScreenState();
}

class _ForumCreatePostScreenState extends ConsumerState<ForumCreatePostScreen> {
  final _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    final caption = _captionController.text.trim();
    if (caption.isEmpty) return;

    if (caption.length > 280) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gönderi 280 karakterden uzun olamaz.')),
      );
      return;
    }

    await ref.read(forumShareProvider.notifier).shareOutfit(
          caption: caption,
        );

    if (mounted && !ref.read(forumShareProvider).hasError) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paylaşıldı!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shareState = ref.watch(forumShareProvider);
    final captionEmpty = _captionController.text.trim().isEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: VestoAppBar(
        title: 'Yeni Gönderi',
        actions: [
          shareState.isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onyx),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: captionEmpty ? null : _share,
                  child: Text(
                    'PAYLAŞ',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      color: captionEmpty
                          ? AppColors.stone.withValues(alpha: 0.5)
                          : AppColors.onyx,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _captionController,
              onChanged: (text) => setState(() {}),
              maxLength: 280,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Topluluğa sormak istediğiniz soruyu veya düşüncelerinizi yazın...',
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.stone,
                ),
                border: InputBorder.none,
                counterText: '',
              ),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.onyx,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_captionController.text.length} / 280',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.stone,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
