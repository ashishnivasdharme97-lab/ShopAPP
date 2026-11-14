// import 'package:flutter/material.dart';
// import 'package:shop_app/models/product_model.dart';
// import 'package:shop_app/services/product_service.dart';

// class AdminProductListScreen extends StatefulWidget {
//   const AdminProductListScreen({super.key});

//   @override
//   State<AdminProductListScreen> createState() =>
//       _AdminProductListScreenState();
// }

// class _AdminProductListScreenState
//     extends State<AdminProductListScreen> {

//   List<ProductModel> products = [];
//   List<ProductModel> filteredProducts = [];
// List<String> categoryTabs = [];

// String selectedCategory = "All";
//   bool isLoading = true;

//   final TextEditingController searchController =
//       TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     loadProducts();
//   }

//   Future<void> loadProducts() async {

//   products = await ProductService.getProducts();

//   filteredProducts = products;

//   categoryTabs = [
//     "All",
//     ...products
//         .map((e) => e.categoryName)
//         .toSet()
//         .toList(),
//   ];

//   setState(() {
//     isLoading = false;
//   });
// }

//   void applyFilters() {
//   filteredProducts = products.where((product) {

//     // Category Filter
//     bool matchCategory =
//         selectedCategory == "All" ||
//         product.categoryName == selectedCategory;

//     // Search Filter
//     bool matchSearch =
//         product.productName
//                 .toLowerCase()
//                 .contains(searchController.text.toLowerCase()) ||
//         product.categoryName
//                 .toLowerCase()
//                 .contains(searchController.text.toLowerCase());

//     return matchCategory && matchSearch;

//   }).toList();

//   setState(() {});
// }

// void search(String value) {
//   applyFilters();
// }
// void filterCategory(String category) {

//   selectedCategory = category;

//   applyFilters();
// }

//   Map<String, List<ProductModel>> get groupedProducts {
//     Map<String, List<ProductModel>> data = {};

//     for (var product in filteredProducts) {
//       data.putIfAbsent(product.categoryName, () => []);
//       data[product.categoryName]!.add(product);
//     }

//     return data;
//   }

//   int get totalProducts => filteredProducts.length;

//   int get totalQuantity {
//     int qty = 0;

//     for (var p in filteredProducts) {
//       qty += p.quantity;
//     }

//     return qty;
//   }

//   double get totalValue {
//     double value = 0;

//     for (var p in filteredProducts) {
//       value += p.price * p.quantity;
//     }

//     return value;
//   }
//   int get totalCategories {
//   return products
//       .map((e) => e.categoryName)
//       .toSet()
//       .length;
// }

//   Widget summaryCard(
//       String title,
//       String value,
//       IconData icon,
//       Color color) {
//     return Expanded(
//       child: Container(
//         height: 90,
//         margin: const EdgeInsets.all(3),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon,
//                 color: Colors.white, size: 30),
//             const SizedBox(height: 10),
//             Text(
//               value,
//               style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               style: const TextStyle(
//                   color: Colors.white70),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(
//       backgroundColor: const Color(0xffF4F6FA),

//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         title: const Text(
//           "Inventory",
//           style: TextStyle(color: Colors.white),
//         ),
//         iconTheme:
//             const IconThemeData(color: Colors.white),
//       ),

//       body: isLoading
//           ? const Center(
//               child:
//                   CircularProgressIndicator())
//           : Column(
//               children: [

//                 const SizedBox(height: 15),

