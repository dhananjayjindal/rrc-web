import 'app_logger.dart';
import 'const.dart';

/// ---------------------------------------------------------------------------
/// Shared helpers (image + percent off)
/// ---------------------------------------------------------------------------
var bg = Color.fromARGB(255, 44, 43, 43);
String?
percentOff(
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
    return '${(((p - s) / p) * 100).round()}% OFF';
  } catch (
    _
  ) {
    return null;
  }
}

Widget
productImage({
  required BuildContext context,
  required String heroTag,
  required String? imageUrl,
  BorderRadiusGeometry? borderRadius,
}) {
  return ClipRRect(
    borderRadius:
        borderRadius ??
        BorderRadius.circular(
          14,
        ),
    child: Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: AppConfig.imageBG,
        ),

        Hero(
          tag: heroTag,
          child:
              imageUrl !=
                  null
              ? appImage(
                  imageUrl,
                  fit: BoxFit.cover,
                )
              : const Center(
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 42,
                  ),
                ),
        ),

        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black26,
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    ),
  );
}


Widget
saleBadge(
  BuildContext context,
  String text,
) {
  final textTheme = Theme.of(
    context,
  ).textTheme;
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 5,
    ),
    decoration: BoxDecoration(
      color: Theme.of(
        context,
      ).colorScheme.primary,
      borderRadius: BorderRadius.circular(
        20,
      ),
      boxShadow: const [
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
      text,
      style: textTheme.labelSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

/// ---------------------------------------------------------------------------
/// PRODUCT LIST CARD
/// ---------------------------------------------------------------------------

class ProductListCard
    extends
        StatelessWidget {
  final Product product;

  const ProductListCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final textTheme = Theme.of(
      context,
    ).textTheme;

    final hasSale = product.salePrice.isNotEmpty;
    final imageUrl = product.imageUrl.isNotEmpty
        ? product.imageUrl.first
        : null;
    final badgeText = hasSale
        ? percentOff(
            product.price,
            product.salePrice,
          )
        : null;

    return Card(
      // shadowColor: Colors.white,
      
      color: bg,
      elevation: 2.5,
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          color: Colors.white, // 🎯 BORDER COLOR
          width: 1,
        ),
        borderRadius: BorderRadius.circular(
          14,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          appLogger.i(
            'ProductListCard.onTap - productId: ${product.id}',
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
          height: 120,
          child: Row(
            children: [
              // IMAGE
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
                          screenWidth >=
                              600
                          ? 160.0
                          : screenWidth *
                                0.32;

                      return SizedBox(
                        width: imageWidth,
                        child: Stack(
                          children: [
                            productImage(
                              context: context,
                              heroTag: 'product_img_${product.id}',
                              imageUrl: imageUrl,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(
                                  14,
                                ),
                                bottomLeft: Radius.circular(
                                  14,
                                ),
                              ),
                            ),
                            if (badgeText !=
                                null)
                              Positioned(
                                left: 8,
                                top: 8,
                                child: saleBadge(
                                  context,
                                  badgeText,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
              ),

              // CONTENT
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TITLE
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),

                      // TAGS
                      if (product.tags.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: product.tags
                              .take(
                                6,
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

                      const Spacer(),

                      // PRICE ROW
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  '₹ ${hasSale ? product.salePrice : product.price}',
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (hasSale) ...[
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    '₹ ${product.price}',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade500,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
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

/// ---------------------------------------------------------------------------
/// PRODUCT GRID CARD
/// ---------------------------------------------------------------------------

class ProductGridCard
    extends
        StatelessWidget {
  final Product product;

  const ProductGridCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final textTheme = Theme.of(
      context,
    ).textTheme;

    final hasSale = product.salePrice.isNotEmpty;
    final imageUrl = product.imageUrl.isNotEmpty
        ? product.imageUrl.first
        : null;
    final badgeText = hasSale
        ? percentOff(
            product.price,
            product.salePrice,
          )
        : null;

    return Card(
      color: bg,
      elevation: 2.5,
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          color: Colors.white, // 🎯 BORDER COLOR
          width: 1,
        ),
        borderRadius: BorderRadius.circular(
          14,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          appLogger.i(
            'ProductGridCard.onTap - productId: ${product.id}',
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
            // IMAGE
            AspectRatio(
              aspectRatio: 1.1,
              child: Stack(
                children: [
                  productImage(
                    context: context,
                    heroTag: 'product_img_${product.id}',
                    imageUrl: imageUrl,
                  ),
                  if (badgeText !=
                      null)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: saleBadge(
                        context,
                        badgeText,
                      ),
                    ),
                ],
              ),
            ),

            // DETAILS
            Padding(
              padding: const EdgeInsets.all(
                10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Text(
                              '₹ ${hasSale ? product.salePrice : product.price}',
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (hasSale) ...[
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                '₹ ${product.price}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade500,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
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

                  if (product.tags.isNotEmpty) ...[
                    const SizedBox(
                      height: 6,
                    ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
