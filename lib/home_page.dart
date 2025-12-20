import 'app_logger.dart';
import 'const.dart';
import 'upi_info.dart'
    hide
        sheets;

class HomePage
    extends
        StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<
    HomePage
  >
  createState() => _HomePageState();
}

class _HomePageState
    extends
        State<
          HomePage
        > {
  // ─────────────────────────────────────────────
  // REQUIRED BREAKPOINTS (AS YOU DEMANDED)
  // ─────────────────────────────────────────────
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

  bool loading = true;
  List<
    Product
  >
  products = [];
  int selectedTab = 0;
  bool useGrid = true;

  @override
  void initState() {
    super.initState();
    appLogger.i(
      'HomePage.initState',
    );
    loadProducts();
  }

  // ─────────────────────────────────────────────
  // DATA
  // ─────────────────────────────────────────────
  Future<
    void
  >
  loadProducts() async {
    try {
      final sheets = SheetsApi(
        spreadsheetId: AppConfig.spreadsheetId,
        apiKey: AppConfig.apiKey,
      );

      final fetched = await sheets.fetchProducts();
      fetched.sort(
        (
          a,
          b,
        ) => b.id.compareTo(
          a.id,
        ),
      );

      setState(
        () {
          products = fetched;
          loading = false;
        },
      );
    } catch (
      e,
      st
    ) {
      appLogger.e(
        'HomePage.loadProducts failed: $e',
      );
      appLogger.d(
        'Stack: $st',
      );
      setState(
        () => loading = false,
      );
    }
  }

  bool hasTag(
    Product p,
    String tag,
  ) {
    return p.tags.any(
      (
        t,
      ) =>
          t.trim().toLowerCase() ==
          tag.toLowerCase(),
    );
  }

  List<
    Product
  >
  getFilteredProducts() {
    appLogger.d(
      products
          .map(
            (
              p,
            ) => p.tags,
          )
          .toList(),
    );

    switch (selectedTab) {
      case 1:
        appLogger.d(
          "getFilteredProducts: Returning 'New' tag products (Tab 1)",
        );
        return products
            .where(
              (
                p,
              ) => hasTag(
                p,
                'new',
              ),
            )
            .toList();

      case 2:
        appLogger.d(
          "getFilteredProducts: Returning 'Hot' tag products (Tab 2)",
        );
        return products
            .where(
              (
                p,
              ) => hasTag(
                p,
                'hot',
              ),
            )
            .toList();

      case 3:
        appLogger.d(
          "getFilteredProducts: Returning 'OnSale' tag products (Tab 3)",
        );
        return products
            .where(
              (
                p,
              ) => hasTag(
                p,
                'onsale',
              ),
            )
            .toList();

      default:
        appLogger.d(
          "getFilteredProducts: Returning ALL products (Default Tab)",
        );
        return products;
    }
  }

  Future<
    void
  >
  _onRefresh() async {
    setState(
      () => loading = true,
    );
    await loadProducts();
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(
    BuildContext context,
  ) {
    final filtered = getFilteredProducts();

    return Scaffold(
      // backgroundColor: AppConfig.bg,
      appBar: _buildAppBar(
        context,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                HomeTabBar(
                  selectedIndex: selectedTab,
                  onTap:
                      (
                        i,
                      ) => setState(
                        () => selectedTab = i,
                      ),
                ),
                Expanded(
                  child:
                      isPhone(
                        context,
                      )
                      // 📱 PHONE → pull to refresh
                      ? RefreshIndicator(
                          onRefresh: _onRefresh,
                          child: _buildContent(
                            context,
                            filtered,
                          ),
                        )
                      // 🖥 WEB → normal scroll
                      : _buildContent(
                          context,
                          filtered,
                        ),
                ),
              ],
            ),
      floatingActionButton:
          isPhone(
            context,
          )
          ? FloatingActionButton(
              tooltip: useGrid
                  ? 'List view'
                  : 'Grid view',
              onPressed: () => setState(
                () => useGrid = !useGrid,
              ),
              child: Icon(
                useGrid
                    ? Icons.view_list
                    : Icons.grid_view,
              ),
            )
          : null,
    );
  }

  // ─────────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────────
  AppBar _buildAppBar(
    BuildContext context,
  ) {
    return AppBar(
      backgroundColor: AppConfig.blackText,
      centerTitle: true,
      shape: ShapeBorder.lerp(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(
              48,
            ),
          ),
        ),
        null,
        0.5,
      ),
      title: const Text(
        'Radhe Collection',
        style: TextStyle(
          fontSize: 20,
        ),
      ),

      leading: IconButton(
        icon: Image.asset(
          'web/RC LOGO.png',
          height:
              AppConfig.homePageIconSize +
              16,
        ),
        onPressed: () => showAboutPopup(
          context,
        ),
      ),

      actions: [
        appBarIcon(
          icon: Icons.fact_check_outlined,
          onTap: () {
            sheets.fetchUpdateLogs().then(
              (
                logs,
              ) => showUpdateLogsPopup(
                context,
                logs,
              ),
            );
          },
        ),

        appBarIcon(
          icon: Icons.search,
          onTap: () {
            showSearch(
              context: context,
              delegate: ProductSearchDelegate(
                allProducts: products,
              ),
            );
          },
        ),

        Consumer<
          Cart
        >(
          builder:
              (
                _,
                cart,
                __,
              ) => Stack(
                children: [
                  appBarIcon(
                    icon: Icons.shopping_cart_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (
                                _,
                              ) => const CartScreen(),
                        ),
                      );
                    },
                  ),

                  if (cart.itemCount >
                      0)
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        padding: const EdgeInsets.all(
                          4,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cart.itemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
        ),

        appBarIcon(
          icon: Icons.qr_code_rounded,
          onTap: () => showQrCodePopup(
            context,
          ),
        ),

        const SizedBox(
          width: 6,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // CONTENT
  // ─────────────────────────────────────────────
  Widget _buildContent(
    BuildContext context,
    List<
      Product
    >
    list,
  ) {
    if (list.isEmpty) {
      return _buildEmptyState(
        context,
        list,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(
        12,
      ),
      child: useGrid
          ? _buildGrid(
              context,
              list,
            )
          : _buildList(
              list,
            ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    List<
      Product
    >
    filtered,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (filtered.isEmpty) ...[
            if (selectedTab ==
                1)
              _EmptyTextBox(
                icon: Icons.inventory_2_outlined,
                title: "Nothing new here… yet 👀",
                subtitle: "Our next drop is loading faster than light. Stay tuned.",
              )
            else if (selectedTab ==
                2)
              _EmptyTextBox(
                icon: Icons.inventory_2_outlined,
                title: "No trends detected.",
                subtitle: "Either everything is underrated… or this page broke the algorithm.",
              )
            else if (selectedTab ==
                3)
              _EmptyTextBox(
                icon: Icons.inventory_2_outlined,
                title: "This page fell into a black hole.",
                subtitle: "No discounts survived. Try again soon.",
              ),
          ],

          // const Text(
          //   'Oops! Nothing Here 😢',
          // ),
          const SizedBox(
            height: 12,
          ),
          FilledButton(
            onPressed: _onRefresh,
            child: const Text(
              'Retry',
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // LIST
  // ─────────────────────────────────────────────
  Widget _buildList(
    List<
      Product
    >
    list,
  ) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder:
          (
            _,
            i,
          ) => Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 6,
            ),
            child: ProductListCard(
              product: list[i],
            ),
          ),
    );
  }

  // ─────────────────────────────────────────────
  // GRID (DYNAMIC USING SAME RULE)
  // ─────────────────────────────────────────────
  Widget _buildGrid(
    BuildContext context,
    List<
      Product
    >
    list,
  ) {
    final width = MediaQuery.of(
      context,
    ).size.width;

    // Dynamic columns using SAME 700px rule
    final crossAxisCount =
        isPhone(
          context,
        )
        ? 2
        : (width /
                  220)
              .floor()
              .clamp(
                3,
                8,
              );

    return GridView.builder(
      itemCount: list.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.62,
        // mainAxisExtent: 280,
      ),
      itemBuilder:
          (
            _,
            i,
          ) => ProductGridCard(
            product: list[i],
          ),
    );
  }
}

// The function to display a dialog with the logs
void
showUpdateLogsPopup(
  BuildContext context,
  String logs,
) {
  showDialog(
    context: context,
    builder:
        (
          BuildContext context,
        ) {
          return AlertDialog(
            title: const Text(
              'Update Logs',
            ),

            // 1. Content Area
            content: SizedBox(
              // Constrain the height to make sure it fits on the screen
              // and becomes scrollable if the logs are long.
              height:
                  MediaQuery.of(
                    context,
                  ).size.height *
                  0.5,
              width:
                  MediaQuery.of(
                    context,
                  ).size.width *
                  0.8,

              child: SingleChildScrollView(
                child: Text(
                  // The log content passed into the function
                  logs,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            // 2. Action Buttons
            actions:
                <
                  Widget
                >[
                  TextButton(
                    child: const Text(
                      'Close',
                    ),
                    onPressed: () {
                      // Dismiss the dialog
                      Navigator.of(
                        context,
                      ).pop();
                    },
                  ),
                ],
          );
        },
  );
}

class _EmptyTextBox
    extends
        StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;

  const _EmptyTextBox({
    required this.title,
    required this.subtitle,
    this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final textTheme = Theme.of(
      context,
    ).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(
          20,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            18,
          ),
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(
                alpha: 0.08,
              ),
              Colors.white.withValues(
                alpha: 0.03,
              ),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white.withValues(
              alpha: 0.12,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.25,
              ),
              blurRadius: 18,
              offset: const Offset(
                0,
                8,
              ),
            ),
          ],
        ),
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon !=
                  null)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 6,
                  ),
                  child: Icon(
                    icon,
                    size: 80,
                    color: Colors.white70,
                  ),
                ),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget
appBarIcon({
  required IconData icon,
  required VoidCallback onTap,
}) {
  return InkResponse(
    onTap: onTap,
    radius: 16,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ), // 🔥 control gap HERE
      child: Icon(
        icon,
        size: AppConfig.homePageIconSize,
      ),
    ),
  );
}
