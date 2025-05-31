import 'package:facebook_clone/widgets/custom_icon_button.dart';
import 'package:facebook_clone/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:facebook_clone/models/post_data_model.dart';
import 'package:facebook_clone/services/post_services/create_post_service.dart';
import 'package:facebook_clone/services/auth_services/auth_service.dart';
import 'package:facebook_clone/widgets/custom_text.dart';
import 'package:facebook_clone/utils/image_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class UpdatePostScreen extends StatefulWidget {
  final PostDataModel post;

  const UpdatePostScreen({super.key, required this.post});

  @override
  State<UpdatePostScreen> createState() => _UpdatePostScreenState();
}

class _UpdatePostScreenState extends State<UpdatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  final PostService _postService = PostService();
  String? _imageUrl;
  File? _newImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _textController.text = widget.post.postText;
    _imageUrl = widget.post.postImageUrl;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _newImage = File(image.path);
      });
    }
  }

  String _getBase64Image(File imageFile) {
    final bytes = imageFile.readAsBytesSync();
    return base64Encode(bytes);
  }

  Future<void> _updatePost() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post text cannot be empty')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = AuthService().currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Handle the image URL based on whether there's a new image or not
      String finalImageUrl;
      if (_newImage != null) {
        // Convert the new image to base64
        finalImageUrl = _getBase64Image(_newImage!);
      } else {
        finalImageUrl = _imageUrl ?? '';
      }

      await _postService.updatePost(
        documentId: widget.post.documentId,
        postText: _textController.text.trim(),
        postImageUrl: finalImageUrl,
        userId: user.uid,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update post: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  CustomIconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      iconData: Icons.arrow_back_ios),
                  CustomText('Update Post'),
                  Spacer(),
                  ElevatedButton(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 12, vertical: 5)),
                    ),
                    onPressed: _updatePost,
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Text('Update'),
                  ),
                ],
              ),
              Divider(),
              SizedBox(
                height: 5,
              ),
              _buildPostInput(),
              const SizedBox(height: 16),
              if (_imageUrl != null || _newImage != null)
                if (_imageUrl != '') _buildPostImage(),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Add Photo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostImage() {
    final screenWidth = MediaQuery.of(context).size.width;
    final estimatedImageHeight = screenWidth * 1.1;
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image(
            image: _newImage != null
                ? FileImage(_newImage!)
                : ImageUtils.getImageProvider(_imageUrl!),
            width: double.infinity,
            fit: BoxFit.cover,
            height: estimatedImageHeight,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: estimatedImageHeight,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.error_outline,
                  size: 50,
                  color: Theme.of(context).colorScheme.error,
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              setState(() {
                _imageUrl = null;
                _newImage = null;
              });
            },
          ),
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
      controller: _textController,
      hintText: "What's on your mind?",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }

        return null;
      },
    );
  }
}