//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(
//                           horizontal: 15),
//                   child: TextField(
//                     controller: searchController,
//                     onChanged: search,
//                     decoration: InputDecoration(
//                       hintText:
//                           "Search Product...",
//                       prefixIcon:
//                           const Icon(Icons.search),
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(
//                         borderRadius:
//                             BorderRadius.circular(
//                                 30),
//                         borderSide:
//                             BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 15),

//                 SizedBox(
//   height: 45,

//   child: ListView.builder(

//     scrollDirection: Axis.horizontal,

//     itemCount: categoryTabs.length,

//     itemBuilder: (context,index){

//       final category = categoryTabs[index];

//       final selected =
//           selectedCategory == category;

//       return GestureDetector(

//         onTap: (){
//           filterCategory(category);
//         },

//         child: Container(

//           margin: const EdgeInsets.only(right: 10),

//           padding: const EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 10,
//           ),

//           decoration: BoxDecoration(

//             color: selected
//                 ? Colors.green
//                 : Colors.white,

//             borderRadius:
//                 BorderRadius.circular(25),

//             border: Border.all(
//               color: selected
//                   ? Colors.green
//                   : Colors.grey.shade300,
//             ),
//           ),

//           child: Center(

//             child: Text(

//               category,

//               style: TextStyle(

//                 color: selected
//                     ? Colors.white
//                     : Colors.black,

//                 fontWeight:
//                     FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       );
//     },
//   ),
// ),

//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(
//                           horizontal: 10),
//                   child: Row(
//                     children: [

//                       summaryCard(
//                         "Products",
//                         totalProducts.toString(),
//                         Icons.inventory,
//                         Colors.blue,
//                       ),

//                       summaryCard(
//                         "Quantity",
//                         totalQuantity.toString(),
//                         Icons.shopping_cart,
//                         Colors.orange,
//                       ),

//                    summaryCard(
//   "Categories",
//   totalCategories.toString(),
//   Icons.category,
//   Colors.deepPurple,
// ),
//                       summaryCard(
//                         "Value",
//                         "₹${totalValue.toStringAsFixed(0)}",
//                         Icons.currency_rupee,
//                         Colors.green,
//                       ),

//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 Expanded(
//                   child: ListView(
//                     padding:
//                         const EdgeInsets.all(12),
//                     children:
//                         groupedProducts.entries
//                             .map((entry) {

//                       final category =
//                           entry.key;

//                       final list =
//                           entry.value;

//                       int qty = 0;

//                       for (var p in list) {
//                         qty += p.quantity;
//                       }

//                       return Card(
//                         margin:
//                             const EdgeInsets.only(
//                                 bottom: 15),
//                         shape:
//                             RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.circular(
//                                   18),
//                         ),
//                         child: ExpansionTile(

//                           tilePadding:
//                               const EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 6),

//                           leading: CircleAvatar(
//                             backgroundColor:
//                                 Colors.green
//                                     .shade100,
//                             child: const Icon(
//                               Icons.category,
//                               color: Colors.green,
//                             ),
//                           ),

//                           title: Text(
//                             category,
//                             style:
//                                 const TextStyle(
//                               fontWeight:
//                                   FontWeight.bold,
//                               fontSize: 18,
//                             ),
//                           ),

//                           subtitle: Text(
//                             "${list.length} Products  •  Qty $qty",
//                           ),

//                           children: [
//                             ...list.map((product) {

//   return Container(
//     margin: const EdgeInsets.symmetric(
//       horizontal: 12,
//       vertical: 8,
//     ),
//     padding: const EdgeInsets.all(12),

//     decoration: BoxDecoration(
//       color: Colors.grey.shade50,
//       borderRadius: BorderRadius.circular(16),
//       border: Border.all(
//         color: Colors.grey.shade300,
//       ),
//     ),

//     child: Row(
//       children: [

//         ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: Image.network(
//             product.productImage,
//             width: 75,
//             height: 75,
//             fit: BoxFit.cover,

//             errorBuilder:
//                 (context, error, stackTrace) {
//               return Container(
//                 width: 75,
//                 height: 75,
//                 color: Colors.grey.shade300,
//                 child: const Icon(Icons.image),
//               );
//             },
//           ),
//         ),

//         const SizedBox(width: 14),

//         Expanded(
//           child: Column(
//             crossAxisAlignment:
//                 CrossAxisAlignment.start,
//             children: [

//               Text(
//                 product.productName,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 17,
//                 ),
//               ),

//               const SizedBox(height: 6),

//               Text(
//                 "₹${product.price}",
//                 style: const TextStyle(
//                   color: Colors.green,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),

//               const SizedBox(height: 8),

//               Row(
//                 children: [

//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 5,
//                     ),

//                     decoration: BoxDecoration(
//                       color: Colors.orange.shade100,
//                       borderRadius:
//                           BorderRadius.circular(20),
//                     ),

//                     child: Text(
//                       "Qty : ${product.quantity}",
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.orange,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),

//         Column(
//           children: [

//             CircleAvatar(
//               radius: 18,
//               backgroundColor:
//                   Colors.blue.shade50,

//               child: IconButton(
//                 padding: EdgeInsets.zero,
//                 icon: const Icon(
//                   Icons.edit,
//                   size: 18,
//                   color: Colors.blue,
//                 ),
//                 onPressed: () {

//                   /// Edit Product
//                 },
//               ),
//             ),

//             const SizedBox(height: 10),

//             CircleAvatar(
//               radius: 18,
//               backgroundColor:
//                   Colors.red.shade50,

//               child: IconButton(
//                 padding: EdgeInsets.zero,
//                 icon: const Icon(
//                   Icons.delete,
//                   size: 18,
//                   color: Colors.red,
//                 ),
//                 onPressed: () {

//                   /// Delete Product
//                 },
//               ),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );

// }).toList(),
//                           ],
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shop_app/models/product_model.dart';
import 'package:shop_app/services/product_service.dart';

class AdminProductListScreen extends StatefulWidget {
  const AdminProductListScreen({super.key});

  @override
  State<AdminProductListScreen> createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen> {
  List<ProductModel> products = [];
  List<ProductModel> filteredProducts = [];

  List<String> categoryTabs = [];

  String selectedCategory = "All";

  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    products = await ProductService.getProducts();

    filteredProducts = products;

    categoryTabs = [
      "All",
      ...products.map((e) => e.categoryName).toSet(),
    ];

    setState(() {
      isLoading = false;
    });
  }

