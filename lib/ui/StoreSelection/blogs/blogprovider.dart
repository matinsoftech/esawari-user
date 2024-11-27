import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emartconsumer/ui/StoreSelection/blogs/blogdetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Add this package for carousel

class BlogsProvider extends StatelessWidget {
  const BlogsProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No blogs found'));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Fetch blog data from multiple documents
          var blogs = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

          return CarouselSlider.builder(
            itemCount: blogs.length,
            options: CarouselOptions(
              height: 300,
              autoPlay: true,
              enlargeCenterPage: true,
            ),
            itemBuilder: (context, index, realIndex) {
              var blogData = blogs[index];

              // Extract fields from the blog data
              String title = blogData['title'] ?? 'No title';
              String description = blogData['description'] ?? 'No description';
              String imageUrl = blogData['image'] ?? '';
              String blogId = snapshot.data!.docs[index].id; // Fetch document ID

              return GestureDetector(
                onTap: () {
                  // Navigate to the detailed screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlogDetailsScreen(
                        blogId: blogId,
                        title: title,
                        description: description,
                        imageUrl: imageUrl,
                      ),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    // Image for the carousel item
                    if (imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          imageUrl,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        ),
                      ),

                    // Title overlay
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 247, 77, 77),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
