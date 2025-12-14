
import 'const.dart';

final sheets = SheetsApi(
  spreadsheetId: AppConfig.spreadsheetId,
  apiKey: AppConfig.apiKey,
);

class CartScreen
    extends
        StatelessWidget {
  const CartScreen({
    super.key,
  });

  // ───────────────────────────────────────────────────────────
  // REQUIRED BREAKPOINTS (AS YOU ASKED – EXACT)
  // ───────────────────────────────────────────────────────────
  bool
  isWeb(
    BuildContext context,
  ) =>
      MediaQuery.of(
        context,
      ).size.width >=
      700;

  bool
  isPhone(
    BuildContext context,
  ) =>
      MediaQuery.of(
        context,
      ).size.width <=
      700;

  // ───────────────────────────────────────────────────────────
  // EMPTY STATE
  // ───────────────────────────────────────────────────────────
  Widget _buildEmpty(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 96,
              color:
                  Theme.of(
                    context,
                  ).colorScheme.primary.withValues(
                    alpha: 0.85,
                  ),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              'Your cart is empty',
              style: Theme.of(
                context,
              ).textTheme.titleLarge,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              'Looks like you haven\'t added anything yet.',
              textAlign: TextAlign.center,
              style:
                  Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(
                    color:
                        Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                  ),
            ),
            const SizedBox(
              height: 18,
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(
                context,
              ),
              child: const Text(
                'Continue shopping',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  // CART LIST (SHARED BY WEB & PHONE)
  // ───────────────────────────────────────────────────────────
  Widget _buildCartList(
    BuildContext context,
    Cart cart,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(
        12,
      ),
      itemCount: cart.distinctCount,
      separatorBuilder:
          (
            _,
            _,
          ) => const SizedBox(
            height: 8,
          ),
      itemBuilder:
          (
            _,
            i,
          ) {
            final item = cart.items.values.toList()[i];

            return Dismissible(
              key: ValueKey(
                item.id,
              ),
              direction:
                  isWeb(
                    context,
                  )
                  ? DismissDirection.none
                  : DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.error,
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              confirmDismiss:
                  (
                    _,
                  ) async {
                    return await showDialog<
                          bool
                        >(
                          context: context,
                          builder:
                              (
                                _,
                              ) => AlertDialog(
                                title: const Text(
                                  'Remove item',
                                ),
                                content: Text(
                                  'Remove "${item.name}" from cart?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(
                                      context,
                                      false,
                                    ),
                                    child: const Text(
                                      'Cancel',
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(
                                      context,
                                      true,
                                    ),
                                    child: const Text(
                                      'Remove',
                                    ),
                                  ),
                                ],
                              ),
                        ) ??
                        false;
                  },
              onDismissed:
                  (
                    _,
                  ) => cart.removeItem(
                    item.id,
                  ),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                    12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                        ),
                        child:
                            item.imageUrl !=
                                null
                            ? ClipRRect(
                                // <--- 1. Use ClipRRect to enforce the clipping
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                                child: appImage(
                                  item.imageUrl!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.shopping_bag_outlined,
                              ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium,
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Text(
                              'Rs ${item.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () => cart.increment(
                              item.id,
                            ),
                            icon: const Icon(
                              Icons.add,
                            ),
                          ),
                          Text(
                            item.qty.toString(),
                          ),
                          IconButton(
                            onPressed: () => cart.decrement(
                              item.id,
                            ),
                            icon: const Icon(
                              Icons.remove,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                        ),
                        color: Theme.of(
                          context,
                        ).colorScheme.error,
                        onPressed: () => cart.removeItem(
                          item.id,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
    );
  }

  // ───────────────────────────────────────────────────────────
  // SUMMARY / CHECKOUT PANEL
  // ───────────────────────────────────────────────────────────
  Widget _buildSummary(
    BuildContext context,
    Cart cart,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(
              context,
            ).dividerColor,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total',
            style: Theme.of(
              context,
            ).textTheme.bodySmall,
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            'Rs ${cart.totalAmount.toStringAsFixed(2)}',
            style:
                Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(
            height: 16,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(
                Icons.send,
              ),
              label: const Text(
                'Checkout',
              ),
              onPressed:
                  cart.itemCount ==
                      0
                  ? null
                  : () async {
                      final vendorNo = await sheets.fetchNo();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (
                                _,
                              ) => CheckoutPage(
                                vendorWhatsAppNumber: vendorNo,
                              ),
                        ),
                      );
                    },
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
                  cart.itemCount ==
                      0
                  ? null
                  : () => cart.clear(),
              child: const Text(
                'Clear cart',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  // BUILD
  // ───────────────────────────────────────────────────────────
  @override
  Widget build(
    BuildContext context,
  ) {
    final cart =
        Provider.of<
          Cart
        >(
          context,
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Cart',
        ),
        centerTitle: true,
      ),
      body:
          cart.itemCount ==
              0
          ? _buildEmpty(
              context,
            )
          : isPhone(
              context,
            )
          // 📱 PHONE → VERTICAL
          ? Column(
              children: [
                Expanded(
                  child: _buildCartList(
                    context,
                    cart,
                  ),
                ),
                _buildSummary(
                  context,
                  cart,
                ),
              ],
            )
          // 🖥 WEB → SPLIT VIEW
          : Column(
              children: [
                Expanded(
                  child: _buildCartList(
                    context,
                    cart,
                  ),
                ),
                _buildSummary(
                  context,
                  cart,
                ),
              ],
            ),
    );
  }
}