  void search(String value) {
    applyFilters();
  }

  void applyFilters() {
    filteredProducts = products.where((product) {
      bool matchCategory =
          selectedCategory == "All" || product.categoryName == selectedCategory;

      bool matchSearch = product.productName
              .toLowerCase()
              .contains(searchController.text.toLowerCase()) ||
          product.categoryName
              .toLowerCase()
              .contains(searchController.text.toLowerCase());

      return matchCategory && matchSearch;
    }).toList();

    setState(() {});
  }

  Map<String, List<ProductModel>> get groupedProducts {
    Map<String, List<ProductModel>> data = {};

    for (var product in filteredProducts) {
      data.putIfAbsent(product.categoryName, () => []);
      data[product.categoryName]!.add(product);
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FB),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xff168A62),
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  //================ HEADER =================//

                  Container(
                    width: double.infinity,
                    height: 208,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xff173B35),
                          Color(0xff168A62),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(35),
                        bottomRight: Radius.circular(35),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 54,
                                width: 54,
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.inventory_2_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 15),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Inventory",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 27,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Manage your catalogue",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  color: const Color(0xff168A62),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            height: 58,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xffE8EDF4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                )
                              ],
                            ),
                            child: TextField(
                              controller: searchController,
                              onChanged: search,
                              decoration: const InputDecoration(
                                hintText: "Search Product",
                                hintStyle: TextStyle(
                                  color: Color(0xff98A2B3),
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: Color(0xff168A62),
                                ),
                                suffixIcon: Icon(
                                  Icons.tune_rounded,
                                  color: Color(0xff98A2B3),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(top: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  //=============== CATEGORY PLACEHOLDER ==============//

                  SizedBox(
                    height: 45,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      itemCount: categoryTabs.length,
                      itemBuilder: (context, index) {
                        final category = categoryTabs[index];

                        final selected = selectedCategory == category;

                        return GestureDetector(
                          onTap: () {
                            selectedCategory = category;

                            applyFilters();
                          },
                          child: categoryChip(
                            category,
                            selected,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  //=============== DASHBOARD PLACEHOLDER ==============//

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: dashboardCard(
                                "Products",
                                filteredProducts.length.toString(),
                                Icons.inventory_2,
                                const Color(0xff168A62),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: dashboardCard(
                                "Categories",
                                (categoryTabs.length - 1).toString(),
                                Icons.category,
                                const Color(0xff5875E8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: dashboardCard(
                                "Stock",
                                products.length.toString(),
                                Icons.shopping_cart,
                                const Color(0xffD98219),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: dashboardCard(
                                "Value",
                                "₹0",
                                Icons.currency_rupee,
                                const Color(0xff5875E8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: groupedProducts.entries.map((entry) {
                            final category = entry.key;
                            final list = entry.value;

                            int qty = 0;

                            for (var p in list) {
                              qty += p.quantity;
                            }

                            return Card(
                              margin: const EdgeInsets.only(bottom: 18),
                              color: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side:
                                    const BorderSide(color: Color(0xffE8EDF4)),
                              ),
                              child: ExpansionTile(
                                initiallyExpanded: true,
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xffE9F5F0),
                                  child: const Icon(
                                    Icons.category_rounded,
                                    color: Color(0xff168A62),
                                  ),
                                ),
                                title: Text(
                                  category,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: Color(0xff243344),
                                  ),
                                ),
                                subtitle: Text(
                                  "${list.length} products · Qty $qty",
                                  style: const TextStyle(
                                      color: Color(0xff75839A), fontSize: 12),
                                ),
                                children: list
                                    .map((product) => productCard(product))
                                    .toList(),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget categoryChip(String text, bool selected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: selected ? const Color(0xff168A62) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selected ? const Color(0xff168A62) : const Color(0xffE8EDF4),
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xff667085),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget dashboardDummy() {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
          )
        ],
      ),
    );
  }

  Widget productCard(ProductModel product) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffE8EDF4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080E1B2A),
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              product.productImage,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 90,
                  height: 90,
                  color: const Color(0xffF1F4F7),
                  child: const Icon(Icons.image),
                );
              },
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff243344),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "₹${product.price}",
                  style: const TextStyle(
                    color: Color(0xff168A62),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffFFF3E2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Qty : ${product.quantity}",
                    style: const TextStyle(
                      color: Color(0xffB76B0B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xffEEF1FF),
                child: IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Color(0xff5875E8),
                  ),
                  onPressed: () {
                    // TODO Edit
                  },
                ),
              ),
              const SizedBox(height: 12),
              CircleAvatar(
                backgroundColor: const Color(0xffFDEEEE),
                child: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Color(0xffD64B4B),
                  ),
                  onPressed: () {
                    // TODO Delete
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget dashboardCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      height: 126,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffE8EDF4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080E1B2A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xff75839A),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                color: Color(0xff172B4D),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
