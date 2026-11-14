import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shop_app/models/product_model.dart';
import 'package:shop_app/views/home/widgets/alert_screen.dart';
import 'package:shop_app/views/home/widgets/category_products_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shop_app/views/home/widgets/request_product_screen.dart';
import 'package:shop_app/views/home/widgets/popular_products_screen.dart';
import 'package:shop_app/views/home/widgets/recently_added_screen.dart';
import 'package:shop_app/models/category_model.dart';
import 'package:shop_app/data/default_categories.dart';
import 'package:shop_app/services/category_service.dart';
import 'package:shop_app/services/product_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentLocation = "Fetching location...";
  int selectedIndex = 0;

  // 🔥 SELECTED CATEGORY
  String selectedCategory = "Grocery";

  final FocusNode searchFocusNode = FocusNode();
  final TextEditingController searchController = TextEditingController();
  final ScrollController _categoryScrollController = ScrollController();
  final PageController _promoPageController = PageController();
  Timer? _promoTimer;
  int _currentPromoIndex = 0;

  String get _currentDateLabel {
    final now = DateTime.now();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  final List<Map<String, dynamic>> _promoSlides = [
    {
      'eyebrow': 'YOUR EVERYDAY STORE',
      'title': 'Everything you need,\nall in one place.',
      'subtitle': 'Browse your local favorites',
      'image': 'assets/images/shopping-bag.png',
      'colors': [const Color(0xff176B52), const Color(0xff24A879)],
    },
    {
      'eyebrow': 'TREAT YOURSELF',
      'title': 'Little treats,\nbig smiles.',
      'subtitle': 'Discover snacks and sweets',
      'image': 'assets/images/cake.png',
      'colors': [const Color(0xff8D4E78), const Color(0xffD987A9)],
    },
    {
      'eyebrow': 'STAY REFRESHED',
      'title': 'A refreshing pick\nfor every day.',
      'subtitle': 'Explore drinks and more',
      'image': 'assets/images/drinks.png',
      'colors': [const Color(0xff286A8D), const Color(0xff55A9B6)],
    },
    {
      'eyebrow': 'DIWALI SPECIAL',
      'title': 'Light up your\ncelebration.',
      'subtitle': 'Shop crackers and festive decor',
      'emoji': '🎆🪔',
      'colors': [const Color(0xff9A3D12), const Color(0xffF2A900)],
    },
    {
      'eyebrow': 'GANAPATI FESTIVE DECOR',
      'title': 'Welcome Bappa\nin style.',
      'subtitle': 'Find decorations for your home',
      'emoji': '🙏🐘',
      'colors': [const Color(0xff8A3E78), const Color(0xffE78174)],
    },
  ];

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    loadCategories();
    loadProducts();
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_promoPageController.hasClients || !mounted) return;
      final nextIndex = (_currentPromoIndex + 1) % _promoSlides.length;
      _promoPageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    searchController.dispose();
    _categoryScrollController.dispose();
    _promoTimer?.cancel();
    _promoPageController.dispose();
    super.dispose();
  }

  Widget _buildPromoSlideshow() {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _promoPageController,
            itemCount: _promoSlides.length,
            onPageChanged: (index) {
              setState(() {
                _currentPromoIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final slide = _promoSlides[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                padding: const EdgeInsets.fromLTRB(20, 17, 16, 17),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: slide['colors'],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1C176B52),
                      blurRadius: 16,
                      offset: Offset(0, 7),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slide['eyebrow'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              letterSpacing: 1.1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            slide['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            slide['subtitle'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 92,
                      height: 92,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: slide['emoji'] != null
                          ? Center(
                              child: Text(
                                slide['emoji'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 34),
                              ),
                            )
                          : Image.asset(
                              slide['image'],
                              fit: BoxFit.contain,
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _promoSlides.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _currentPromoIndex == index ? 20 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: _currentPromoIndex == index
                    ? const Color(0xff168A62)
                    : const Color(0xffC9D3D0),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _selectSearchCategory(String categoryName) {
    setState(() {
      selectedCategory = categoryName;
      searchController.clear();
    });
    searchFocusNode.unfocus();
  }

  Widget _buildSearchResults() {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) return const SizedBox.shrink();

    final matchingProducts = products.where((product) {
      return product.productName.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          product.categoryName.toLowerCase().contains(query);
    }).toList();
    final matchingCategories = categories.where((category) {
      return category.categoryName.toLowerCase().contains(query) ||
          matchingProducts.any(
            (product) => product.categoryName == category.categoryName,
          );
    }).toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE8EDF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (matchingCategories.isNotEmpty) ...[
            const Text(
              'Categories',
              style: TextStyle(
                color: Color(0xff172B4D),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            ...matchingCategories.map(
              (category) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xffE7F4EE),
                  child: Icon(
                    Icons.category_outlined,
                    color: Color(0xff168A62),
                    size: 20,
                  ),
                ),
                title: Text(category.categoryName),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
                onTap: () => _selectSearchCategory(category.categoryName),
              ),
            ),
          ],
          if (matchingProducts.isNotEmpty) ...[
            if (matchingCategories.isNotEmpty) const Divider(height: 18),
            const Text(
              'Products',
              style: TextStyle(
                color: Color(0xff172B4D),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            ...matchingProducts.map(
              (product) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xffF2F5F7),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: Color(0xff168A62),
                    size: 20,
                  ),
                ),
                title: Text(product.productName),
                subtitle: Text(product.categoryName),
                trailing: Text(
                  '₹${product.price}',
                  style: const TextStyle(
                    color: Color(0xff168A62),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () => _selectSearchCategory(product.categoryName),
              ),
            ),
          ],
          if (matchingCategories.isEmpty && matchingProducts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'No matching products or categories found.',
                style: TextStyle(color: Color(0xff75839A), fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> loadProducts() async {
    products = await ProductService.getProducts();

    print("TOTAL PRODUCTS = ${products.length}");

    for (var p in products) {
      print("PRODUCT = ${p.productName}");
      print("IMAGE = ${p.productImage}");
    }

    setState(() {
      isProductLoading = false;
    });
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // LOCATION SERVICE CHECK
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      setState(() {
        currentLocation = "Location OFF";
      });
      return;
    }

    // PERMISSION CHECK
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        setState(() {
          currentLocation = "Permission Denied";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        currentLocation = "Permission Permanently Denied";
      });
      return;
    }

    // GET POSITION
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // GET ADDRESS
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    Placemark place = placemarks[0];

    setState(() {
      currentLocation = "${place.locality}, ${place.country}";
    });
  }

  Future<void> loadCategories() async {
    final loadedCategories = await CategoryService.getCategories();

    for (var c in loadedCategories) {
      print("Category = ${c.categoryName}");
      print("Image = ${c.categoryImage}");
    }

    if (!mounted) return;

    setState(() {
      categories =
          loadedCategories.isEmpty ? defaultStoreCategories : loadedCategories;
      selectedCategory = categories.first.categoryName;
      isCategoryLoading = false;
    });
  }

  // 🔥 MODULES
  final List<Map<String, dynamic>> modules = [
    {
      "name": "General Store",
      "image": "assets/images/shopping-bag.png",
      "color": const Color.fromARGB(255, 204, 223, 216)
    },
    {
      "name": "Electrical",
      "image": "assets/images/electrical.png",
      "color": const Color(0xFFF8BBD0)
    },
    {
      "name": "Hardware",
      "image": "assets/images/hardware.png",
      "color": const Color(0xFFD1C4E9)
    },
    {
      "name": "Fashion",
      "image": "assets/images/fashion.png",
      "color": const Color(0xFFFFE4E1)
    },
  ];

  // 🔥 CATEGORIES
  List<CategoryModel> categories = defaultStoreCategories;
  bool isCategoryLoading = true;

  List<ProductModel> products = [];
  bool isProductLoading = true;

// 🔥 POPULAR PRODUCTS
  final List<Map<String, dynamic>> popularProducts = [
    {
      "name": "Popular Cake",
      "price": "₹220",
      "image": "assets/images/cake.png",
      "color": Colors.pink,
    },
    {
      "name": "Popular Drink",
      "price": "₹40",
      "image": "assets/images/drinks.png",
      "color": Colors.green,
    },
    {
      "name": "Popular Snacks",
      "price": "₹25",
      "image": "assets/images/snack.png",
      "color": Colors.orange,
    },
  ];

  Widget _buildCategoryImage(CategoryModel category) {
    final image = category.categoryImage;
    if (image == null || image.isEmpty) {
      return const Icon(Icons.category_rounded, color: Color(0xff168A62));
    }

    if (image.startsWith('assets/')) {
      return Image.asset(image, fit: BoxFit.contain);
    }

    return Image.network(
      image,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.image_not_supported_outlined,
          color: Color(0xff98A2B3),
        );
      },
    );
  }

  Widget _buildNoProducts() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffE8EDF4)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: Color(0xff168A62),
            size: 28,
          ),
          SizedBox(height: 7),
          Text(
            'No products in this category',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xff344054),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 FILTER PRODUCTS
    final filteredProducts = products.where((p) {
      return p.categoryName == selectedCategory;
    }).toList();

    print("Selected Category = $selectedCategory");
    print("Filtered Count = ${filteredProducts.length}");
    return Scaffold(
        backgroundColor: const Color(0xffF5F7FA),
        // 🔥 APP BAR
        appBar: AppBar(
          backgroundColor: const Color(0xffF5F7FA),
          elevation: 0,
          toolbarHeight: 78,
          titleSpacing: 18,
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi, Ashish 👋",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xff172B4D),
                  fontSize: 19,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: const Color(0xff168A62),
                  ),
                  SizedBox(width: 4),
                  Text(
                    currentLocation,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xff778397),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _currentDateLabel,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xff98A2B3),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xff344054),
              ),
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlertScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 6),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Color(0xff344054),
                size: 21,
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            searchFocusNode.unfocus();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔍 SEARCH
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xffE8EDF1)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x080E1B2A),
                        blurRadius: 14,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    focusNode: searchFocusNode,
                    controller: searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Color(0xff168A62)),
                      hintText: "Search products...",
                      hintStyle: const TextStyle(
                          color: Color(0xff98A2B3), fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      suffixIcon: searchController.text.isEmpty
                          ? const Icon(
                              Icons.tune_rounded,
                              color: Color(0xff98A2B3),
                            )
                          : IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Color(0xff98A2B3),
                              ),
                              onPressed: () {
                                setState(searchController.clear);
                              },
                            ),
                    ),
                  ),
                ),

                _buildSearchResults(),

                const SizedBox(height: 22),

                // 🏬 MODULES
                const Text(
                  "Shop by Modules",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Color(0xff172B4D),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: 76,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: modules.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 158,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              modules[index]["color"].withValues(alpha: 0.7),
                              Colors.white,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xffE8EDF1)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A172B4D),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .88),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                modules[index]["image"],
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.storefront_rounded,
                                    color: Color(0xff168A62),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                modules[index]["name"],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xff243344),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                _buildPromoSlideshow(),

                const SizedBox(height: 20),

                // 🏷 CATEGORIES
                Row(
                  children: [
                    const Text(
                      "Categories",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: Color(0xff172B4D),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: 122,
                  child: Scrollbar(
                    controller: _categoryScrollController,
                    thumbVisibility: true,
                    thickness: 3,
                    radius: const Radius.circular(8),
                    child: ListView.builder(
                      controller: _categoryScrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected =
                            selectedCategory == category.categoryName;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = category.categoryName;
                            });
                          },
                          child: Container(
                            width: 94,
                            margin: const EdgeInsets.only(right: 12, bottom: 8),
                            child: Column(
                              children: [
                                Container(
                                  height: 72,
                                  width: 72,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: Colors.green.withValues(
                                                alpha: 0.35,
                                              ),
                                              blurRadius: 12,
                                              spreadRadius: 2,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xff168A62)
                                          : const Color(0xffE8EDF1),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: _buildCategoryImage(category),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  category.categoryName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: isSelected
                                        ? const Color(0xff168A62)
                                        : const Color(0xff667085),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff176B52),
                        Color(0xff168A62),
                        Color(0xff24A879)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x24168A62),
                        blurRadius: 16,
                        offset: Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // ICON
                      Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .16),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // TEXT
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Can't find your product?",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Send a request for the product you need.",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // BUTTON
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RequestProductScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xff168A62),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Request Product",
                          style: TextStyle(
                            color: const Color(0xff168A62),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🛍 PRODUCTS TITLE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$selectedCategory Products",
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: Color(0xff172B4D),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryProductsScreen(
                              title: "$selectedCategory Products",
                              products: filteredProducts,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "See All  →",
                        style: TextStyle(
                            color: Color(0xff168A62),
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: 200,
                  child: filteredProducts.isEmpty
                      ? _buildNoProducts()
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            print(
                                "IMAGE URL = ${filteredProducts[index].productImage}");

                            return Container(
                              width: 142,
                              margin: const EdgeInsets.only(right: 14),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border:
                                    Border.all(color: const Color(0xffEDF1F5)),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x080E1B2A),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: 98,
                                    width: 126,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffF5F7FA),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Image.network(
                                      filteredProducts[index].productImage,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.broken_image);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    filteredProducts[index].productName,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: Color(0xff344054),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "₹${filteredProducts[index].price}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xff168A62),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 25),

// 🆕 RECENTLY ADDED
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recently Added",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: Color(0xff172B4D),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecentlyAddedScreen(
                              products: filteredProducts,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "See All  →",
                        style: TextStyle(
                            color: Color(0xff168A62),
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 200,
                  child: filteredProducts.isEmpty
                      ? _buildNoProducts()
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 142,
                              margin: const EdgeInsets.only(right: 14),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border:
                                    Border.all(color: const Color(0xffEDF1F5)),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x080E1B2A),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: 98,
                                    width: 126,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffF5F7FA),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Image.network(
                                      filteredProducts[index].productImage,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover, // किंवा BoxFit.contain
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.broken_image);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 34,
                                    child: Text(
                                      filteredProducts[index].productName,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: Color(0xff344054),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "₹${filteredProducts[index].price}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xff168A62),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 25),

                // 🔥 POPULAR PRODUCTS TITLE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Popular Products",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: Color(0xff172B4D),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PopularProductsScreen(
                              products: popularProducts,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "See All  →",
                        style: TextStyle(
                          color: Color(0xff168A62),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 164,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: popularProducts.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 122,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xffEDF1F5)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x080E1B2A),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 55,
                              width: 55,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xffF4F7F8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Image.asset(
                                popularProducts[index]["image"],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              popularProducts[index]["name"],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: Color(0xff344054),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              popularProducts[index]["price"],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: popularProducts[index]["color"],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
