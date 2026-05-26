import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/core/widgets/molecules/vesto_app_bar.dart';
import 'package:mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/features/profile/presentation/providers/profile_providers.dart';
import 'package:mobile/features/profile/data/repositories/user_repository.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _usernameController;
  File? _newAvatar;
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final user = ref.read(currentUserProvider).value;
      _nameController = TextEditingController(text: user?.displayName ?? '');
      _bioController = TextEditingController(text: user?.bio ?? '');
      _usernameController = TextEditingController(text: user?.username ?? '');
      _initialized = true;
    }
  }

  @override
  void dispose() {
    if (_initialized) {
      _nameController.dispose();
      _bioController.dispose();
      _usernameController.dispose();
    }
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() {
        _newAvatar = File(image.path);
      });
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim().toLowerCase();
    final bio = _bioController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İsim boş olamaz')),
      );
      return;
    }

    // Username format check
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_.]+$');
    if (username.isNotEmpty && !usernameRegex.hasMatch(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcı adı sadece harf, rakam, alt çizgi ve nokta içerebilir')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? photoUrl;
      final uid = ref.read(currentUserProvider).value!.uid;

      if (_newAvatar != null) {
        final storageRef = FirebaseStorage.instance.ref().child('users/$uid/avatar.jpg');
        await storageRef.putFile(
          _newAvatar!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        photoUrl = await storageRef.getDownloadURL();
      }

      await ref.read(userRepositoryProvider).updateProfile(
        uid: uid,
        displayName: name,
        bio: bio,
        username: username.isNotEmpty ? username : null,
        photoUrl: photoUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil başarıyla güncellendi')),
        );
        context.pop();
      }
    } on UsernameAlreadyTakenException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu kullanıcı adı alınmış')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: AppColors.pearl,
      appBar: VestoAppBar(
        title: 'Profili Düzenle',
        actions: [
          _isSaving
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onyx),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _save,
                  child: const Text(
                    'Kaydet',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppColors.onyx,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar picker
            GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.mist,
                    backgroundImage: _newAvatar != null
                        ? FileImage(_newAvatar!)
                        : (user?.photoURL != null ? CachedNetworkImageProvider(user!.photoURL!) as ImageProvider : null),
                    child: _newAvatar == null && user?.photoURL == null
                        ? Text(
                            user?.displayName.isNotEmpty == true
                                ? user!.displayName.substring(0, 1).toUpperCase()
                                : 'V',
                            style: AppTypography.headlineMedium.copyWith(color: AppColors.onyx),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.onyx,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: AppColors.pearl,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Display Name
            _ProfileField(
              label: 'İsim',
              controller: _nameController,
              maxLength: 50,
            ),
            const SizedBox(height: 16),

            // Username
            _ProfileField(
              label: 'Kullanıcı adı',
              controller: _usernameController,
              prefix: '@',
              hint: 'vestokullanicisi',
              maxLength: 30,
            ),
            const SizedBox(height: 16),

            // Bio
            _ProfileField(
              label: 'Bio',
              controller: _bioController,
              maxLength: 150,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? prefix;
  final String? hint;
  final int maxLength;
  final int maxLines;

  const _ProfileField({
    required this.label,
    required this.controller,
    this.prefix,
    this.hint,
    required this.maxLength,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.labelSmall.copyWith(color: AppColors.stone),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.mist),
          ),
          child: Row(
            children: [
              if (prefix != null) ...[
                Text(
                  prefix!,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.stone),
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLength: maxLength,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.onyx),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
