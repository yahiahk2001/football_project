import 'package:flutter/material.dart';

class StoresPage extends StatelessWidget {
  final List<Map<String, dynamic>> stores = [
    {
      'store_id': 1,
      'store_name': 'Nike Store',
      'store_cover':
          'https://miro.medium.com/v2/resize:fit:512/1*W1oEL4FzULNlhtbv51K2HA.jpeg',
      'store_logo':
          'https://img.20mn.fr/Stfx3dfKT6q9SaZ4Xnrs5yk/1444x920_nike-devoile-des-offres-folles-sur-ces-3-paires-mythiques-d-air-max',
      'store_description':
          'Explore the latest Nike sports gear and accessories.',
    },
    {
      'store_id': 2,
      'store_name': 'Adidas Store',
      'store_cover':
          'https://t3.ftcdn.net/jpg/04/36/01/74/360_F_436017400_ATTx1DH0TZfhZfz3dSHMo3cafsSbGpoG.jpg',
      'store_logo':
          'https://t4.ftcdn.net/jpg/04/17/34/89/360_F_417348945_08aoaDhBzLAfBu5ehXCQgLClPYFBfRpV.jpg',
      'store_description':
          'Discover Adidas sportswear and high-performance products.',
    },
    {
      'store_id': 3,
      'store_name': 'Puma Store',
      'store_cover':
          'https://www.shutterstock.com/image-photo/california-usa-september-27-2024-260nw-2537592895.jpg',
      'store_logo':
          'https://as1.ftcdn.net/v2/jpg/03/40/62/18/1000_F_340621882_t80vTJ201ScK5dv6DlTDXDEXfi5mrh1a.jpg',
      'store_description':
          'Discover Puma sportswear and high-performance products.',
    },
  ];

  StoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sports Stores',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: stores.length,
          itemBuilder: (context, index) {
            final store = stores[index];
            return GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ميزة المتجر غير متوفرة حاليا'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // صورة خلفية المتجر
                      Image.network(
                        store['store_logo'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      // طبقة شفافة فوق الصورة
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.6),
                                Colors.black54,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),
                      // تفاصيل المتجر
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store['store_name'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              store['store_description'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
