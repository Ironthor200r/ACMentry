import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'login.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late List<Product> products = [];

  @override
  void initState() {
    super.initState();
    // Fetch product data from dummy API
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('http://dummyjson.com/products'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData.containsKey('products')) {
        final List<dynamic> productList = responseData['products'];
        setState(() {
          products = productList.map((item) => Product.fromJson(item)).toList();
        });
      } else {
        throw Exception('Products data not found in response');
      }
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(233, 137, 166, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(233, 137, 166, 1),
        title: Text('E-Commerce App'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Navigate to the login page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
            childAspectRatio: 0.75,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(product: product);
          },
        ),
      ),
    );
  }
}

class Product {
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  Product({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['title'] ?? 'Unknown',
      description: json['description'] ?? '',
      price: json['price'] != null ? json['price'].toDouble() : 0.0,
      imageUrl: json['thumbnail'] ?? '',
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  ProductCard({Key? key, required this.product}) : super(key: key);

  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 40,
            width: 150,
            child: Expanded(
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                    )
                  : Placeholder(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.0),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.green),
                ),
                TextField(
                  controller: _reviewController,
                  decoration: InputDecoration(
                    labelText: 'Write a Review',
                  ),
                ),
                SizedBox(height: 8.0),
                Row(
                  // Wrap buttons in a Row
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        final String review = _reviewController.text.trim();
                        if (review.isNotEmpty) {
                          _writeReview(product.name, review);
                          _reviewController.clear();

                          // Log event for "give" button click
                          analytics.logEvent(name: 'give_review', parameters: {
                            'product_name': product.name,
                          });
                        }
                      },
                      child: Text('give'),
                    ),
                    SizedBox(width: 8.0), // Add spacing between buttons
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ReadReviewsPage(productName: product.name),
                          ),
                        );

                        // Log event for "read" button click
                        analytics.logEvent(name: 'read_reviews', parameters: {
                          'product_name': product.name,
                        });
                      },
                      child: Text('read'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _writeReview(String productName, String review) {
    FirebaseFirestore.instance.collection('reviews').add({
      'product_name': productName,
      'review': review,
      'timestamp': Timestamp.now(),
    });
  }
}

class ReadReviewsPage extends StatelessWidget {
  final String productName;

  const ReadReviewsPage({Key? key, required this.productName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews for $productName'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('reviews')
            .where('product_name', isEqualTo: productName)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No reviews available for $productName'),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['review']),
                subtitle: Text('Reviewed on: ${data['timestamp'].toDate()}'),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
