import 'package:flutter/material.dart';
import 'package:mobile/app/theme/app_colors.dart';

class ForumCommentInput extends StatefulWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;
  final String? replyingToDisplayName;
  final VoidCallback? onCancelReply;

  const ForumCommentInput({
    required this.controller,
    required this.isSending,
    required this.onSend,
    this.replyingToDisplayName,
    this.onCancelReply,
    super.key,
  });

  @override
  State<ForumCommentInput> createState() => _ForumCommentInputState();
}

class _ForumCommentInputState extends State<ForumCommentInput> {
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_textListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_textListener);
    super.dispose();
  }

  void _textListener() {
    final text = widget.controller.text.trim();
    final canSend = text.isNotEmpty && text.length <= 280;
    if (canSend != _canSend) {
      setState(() => _canSend = canSend);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.mist.withValues(alpha: 0.5), width: 1),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.replyingToDisplayName != null) ...[
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '@${widget.replyingToDisplayName} kullanıcısına yanıt veriliyor',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onyx,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onCancelReply,
                      behavior: HitTestBehavior.opaque,
                      child: const Text(
                        'Vazgeç',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.stone,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.mist),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.pearl,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: widget.controller,
                      maxLines: null,
                      maxLength: 280,
                      decoration: InputDecoration(
                        hintText: widget.replyingToDisplayName != null
                            ? 'Yanıtınızı yazın...'
                            : 'Yorum yaz...',
                        hintStyle: const TextStyle(color: AppColors.stone),
                        border: InputBorder.none,
                        counterText: '', // Hide default counter inside small input
                      ),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.onyx,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                widget.isSending
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onyx),
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.send,
                          color: _canSend ? AppColors.onyx : AppColors.stone.withValues(alpha: 0.5),
                        ),
                        onPressed: _canSend ? widget.onSend : null,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
