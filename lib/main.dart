import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const PastelShop());

class Palette {
  static const cream = Color(0xFFFFFBF6);
  static const blush = Color(0xFFFFE4E8);
  static const lilac = Color(0xFFEAE3F9);
  static const mint = Color(0xFFE4F2E9);
  static const peach = Color(0xFFFFE9D6);
  static const ink = Color(0xFF35333D);
  static const muted = Color(0xFF85818B);
  static const primary = Color(0xFFAD7897);
}

class Product {
  final int id, stock;
  final String title, description, category, brand, thumbnail;
  final List<String> images;
  final double price, rating, discount;
  Product({
    required this.id,
    required this.stock,
    required this.title,
    required this.description,
    required this.category,
    required this.brand,
    required this.thumbnail,
    required this.images,
    required this.price,
    required this.rating,
    required this.discount,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id: (j['id'] as num).toInt(),
    stock: (j['stock'] as num?)?.toInt() ?? 0,
    title: j['title']?.toString() ?? '',
    description: j['description']?.toString() ?? '',
    category: j['category']?.toString() ?? '',
    brand: j['brand']?.toString() ?? 'Unbranded',
    thumbnail: j['thumbnail']?.toString() ?? '',
    images: (j['images'] as List? ?? []).map((e) => e.toString()).toList(),
    price: (j['price'] as num?)?.toDouble() ?? 0,
    rating: (j['rating'] as num?)?.toDouble() ?? 0,
    discount: (j['discountPercentage'] as num?)?.toDouble() ?? 0,
  );
}

class ProductsApi {
  static Future<List<Product>> list({String query = ''}) async {
    final path = query.trim().isEmpty ? '/products' : '/products/search';
    final url = Uri.https(
      'dummyjson.com',
      path,
      query.trim().isEmpty ? {'limit': '0'} : {'q': query.trim(), 'limit': '0'},
    );
    final response = await http.get(url).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200)
      throw Exception('Server error (${response.statusCode})');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['products'] as List)
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<Product> detail(int id) async {
    final response = await http
        .get(Uri.https('dummyjson.com', '/products/$id'))
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) throw Exception('Produk tidak ditemukan');
    return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}

class PastelShop extends StatelessWidget {
  const PastelShop({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'KatyuStore',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Palette.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Palette.primary,
        surface: Palette.cream,
      ),
      fontFamily: 'SF Pro Display',
    ),
    home: const HomeScreen(),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  List<Product> _products = [];
  bool _loading = true;
  String? _error;
  int _request = 0;
  String _category = 'All';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load([String query = '']) async {
    final token = ++_request;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final products = await ProductsApi.list(query: query);
      if (!mounted || token != _request) return;
      setState(() {
        _products = products;
        _loading = false;
        _category = 'All';
      });
    } catch (_) {
      if (!mounted || token != _request) return;
      setState(() {
        _loading = false;
        _error = 'Gagal memuat produk. Periksa internet dan coba lagi.';
      });
    }
  }

  void _searchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 420), () => _load(value));
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'All',
      ..._products.map((e) => e.category).toSet().toList()..sort(),
    ];
    final visible = _category == 'All'
        ? _products
        : _products.where((p) => p.category == _category).toList();
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HELLO, BEAUTIFUL ✿',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Palette.primary,
                                  letterSpacing: 2,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'KatyuStore',
                                style: TextStyle(
                                  fontSize: 31,
                                  fontWeight: FontWeight.w800,
                                  color: Palette.ink,
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(13),
                          decoration: const BoxDecoration(
                            color: Palette.lilac,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_mall_outlined,
                            color: Palette.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 23),
                    Container(
                      decoration: BoxDecoration(
                        color: Palette.blush,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your little happy place',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: Palette.ink,
                                  ),
                                ),
                                SizedBox(height: 7),
                                Text(
                                  'Discover lovely things,\none product at a time.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.55,
                                    color: Palette.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 77,
                            height: 77,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Palette.cream,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '✿',
                              style: TextStyle(
                                fontSize: 60,
                                color: Palette.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _search,
                      onChanged: _searchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search your favorites...',
                        hintStyle: const TextStyle(color: Palette.muted),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Palette.primary,
                        ),
                        suffixIcon: _search.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  _search.clear();
                                  _debounce?.cancel();
                                  _load();
                                },
                              ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 17,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Explore products',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Palette.ink,
                          ),
                        ),
                        Text(
                          '${visible.length} items',
                          style: const TextStyle(
                            color: Palette.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (!_loading && _error == null)
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final value = categories[i];
                            final active = value == _category;
                            return ChoiceChip(
                              label: Text(
                                value == 'All'
                                    ? 'All products'
                                    : value.replaceAll('-', ' '),
                              ),
                              selected: active,
                              onSelected: (_) =>
                                  setState(() => _category = value),
                              showCheckmark: false,
                              selectedColor: Palette.lilac,
                              backgroundColor: Colors.white,
                              side: BorderSide.none,
                              labelStyle: TextStyle(
                                color: Palette.ink,
                                fontSize: 12,
                                fontWeight: active
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Palette.primary),
                ),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: _Status(
                  message: _error!,
                  onRetry: () => _load(_search.text),
                ),
              )
            else if (visible.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('No products found 🌷')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 5, 22, 26),
                sliver: SliverGrid.builder(
                  itemCount: visible.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 13,
                    childAspectRatio: .69,
                  ),
                  itemBuilder: (context, i) => ProductCard(product: visible[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _Status({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: Palette.primary,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    ),
  );
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});
  @override
  Widget build(BuildContext context) {
    final bg = [
      Palette.lilac,
      Palette.mint,
      Palette.peach,
      Palette.blush,
    ][product.id % 4];
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => DetailScreen(id: product.id))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: bg,
                      padding: const EdgeInsets.all(10),
                      child: Image.network(
                        product.thumbnail,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported_outlined,
                          color: Palette.muted,
                        ),
                      ),
                    ),
                  ),
                  if (product.discount > 0)
                    Positioned(
                      top: 9,
                      left: 9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          '-${product.discount.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category.replaceAll('-', ' ').toUpperCase(),
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 9,
                      letterSpacing: .7,
                      color: Palette.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Palette.ink,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Palette.ink,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.star_rounded,
                        size: 15,
                        color: Color(0xFFE3AE5D),
                      ),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Palette.muted,
                        ),
                      ),
                    ],
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

