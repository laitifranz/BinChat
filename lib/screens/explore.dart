import 'package:flutter/material.dart';

class FeedPage extends StatelessWidget {
  final List<Post> posts = [
    Post(
      userName: 'john_doe',
      userImage: 'https://via.placeholder.com/150',
      country: 'Italy',
      timestamp: '2 hours ago',
      content:
          'Did you know recycling one ton of paper can save 17 trees? 🌳 #RecyclingTips',
    ),
    Post(
        userName: 'jane_smith12',
        userImage: 'https://via.placeholder.com/150',
        country: 'USA',
        timestamp: '1 day ago',
        content:
            'Turning old t-shirts into tote bags is a fun way to recycle and reduce waste! ♻️ #DIY #EcoFriendly',
        image: 'https://i.ytimg.com/vi/rDIea-ldrJU/maxresdefault.jpg'),
    Post(
      userName: 'alex_897',
      userImage: 'https://via.placeholder.com/150',
      country: 'Japan',
      timestamp: '3 days ago',
      content:
          'Plastic waste is a huge problem. Let\'s commit to using reusable bags and bottles! #NoPlastic',
    ),
    Post(
      userName: 'eco_enthusiast',
      userImage: 'https://via.placeholder.com/150',
      country: 'Germany',
      timestamp: '5 hours ago',
      content:
          'Ever tried composting at home? It\'s easier than you think and great for your garden! 🌿 #Composting',
    ),
    Post(
        userName: 'nature_lovers_42',
        userImage: 'https://via.placeholder.com/150',
        country: 'Brazil',
        timestamp: '1 day ago',
        content:
            'A small change can make a big difference! Swap single-use plastics for sustainable alternatives. 🌎 #SustainableLiving',
        image:
            'https://www.t-texshop.com/img/p/4/1/6/9/4169-large_default.jpg'),
    Post(
      userName: 'green_ideas',
      userImage: 'https://via.placeholder.com/150',
      country: 'Canada',
      timestamp: '2 days ago',
      content:
          'DIY tip: Use old jars as plant pots to give them a second life! 🌱 #Upcycling',
    ),
    Post(
      userName: 'earth_lover89',
      userImage: 'https://via.placeholder.com/150',
      country: 'Australia',
      timestamp: '3 days ago',
      content:
          'Did you know that recycling aluminum cans saves 95% of the energy required to make the same amount from raw materials? 💡 #RecyclingFacts',
    ),
    Post(
      userName: 'planet_saver',
      userImage: 'https://via.placeholder.com/150',
      country: 'India',
      timestamp: '4 days ago',
      content:
          'Support local businesses that use eco-friendly packaging. Every choice counts! 🌍 #EcoShopping',
    ),
    Post(
      userName: 'sustainable_soul',
      userImage: 'https://via.placeholder.com/150',
      country: 'South Africa',
      timestamp: '6 days ago',
      content:
          'Celebrate zero waste month by tracking your waste and aiming for less each week! 🌟 #ZeroWasteChallenge',
    ),
    Post(
      userName: 'recycle_hero',
      userImage: 'https://via.placeholder.com/150',
      country: 'France',
      timestamp: '7 days ago',
      content:
          'Join a local clean-up event to help keep our beaches and parks beautiful. Let\'s make a difference together! 🏖️ #CommunityCleanup',
    ),
    Post(
      userName: 'green_minds',
      userImage: 'https://via.placeholder.com/150',
      country: 'UK',
      timestamp: '8 days ago',
      content:
          'Did you know that buying second-hand items helps reduce waste and supports sustainable fashion? 👗 #SustainableFashion',
    ),
  ];

  FeedPage({super.key});

  void _showAddPostPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: const AddPostWidget(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Handle search action
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostWidget(post: post);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPostPopup(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Post {
  final String userName;
  final String userImage;
  final String timestamp;
  final String content;
  final String country;
  final String? image;

  Post(
      {required this.userName,
      required this.userImage,
      required this.country,
      required this.timestamp,
      required this.content,
      this.image});
}

class PostWidget extends StatelessWidget {
  final Post post;

  const PostWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(post.userImage),
                  radius: 25.0,
                ),
                const SizedBox(width: 12.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${post.userName} from ${post.country}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    Text(
                      post.timestamp,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Text(
              post.content,
              style: const TextStyle(fontSize: 14.0),
            ),
            const SizedBox(height: 10.0),
            if (post.image != null) ...[
              Image.network(post.image!),
              const SizedBox(height: 10.0),
            ],
            Row(
              children: [
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.thumb_up_alt_outlined)),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.thumb_down_alt_outlined)),
                IconButton(
                    onPressed: () {}, icon: const Icon(Icons.report_outlined)),
                const Spacer(),
                IconButton(
                    onPressed: () {}, icon: const Icon(Icons.comment_outlined)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class AddPostWidget extends StatefulWidget {
  const AddPostWidget({super.key});

  @override
  _AddPostWidgetState createState() => _AddPostWidgetState();
}

class _AddPostWidgetState extends State<AddPostWidget> {
  final TextEditingController _contentController = TextEditingController();

  void _submitPost() {
    final content = _contentController.text;
    if (content.isNotEmpty) {
      // TODO: Handle post submission
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Create New Post',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _submitPost,
                  icon: const Icon(Icons.send,
                      size: 18), // Icon for visual interest
                  label: const Text(
                    'Share',
                    style: TextStyle(
                      fontSize: 16, // Slightly larger text
                      fontWeight: FontWeight.bold, // Bold text for emphasis
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context)
                        .primaryColor
                        .withOpacity(0.7), // Background color
                    foregroundColor: Colors.white, // Text color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12), // Padding for a better touch target
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Rounded corners
                    ),
                    elevation: 5, // Shadow for a 3D effect
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Share your ideas or suggestions...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Handle add image action
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Add Image'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Handle add video action
                  },
                  icon: const Icon(Icons.videocam),
                  label: const Text('Add Video'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Warning: The post will be public.',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
