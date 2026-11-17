import 'package:flutter/material.dart';
import 'post.dart';

// A card showing one post: author, caption, image, like button, comments,
// and a field to add a new comment. Like and comment state is mirrored in the
// parent feed (keyed by the post instance) so it survives when posts are
// reordered; ObjectKey(post) keeps this card attached to the correct post.
class PostCard extends StatefulWidget {
  final Post post;
  final bool isLiked;
  final List<String> comments;
  final VoidCallback onLikeToggle;
  final ValueChanged<String> onAddComment;

  const PostCard({
    super.key,
    required this.post,
    required this.isLiked,
    required this.comments,
    required this.onLikeToggle,
    required this.onAddComment,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final TextEditingController commentController = TextEditingController();
  late bool isLiked;
  late List<String> comments;

  @override
  void initState() {
    super.initState();
    isLiked = widget.isLiked;
    comments = List<String>.from(widget.comments);
  }

  // Toggles the heart between liked and not liked, locally and in the parent.
  void likePost() {
    setState(() {
      isLiked = !isLiked;
    });
    widget.onLikeToggle();
  }

  // Adds a non-empty comment to this card and the parent, clears the field.
  void addComment() {
    final String comment = commentController.text.trim();

    if (comment.isEmpty) {
      return;
    }

    setState(() {
      comments.add(comment);
    });

    widget.onAddComment(comment);

    commentController.clear();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.post.username.trim();

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text(
                username.isEmpty ? '?' : username[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Student Feed'),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              widget.post.caption,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Image.network(
            widget.post.imageUrl,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                height: 220,
                child: Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 70,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed: likePost,
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : null,
                ),
                label: Text(isLiked ? 'Liked' : 'Like'),
              ),
              Text('${comments.length} Comments'),
            ],
          ),
          for (final String comment in comments)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(comment),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: addComment,
                  icon: const Icon(Icons.send),
                  color: Colors.green,
                  tooltip: 'Send comment',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
