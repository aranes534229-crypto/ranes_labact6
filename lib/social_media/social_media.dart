import 'package:flutter/material.dart';
import 'create_post_sheet.dart';
import 'post.dart';
import 'post_card.dart';

// The social media feed page showing a list of posts with a FAB to create new ones.
class SocialMediaPage extends StatefulWidget {
  final String username;

  const SocialMediaPage({
    super.key,
    required this.username,
  });

  @override
  State<SocialMediaPage> createState() => _SocialMediaPageState();
}

class _SocialMediaPageState extends State<SocialMediaPage> {
  final List<Post> posts = [
    const Post(
      username: 'JohnDoe',
      caption: 'Enjoying the sunny weather!',
      imageUrl: 'https://picsum.photos/id/20/600/400',
    ),
    const Post(
      username: 'JaneSmith',
      caption: 'Just finished a great book!',
      imageUrl: 'https://picsum.photos/id/24/600/400',
    ),
  ];

  // Like and comment state is kept here (keyed by the post instance, which is
  // identity-stable because Post is const) so it survives when posts are
  // reordered by insertions at the top of the feed.
  final Map<Post, bool> postLikes = {};
  final Map<Post, List<String>> postComments = {};

  // Toggles the like state of a post in the parent feed.
  void toggleLike(Post post) {
    setState(() {
      postLikes[post] = !(postLikes[post] ?? false);
    });
  }

  // Adds a comment to a post in the parent feed.
  void addComment(Post post, String comment) {
    setState(() {
      postComments.putIfAbsent(post, () => []).add(comment);
    });
  }

  // Opens the create post bottom sheet; awaits the result, then inserts the
  // new post at the top of the feed if one was submitted.
  Future<void> openCreatePostSheet() async {
    final Post? newPost = await showModalBottomSheet<Post>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return CreatePostSheet(username: widget.username);
      },
    );

    if (!mounted || newPost == null) {
      return;
    }

    setState(() {
      posts.insert(0, newPost);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Social Media')),
      body: posts.isEmpty
          ? const Center(child: Text('No posts yet. Create one!'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return PostCard(
                  key: ObjectKey(post),
                  post: post,
                  isLiked: postLikes[post] ?? false,
                  comments: List<String>.from(postComments[post] ?? const []),
                  onLikeToggle: () => toggleLike(post),
                  onAddComment: (comment) => addComment(post, comment),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: openCreatePostSheet,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        tooltip: 'Create Post',
        child: const Icon(Icons.add),
      ),
    );
  }
}
