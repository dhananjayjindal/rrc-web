import 'app_logger.dart';
import 'const.dart';

class ProductSearchDelegate
    extends
        SearchDelegate {
  final List<
    Product
  >
  allProducts;

  ProductSearchDelegate({
    required this.allProducts,
  });

  @override
  List<
    Widget
  >?
  buildActions(
    BuildContext context,
  ) {
    return [
      IconButton(
        icon: const Icon(
          Icons.clear,
        ),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(
    BuildContext context,
  ) {
    return IconButton(
      icon: const Icon(
        Icons.arrow_back,
      ),
      onPressed: () => close(
        context,
        null,
      ),
    );
  }

  // Shared helper to build a modern Card row for a product
  Widget _buildProductCard(
    BuildContext context,
    Product product,
  ) {
    final imageUrl = (product.imageUrl.isNotEmpty)
        ? (product.imageUrl.first)
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          appLogger.i(
            'SearchResult.onTap - productId: ${product.id}',
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailPage(product: product),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          child: Row(
            children: [
              // Left: text column (name then price)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name (primary)
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    // Price (secondary)
                    Row(
                      children: [
                        if (product.salePrice.isNotEmpty)
                          Text(
                            '₹${product.salePrice}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        if (product.salePrice.isNotEmpty)
                          const SizedBox(
                            width: 8,
                          ),
                        if (product.salePrice.isNotEmpty)
                          Text(
                            '₹${product.price}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        if (product.salePrice.isEmpty)
                          Text(
                            '₹${product.price}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right: image
              const SizedBox(
                width: 12,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  8,
                ),
                child: SizedBox(
                  // 1. **CRITICAL FIX**: Define a fixed size for the image area
                  width: 90,
                  height: 90,

                  child:
                      imageUrl !=
                          null
                      ? appImage(
                          imageUrl,
                          // 2. Adjust BoxFit:
                          //    - BoxFit.cover is usually better for filling a fixed area without distortion
                          //    - BoxFit.fitHeight might crop the sides to fit the 90 height
                          fit: BoxFit.cover, // Consider changing to BoxFit.cover or leaving it as BoxFit.fitHeight
                        )
                      : Container(
                          // The placeholder already has the correct size
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 36,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget buildResults(
    BuildContext context,
  ) {
    final results = allProducts
        .where(
          (
            p,
          ) => p.name.toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();

    if (results.isEmpty) {
      return const Center(
        child: Text(
          'No matching products found.',
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder:
          (
            context,
            index,
          ) {
            final product = results[index];
            return _buildProductCard(
              context,
              product,
            );
          },
    );
  }

  @override
  Widget buildSuggestions(
    BuildContext context,
  ) {
    final suggestions =
        query
            .trim()
            .isEmpty
        ? allProducts
              .take(
                10,
              )
              .toList() // top 10 suggestions when query empty
        : allProducts
              .where(
                (
                  p,
                ) => p.name.toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();

    if (suggestions.isEmpty) {
      return const Center(
        child: Text(
          'No suggestions.',
        ),
      );
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder:
          (
            context,
            index,
          ) {
            final product = suggestions[index];
            return _buildProductCard(
              context,
              product,
            );
          },
    );
  }
}
