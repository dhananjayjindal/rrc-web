import 'const.dart';
import 'app_logger.dart';


class ProductDetailPage
    extends
        StatefulWidget {
  final Product product;
  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<
    ProductDetailPage
  >
  createState() => _ProductDetailPageState();
}

class _ProductDetailPageState
    extends
        State<
          ProductDetailPage
        >
    with
        TickerProviderStateMixin {
  
  late PageController _pageController;
  int _activeImage = 0;
  int _quantity = 1;

  // ─────────────────────────────────────────────
  // REQUIRED BREAKPOINTS (AS REQUESTED)
  // ─────────────────────────────────────────────
  bool
  isWeb(
    BuildContext context,
  ) =>
      MediaQuery.of(
        context,
      ).size.width >
      700;

  bool
  isPhone(
    BuildContext context,
  ) =>
      MediaQuery.of(
        context,
      ).size.width <=
      700;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    appLogger.i(
      'ProductDetailPage.initState - productId: ${product.id}, name: ${product.name}',
    );
    _pageController = PageController();

  }

  @override
  void dispose() {
    appLogger.i(
      'ProductDetailPage.dispose - productId: ${widget.product.id}',
    );
    try {
      // _videoController?.dispose();
      // _ytController?.dispose();
      _pageController.dispose();
    } catch (
      e,
      st
    ) {
      appLogger.w(
        'Error disposing controllers: $e',
      );
      appLogger.d(
        'stack: $st',
      );
    }
    super.dispose();
  }

  String? _getImageLink(
    int idx,
  ) {
    if (widget.product.imageUrl.isEmpty) return null;
    if (idx <
            0 ||
        idx >=
            widget.product.imageUrl.length) {
      return null;
    }
    return (widget.product.imageUrl[idx]);
  }

  String? _percentOff() {
    try {
      if (widget.product.price.isEmpty ||
          widget.product.salePrice.isEmpty) {
        return null;
      }
      final p = double.parse(
        widget.product.price,
      );
      final s = double.parse(
        widget.product.salePrice,
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

  void _addToCart() {
    appLogger.i(
      'ProductDetailPage - addToCart pressed (productId: ${widget.product.id}, qty: $_quantity)',
    );
    try {
      Provider.of<
            Cart
          >(
            context,
            listen: false,
          )
          .addItem(
            widget.product,
            _quantity,
          );
      final count =
          Provider.of<
                Cart
              >(
                context,
                listen: false,
              )
              .itemCount;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Added $_quantity item(s) to cart • total $count',
          ),
        ),
      );
    } catch (
      e,
      st
    ) {
      appLogger.e(
        'Error adding to cart: $e',
      );
      appLogger.d(
        'stack: $st',
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to add to cart',
          ),
        ),
      );
    }
  }



  Widget _buildImageCarousel(
    double expandedHeight,
  ) {
    final images = widget.product.imageUrl;
    if (images.isEmpty) {
      return Container(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest,
        child: const Center(
          child: Icon(
            Icons.shopping_bag_outlined,
            size: 96,
          ),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: images.length,
          onPageChanged:
              (
                i,
              ) {
                setState(
                  () => _activeImage = i,
                );
              },
          itemBuilder:
              (
                _,
                idx,
              ) {
                final link = _getImageLink(
                  idx,
                );

                return GestureDetector(
                  onTap:
                      link ==
                          null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (
                                    _,
                                  ) => FullScreenImageViewer(
                                    imageUrl: link,
                                  ),
                            ),
                          );
                        },
                  child: SizedBox(
                    width: double.infinity,
                    height: expandedHeight,
                    child: productHeroImage(
                      context: context,
                      heroTag: 'product_img_${widget.product.id}',
                      imageUrl: link,
                      fit: BoxFit.contain, // correct for detail page
                    ),
                  ),
                );
              },
        ),

        // BACK BUTTON
        Positioned(
          left: 8,
          top:
              MediaQuery.of(
                context,
              ).padding.top +
              8,
          child: _circleAction(
            context,
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(
              context,
            ),
          ),
        ),

        // PRICE CARD
        Positioned(
          left: 16,
          bottom: 16,
          child: _priceBadge(
            context,widget
          ),
        ),

        // PAGE INDICATOR
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (
                i,
              ) {
                final active =
                    i ==
                    _activeImage;
                return AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 250,
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  width: active
                      ? 18
                      : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? Theme.of(
                            context,
                          ).colorScheme.primary
                        : Colors.white70,
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );

  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(
      context,
    );
    final product = widget.product;
    final percent = _percentOff();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              stretch: true,
              expandedHeight: 360,
              backgroundColor: theme.colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildImageCarousel(
                  360,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  14,
                  16,
                  6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + small meta row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (percent !=
                            null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent,
                              borderRadius: BorderRadius.circular(
                                20,
                              ),
                            ),
                            child: Text(
                              percent,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // Short info row: rating placeholder, stock, id
                    Row(
                      children: [
                        const Spacer(),
                        Text(
                          '#${product.id}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // Tags
                    if (product.tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: product.tags
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

                    const SizedBox(
                      height: 14,
                    ),

                    // Description (selectable)
                    Text(
                      'Description',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    SelectableText(
                      product.description,
                      style: theme.textTheme.bodyMedium,
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // Gallery Thumbnails
                    if (product.imageUrl.length >
                        1) ...[
                      Text(
                        'Gallery',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      SizedBox(
                        height: 84,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: product.imageUrl.length,
                          separatorBuilder:
                              (
                                _,
                                _,
                              ) => const SizedBox(
                                width: 8,
                              ),
                          itemBuilder:
                              (
                                context,
                                idx,
                              ) {
                                final link = _getImageLink(
                                  idx,
                                );
                                return GestureDetector(
                                  onTap: () {
                                    _pageController.animateToPage(
                                      idx,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                    setState(
                                      () => _activeImage = idx,
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ),
                                    child:
                                        link !=
                                            null
                                        ? appImage(
                                            link,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 84,
                                            height: 84,
                                            color: theme.colorScheme.surfaceContainerHighest,
                                            child: const Icon(
                                              Icons.broken_image,
                                            ),
                                          ),
                                  ),
                                );
                              },
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                    ],

                    if (product.videoUrl.isNotEmpty) ...[
                      Text(
                        'Product Video',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      VideoPreviewButton(
                        videoUrl: product.videoUrl,
                      ),
                    ],
                    const SizedBox(
                      height: 80,
                    ), // spacing for bottom bar
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Sticky Bottom Bar
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.dividerColor,
              ),
            ),
          ),
          child: Row(
            children: [
              // Quantity selector
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove,
                      ),
                      onPressed:
                          _quantity >
                              1
                          ? () => setState(
                              () => _quantity--,
                            )
                          : null,
                    ),
                    Text(
                      '$_quantity',
                      style: theme.textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                      ),
                      onPressed: () => setState(
                        () => _quantity++,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 12,
              ),

              // Add to cart
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(
                    Icons.add_shopping_cart_outlined,
                  ),
                  label: const Text(
                    'Add to cart',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class FullScreenImageViewer
    extends
        StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(
            context,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Hero(
            tag: imageUrl, // 🔑 MUST match source Hero tag
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 1.0,
              maxScale: 4.0,
              child: Container(
                constraints: const BoxConstraints.expand(),
                alignment: Alignment.center,
                child: appImage(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}







// Assuming the openYoutube function is available globally:
void openYoutube(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }
}

class VideoPreviewButton extends StatelessWidget {
  final String videoUrl;
  final double aspectRatio; // New property to control dynamic height/width ratio
  final BorderRadius borderRadius;

  const VideoPreviewButton({
    super.key,
    required this.videoUrl,
    this.aspectRatio = 16 / 9, // Default to standard video ratio
    this.borderRadius = const BorderRadius.all(Radius.circular(12.0)),
  });

  // Safely get the video ID
  String? get videoId => YoutubePlayer.convertUrlToId(videoUrl);

  // Generate the high-quality thumbnail URL
  String get thumbnailUrl {
    return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  }

  @override
  Widget build(BuildContext context) {
    if (videoId == null) {
      return const SizedBox.shrink(); // Hide if URL is invalid
    }

    // Wrap the content in AspectRatio to make the height dynamic based on the width
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: InkWell(
        onTap: () => openYoutube(videoUrl),
        borderRadius: borderRadius,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Container(
            width: double.infinity,
            // The height is now determined by AspectRatio, so we remove the explicit height
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Stack(
              children: [
                // 1. Thumbnail Image (Dynamic fit based on AspectRatio)
                Positioned.fill(
                  child: Image.network(
                    thumbnailUrl,
                    // Use BoxFit.cover to fill the entire container area defined by AspectRatio
                    fit: BoxFit.cover,
                    color: Colors.black.withValues(alpha:  0.3), // Darken the image
                    colorBlendMode: BlendMode.darken,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade400,
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.white70),
                        ),
                      );
                    },
                  ),
                ),

                // 2. Content (Icon and Label, centered)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min, // Keep row tight to its children
                      children: [
                        // The icon
                        const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        // The label
                        Text(
                          'Watch Product Video',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget
productHeroImage({
  required BuildContext context,
  required String heroTag,
  required String? imageUrl,
  BoxFit fit = BoxFit.cover,
}) {
  return Stack(
    fit: StackFit.expand,
    children: [
      // consistent background
      Container(
        color: AppConfig.imageBG
      ),

      if (imageUrl !=
          null)
        Hero(
          tag: heroTag,
          child: appImage(
            imageUrl,
            fit: fit,
          ),
        )
      else
        const Center(
          child: Icon(
            Icons.broken_image,
            size: 56,
          ),
        ),

      // depth / contrast
      // const DecoratedBox(
      //   decoration: BoxDecoration(
      //     gradient: LinearGradient(
      //       begin: Alignment.bottomCenter,
      //       end: Alignment.topCenter,
      //       colors: [
      //         Colors.black26,
      //         Colors.transparent,
      //       ],
      //     ),
      //   ),
      // ),
    ],
  );
}


Widget
_circleAction(
  BuildContext context, {
  required IconData icon,
  required VoidCallback onTap,
}) {
  return CircleAvatar(
    backgroundColor: Colors.black87,
    child: IconButton(
      icon: Icon(
        icon,
        color: Colors.white,
      ),
      onPressed: onTap,
    ),
  );
}

Widget
_priceBadge(
  BuildContext context,
  dynamic widget,
) {
  final textTheme = Theme.of(
    context,
  ).textTheme;
  final hasSale = widget.product.salePrice.isNotEmpty;

  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
    decoration: BoxDecoration(
      color: Colors.white.withValues( alpha: 0.95,),
      borderRadius: BorderRadius.circular(
        12,
      ),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '₹ ${hasSale ? widget.product.salePrice : widget.product.price}',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppConfig.blackText,
          ),
        ),
        if (hasSale)
          Text(
            '₹ ${widget.product.price}',
            style: textTheme.bodySmall?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
            ),
          ),
      ],
    ),
  );
}
