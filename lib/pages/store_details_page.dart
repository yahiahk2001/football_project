import 'package:flutter/material.dart';

class StoreDetailsPage extends StatelessWidget {
  final Map<String, dynamic> store;

  StoreDetailsPage({super.key, required this.store});

  final List<Map<String, dynamic>> products = [
    {
      'product_id': 1,
      'store_id': 1,
      'product_name': 'Nike Running Shoes',
      'product_image':
          'https://i.ebayimg.com/images/g/Qp0AAOSwz91m2boH/s-l1600.webp',
      'price': 120.0,
      'description': 'High-quality running shoes from Nike.',
      'rating': 4.5,
    },
    {
      'product_id': 2,
      'store_id': 1,
      'product_name': 'Nike Sports Bag',
      'product_image':
          'https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco/53e530c8-c5d4-4d68-85f8-6cf4e8628496/NK+GYM+CLUB+BAG+-+SP23.png',
      'price': 60.0,
      'description': 'Durable and stylish sports bag.',
      'rating': 4.0,
    },
    {
      'product_id': 3,
      'store_id': 1,
      'product_name': 'Nike Football',
      'product_image':
          'https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco/10b32c47-fde8-465d-8ccc-e9bc4755b969/PL+NK+FLIGHT+-+FA24.png',
      'price': 30.0,
      'description': 'Official Nike football for professionals.',
      'rating': 4.7,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final storeProducts =
        products.where((p) => p['store_id'] == store['store_id']).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(store['store_name']),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Image.network(
                  store['store_cover'],
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(store['store_logo']),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        store['store_name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store['store_description'],
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InfoCard(
                        icon: Icons.location_on,
                        title: 'Location',
                        value: 'Downtown, NY',
                      ),
                      InfoCard(
                        icon: Icons.phone,
                        title: 'Contact',
                        value: '+1 234 567 890',
                      ),
                      InfoCard(
                        icon: Icons.star,
                        title: 'Rating',
                        value: '4.5/5',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Products',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: storeProducts.length,
                    itemBuilder: (context, index) {
                      final product = storeProducts[index];
                      return ProductCard(product: product);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.deepPurple),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              product['product_image'],
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              product['product_name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '\$${product['price']}',
              style: const TextStyle(color: Colors.green),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.yellow.shade700, size: 16),
                const SizedBox(width: 4),
                Text('${product['rating']}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
