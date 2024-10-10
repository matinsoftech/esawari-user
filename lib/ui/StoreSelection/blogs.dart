import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BlogsProvider extends StatelessWidget {
  const BlogsProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('blogs')
              .doc('JGc8Y60e9bK0TP6zeujM')
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('No data found'));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            var blogData = snapshot.data!.data() as Map<String, dynamic>;

            // Extracting fields
            String title = blogData['title'] ?? 'No title';
            String description = blogData['description'] ?? 'No description';
            String imageUrl = blogData['image'] ?? '';

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Enable horizontal scrolling
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width, // Restrict the width
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8.0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Image at the bottom layer of the Stack
                    if (imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          imageUrl,
                          height: 300,
                          width: MediaQuery.of(context).size.width, // Constrain width to the screen size
                          fit: BoxFit.cover,
                        ),
                      ),

                    // Positioned widget for Title and Description
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // White text over red background
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black, // White text over red background
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
