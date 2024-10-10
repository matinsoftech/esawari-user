import 'package:carousel_slider/carousel_slider.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Category extends Equatable {
  
  final String imagePath;

  const Category({
    required this.imagePath,
   
  });

  @override
  List<Object?> get props => [imagePath];

  // List of categories with image paths from local assets
  static List<Category> Categories = [
    const Category(
      imagePath: 'assets/images/e-sawari_banner.jpg',
      
    ),
    const Category(
      imagePath: 'assets/images/e-sawari_Banne.jpg',
      
    ),
  ];
}

class MainSliders extends StatelessWidget {
  MainSliders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CarouselSlider(
        options: CarouselOptions(
          aspectRatio: 2.0,
          enlargeCenterPage: true,
          enableInfiniteScroll: false,
          initialPage: 2,
          autoPlay: true,
        ),
        items: Category.Categories.map(
          (category) => HeroCarousel(category: category),
        ).toList(),
      ),
    );
  }
}

class HeroCarousel extends StatelessWidget {
  final Category category;

  const HeroCarousel({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        child: Stack(
          children: <Widget>[
            // Using Image.asset to load images from local assets
            Image.asset(
              category.imagePath,
              fit: BoxFit.cover,
              width: 1000.0,
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(200, 0, 0, 0),
                      const Color.fromARGB(0, 0, 0, 0),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
               
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // For Firebase Firestore
// import 'package:flutter/material.dart';

// class Category {
//   final String imagePath;

//   Category({required this.imagePath});

//   // Factory constructor to create Category from Firestore document
//   factory Category.fromFirestore(DocumentSnapshot doc) {
//     return Category(
//       imagePath: doc['photo'] ?? '', // Fetch the 'photo' field from Firestore
//     );
//   }
// }

// class MainSliders extends StatefulWidget {
//   @override
//   _MainSlidersState createState() => _MainSlidersState();
// }

// class _MainSlidersState extends State<MainSliders> {
//   List<Category> _categories = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchBannerItems(); // Fetch the banner items from Firebase
//   }

//   Future<void> _fetchBannerItems() async {
//     try {
//       // Fetch data from Firestore 'banner_items' collection
//       QuerySnapshot snapshot = await FirebaseFirestore.instance
//           .collection('banner_items')
//           .where('is_publish', isEqualTo: true) // Only get published banners
//           .orderBy('set_order', descending: false) // Order by 'set_order'
//           .get();

//       // Map Firestore documents to Category objects
//       List<Category> categories = snapshot.docs
//           .map((doc) => Category.fromFirestore(doc))
//           .toList();

//       setState(() {
//         _categories = categories;
//         _isLoading = false; // Loading complete
//       });
//     } catch (e) {
//       print('Error fetching banner items: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _isLoading
//         ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching data
//         : CarouselSlider(
//             options: CarouselOptions(
//               aspectRatio: 2.0,
//               enlargeCenterPage: true,
//               enableInfiniteScroll: false,
//               initialPage: 0,
//               autoPlay: true,
//             ),
//             items: _categories.map((category) => HeroCarousel(category: category)).toList(),
//           );
//   }
// }

// class HeroCarousel extends StatelessWidget {
//   final Category category;

//   const HeroCarousel({Key? key, required this.category}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(5.0),
//       child: ClipRRect(
//         borderRadius: const BorderRadius.all(Radius.circular(5.0)),
//         child: Stack(
//           children: <Widget>[
//             Image.network(
//               category.imagePath,
//               fit: BoxFit.cover,
//               width: 1000.0,
//               loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
//                 if (loadingProgress == null) {
//                   return child;
//                 } else {
//                   return Center(
//                     child: CircularProgressIndicator(
//                       value: loadingProgress.expectedTotalBytes != null
//                           ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
//                           : null,
//                     ),
//                   );
//                 }
//               },
//               errorBuilder: (context, error, stackTrace) {
//                 return Center(child: Text('Failed to load image'));
//               },
//             ),
//             Positioned(
//               bottom: 0.0,
//               left: 0.0,
//               right: 0.0,
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       const Color.fromARGB(200, 0, 0, 0),
//                       const Color.fromARGB(0, 0, 0, 0),
//                     ],
//                     begin: Alignment.bottomCenter,
//                     end: Alignment.topCenter,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
