import 'dart:convert';
import 'dart:io';

import 'package:facebook_clone/services/auth_services/auth_service.dart';
import 'package:facebook_clone/services/post_services/create_post_service.dart';
import 'package:facebook_clone/widgets/custom_icon_button.dart';
import 'package:facebook_clone/widgets/custom_text.dart';
import 'package:facebook_clone/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../consts/theme.dart';

/// A screen that allows users to create a new post with text and optional image.
class CreatePostScreen extends StatefulWidget {
  final User user;
  final PostService postService;

  const CreatePostScreen({
    super.key,
    required this.user,
    required this.postService,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _postController = TextEditingController();
  String? _postImageBase64;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  /// Picks an image from the gallery and converts it to base64
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        final bytes = await imageFile.readAsBytes();
        final base64Image = base64Encode(bytes);

        setState(() {
          _postImageBase64 = base64Image;
          _errorMessage = null;
        });
      }
    } catch (e) {
      _setError('Failed to pick image: $e');
    }
  }

  /// Creates a new post with the provided text and image
  Future<void> _createPost() async {
    if (_postController.text.trim().isEmpty && _postImageBase64 == null) {
      _setError('Please add some text or an image to your post');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.postService.createPost(
        postText: _postController.text.trim(),
        postImageUrl: _postImageBase64,
        user: widget.user,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _setError('Failed to create post: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _setError(String message) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CustomIconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        iconData: Icons.arrow_back_ios),
                    CustomText(
                      'Create Post',
                    ),
                    Spacer(),
                    _isLoading
                        ? Center(child: const CircularProgressIndicator())
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppTheme.lightTheme.colorScheme.primary,
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20)),
                            onPressed: _createPost,
                            child: Text(
                              'POST',
                              style: TextStyle(color: Colors.white),
                            ))
                  ],
                ),
                Divider(),
                _buildUserInfo(),
                const SizedBox(height: 5),
                _buildPostInput(),
                const SizedBox(height: 20),
                if (_postImageBase64 != null) _buildImagePreview(),
                const SizedBox(height: 20),
                _buildActionButtons(),
                if (_errorMessage != null) _buildErrorMessage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(
            widget.user.photoURL ?? 'https://picsum.photos/seed/user/50/50',
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              widget.user.displayName ?? 'Anonymous',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPostInput() {
    return CustomTextField(
      decoration: InputDecoration(
        fillColor: Colors.transparent,
        enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
        border: OutlineInputBorder(borderSide: BorderSide.none),
        disabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
      ),
      controller: _postController,
      hintText: "What's on your mind?",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }

        return null;
      },
    );
  }

  Widget _buildImagePreview() {
    final screenWidth = MediaQuery.of(context).size.width;
    final estimatedImageHeight = screenWidth * 1.1;
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            base64Decode(_postImageBase64!),
            height: estimatedImageHeight,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              setState(() {
                _postImageBase64 = null;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.photo_library),
          label: const CustomText('Add Photo'),
        ),
        // const SizedBox(height: 12),
        // ElevatedButton.icon(
        //   onPressed: _isLoading ? null : _createPost,
        //   icon: const Icon(Icons.post_add),
        //   label: const CustomText('Create Post'),
        //   style: ElevatedButton.styleFrom(
        //     padding: const EdgeInsets.symmetric(vertical: 12),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        _errorMessage!,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
