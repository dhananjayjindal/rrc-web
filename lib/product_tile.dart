import 'app_logger.dart';
import 'const.dart';

class ProductListCard
    extends
        StatelessWidget {
  final Product product;
  // final VoidCallback? onAddToCart;
  // final VoidCallback? onToggleWishlist;

  const ProductListCard({
    super.key,
    required this.product,
    // this.onAddToCart,
    // this.onToggleWishlist,
  });

  String? _percentOff(
    String price,
    String salePrice,
  ) {
    try {
      if (price.isEmpty ||
          salePrice.isEmpty) {
        return null;
      }
      final p = double.parse(
        price,
      );
      final s = double.parse(
        salePrice,
      );
      if (p <=
              0 ||
          s >=
              p) {
        return null;
      }
      final diff =
          ((p -
                      s) /
                  p *
                  100)
              .round();
      return '$diff% OFF';
    } catch (
      _
    ) {
      return null;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final textTheme = Theme.of(
      context,
    ).textTheme;
    final bool hasSale = product.salePrice.isNotEmpty;
    final imageUrl = product.imageUrl.isNotEmpty
        ? (product.imageUrl.first)
        : null;
    final percentBadge = hasSale
        ? _percentOff(
            product.price,
            product.salePrice,
          )
        : null;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          14,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          appLogger.i(
            'ProductCard.onTap - productId: ${product.id} - navigating to ProductDetailPage',
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (
                    _,
                  ) => ProductDetailPage(
                    product: product,
                  ),
            ),
          );
        },
        child: SizedBox(
          height: 120, // fixed card height — adjust if you want taller cards
          child: Row(
            children: [
              // Left: image (responsive width ~ 33% of screen or fixed)
              LayoutBuilder(
                builder:
                    (
                      context,
                      constraints,
                    ) {
                      final screenWidth = MediaQuery.of(
                        context,
                      ).size.width;
                      final imageWidth =
                          (screenWidth >=
                              600)
                          ? 160.0
                          : screenWidth *
                                0.32;
                      return SizedBox(
                        width: imageWidth,
                        height: double.infinity,
                        child: Stack(
                          children: [
                            // Hero for image transition
                            Positioned.fill(
                              child: Hero(
                                tag: 'product_img_${product.id}',
                                child: Container(
                                  // Use the background color for the container itself
                                  color: AppConfig.imageBG,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(
                                        14,
                                      ),
                                      bottomLeft: Radius.circular(
                                        14,
                                      ),
                                    ),
                                    child:
                                        imageUrl !=
                                            null
                                        ? appImage(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.surfaceContainerHighest,
                                            child: const Center(
                                              child: Icon(
                                                Icons.shopping_bag_outlined,
                                                size: 42,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),

                            // Top-left sale badge or percent off
                            if (percentBadge !=
                                null)
                              Positioned(
                                left: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurpleAccent,
                                    borderRadius: BorderRadius.circular(
                                      20,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 6,
                                        offset: Offset(
                                          0,
                                          2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    percentBadge,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
              ),

              // Right: content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        product.name,
                        style: textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 6,
                      ),

                      // Tags (wrap, limited height)
                      if (product.tags.isNotEmpty)
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: product.tags
                                  .take(
                                    6,
                                  ) // limit tags shown
                                  .map(
                                    (
                                      t,
                                    ) => buildTagChipFromContext(
                                      context,
                                      t,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),

                      const Spacer(),

                      // Price row + id + wishlist
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Price block
                          Expanded(
                            child: Row(
                              children: [
                                if (hasSale) ...[
                                  Text(
                                    '₹ ${product.salePrice}',
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    '₹ ${product.price}',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ] else ...[
                                  Text(
                                    '₹ ${product.price}',
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Product id (small)
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 8.0,
                            ),
                            child: Text(
                              '#${product.id}',
                              style: textTheme.bodySmall?.copyWith(
                                color: Theme.of(
                                  context,
                                ).hintColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductGridCard
    extends
        StatelessWidget {
  final Product product;
  // final VoidCallback? onAddToCart;
  // final VoidCallback? onToggleWishlist;

  const ProductGridCard({
    super.key,
    required this.product,
    // this.onAddToCart,
    // this.onToggleWishlist,
  });

  String _formatPrice(
    String price,
  ) {
    if (price.isEmpty) return '-';
    return '₹ $price';
  }

  // Optional: compute percent off; returns null if not applicable
  String? _percentOff(
    String price,
    String salePrice,
  ) {
    try {
      if (price.isEmpty ||
          salePrice.isEmpty) {
        return null;
      }
      final p = double.parse(
        price,
      );
      final s = double.parse(
        salePrice,
      );
      if (p <=
              0 ||
          s >=
              p) {
        return null;
      }
      final diff =
          ((p -
                      s) /
                  p *
                  100)
              .round();
      return '$diff% OFF';
    } catch (
      _
    ) {
      return null;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final textTheme = Theme.of(
      context,
    ).textTheme;
    final bool hasSale = product.salePrice.isNotEmpty;
    final imageUrl = product.imageUrl.isNotEmpty
        ? (product.imageUrl.first)
        : null;
    final percentBadge = hasSale
        ? _percentOff(
            product.price,
            product.salePrice,
          )
        : null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          appLogger.i(
            'ProductCardGrid.onTap - productId: ${product.id} - navigating to ProductDetailPage',
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (
                    _,
                  ) => ProductDetailPage(
                    product: product,
                  ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image area with overlayed actions & badges
            AspectRatio(
              aspectRatio: 1.1, // slightly taller images for product focus
              child: Stack(
                children: [
                  // Hero image
                  Positioned.fill(
                    child: Container(
                      color: AppConfig.imageBG,
                      child: Hero(
                        tag: 'product_img_${product.id}',
                        child:
                            imageUrl !=
                                null
                            ? appImage(
                                imageUrl,
                                fit: BoxFit.contain,
                              )
                            : Container(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                child: const Center(
                                  child: Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 36,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),

                  // Top-left sale badge or percent off
                  if (percentBadge !=
                      null)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          borderRadius: BorderRadius.circular(
                            20,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(
                                0,
                                2,
                              ),
                            ),
                          ],
                        ),
                        child: Text(
                          percentBadge,
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Details area
            Padding(
              padding: const EdgeInsets.all(
                10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name first
                  Text(
                    product.name,
                    style: textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 6,
                  ),

                  // Price row: sale price first (if present) then original
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            if (hasSale) ...[
                              Text(
                                _formatPrice(
                                  product.salePrice,
                                ),
                                style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                _formatPrice(
                                  product.price,
                                ),
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ] else ...[
                              Text(
                                _formatPrice(
                                  product.price,
                                ),
                                style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // small id
                      Text(
                        '#${product.id}',
                        style: textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).hintColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  // Tags (limited to avoid overflow)
                  if (product.tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: product.tags
                          .take(
                            4,
                          )
                          .map(
                            (
                              t,
                            ) => buildTagChipFromContext(
                              context,
                              t,
                            ),
                          )
                          .toList(),
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
