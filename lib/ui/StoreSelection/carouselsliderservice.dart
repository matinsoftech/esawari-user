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
      decoration: BoxDecoration(color: Colors.white),
      child: CarouselSlider(
        options: CarouselOptions(
          aspectRatio: 1.9,
          enlargeCenterPage: true,
          enableInfiniteScroll: true,
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // Same border radius for all corners
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10), // Apply circular border uniformly
        child: Stack(
          children: <Widget>[
            // Using Image.asset to load images from local assets
            Image.asset(
              category.imagePath,
              fit: BoxFit.cover, // Ensure the image fits the container properly
              width: double.infinity, // Ensure full width coverage
              height: double.infinity, // Ensure full height coverage
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