class DetailScreen extends StatefulWidget {
  final int id;
  const DetailScreen({super.key, required this.id});
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Product> _future;
  int _photo = 0;
  @override
  void initState() {
    super.initState();
    _future = ProductsApi.detail(widget.id);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: FutureBuilder<Product>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Palette.primary),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _Status(
              message: 'Could not load product details.',
              onRetry: () => setState(() {
                _future = ProductsApi.detail(widget.id);
              }),
            );
          }
          final p = snapshot.data!;
          final images = p.images.isEmpty ? [p.thumbnail] : p.images;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Container(
                      color: Palette.lilac,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 13, 18, 0),
                            child: Row(
                              children: [
                                IconButton.filledTonal(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'PRODUCT DETAILS',
                                  style: TextStyle(
                                    fontSize: 12,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Spacer(),
                                const SizedBox(width: 48),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 290,
                            child: PageView.builder(
                              itemCount: images.length,
                              onPageChanged: (i) => setState(() => _photo = i),
                              itemBuilder: (_, i) => Padding(
                                padding: const EdgeInsets.all(22),
                                child: Image.network(
                                  images[i],
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.image_not_supported_outlined,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          if (images.length > 1)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  images.length,
                                  (i) => Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    width: i == _photo ? 19 : 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: i == _photo
                                          ? Palette.primary
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(23),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.category.replaceAll('-', ' ').toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Palette.primary,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            p.title,
                            style: const TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                              color: Palette.ink,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFE3AE5D),
                                size: 20,
                              ),
                              Text(
                                ' ${p.rating.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${p.stock} in stock',
                                style: const TextStyle(color: Palette.muted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Palette.mint,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.local_shipping_outlined,
                                  color: Palette.ink,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'A little joy delivered to you',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 23),
                          const Text(
                            'About this product',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Palette.ink,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            p.description,
                            style: const TextStyle(
                              color: Palette.muted,
                              fontSize: 14,
                              height: 1.7,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Brand: ${p.brand}',
                            style: const TextStyle(
                              color: Palette.ink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PRICE',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.5,
                              color: Palette.muted,
                            ),
                          ),
                          Text(
                            '\$${p.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              color: Palette.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Palette.blush,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text(
                        'Made to make you smile ✿',
                        style: TextStyle(
                          color: Palette.ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
