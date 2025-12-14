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

List<
    Product
  >
  getFilteredProducts() {
    switch (selectedTab) {
      case 1:
        // LOG: Log for 'New Arrivals'
        appLogger.d(
          "getFilteredProducts: Returning 'New' tag products (Tab 1)",
        );
        return products
            .where(
              (
                p,
              ) => p.tags.contains(
                'New',
              ),
            )
            .toList();
      case 2:
        // LOG: Log for 'Hot Products'
        appLogger.d(
          "getFilteredProducts: Returning 'Hot' tag products (Tab 2)",
        );
        return products
            .where(
              (
                p,
              ) => p.tags.contains(
                'Hot',
              ),
            )
            .toList();
      case 3:
        // LOG: Log for 'On Sale'
        appLogger.d(
          "getFilteredProducts: Returning 'OnSale' tag products (Tab 3)",
        );
        return products
            .where(
              (
                p,
              ) => p.tags.contains(
                'OnSale',
              ),
            )
            .toList();
      default:
        // LOG: Log for the default case (usually 'All Products')
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
      backgroundColor: AppConfig.bg,
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
      title: const Text(
        'Radhe Collection',
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.info_outline,
        ),
        onPressed: () => showAboutPopup(
          context,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            // FIX: Replaced non-existent Icons.logs with a suitable alternative
            Icons.fact_check_outlined,
          ),
          onPressed: () {
            // Keeps your existing asynchronous logic
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
        IconButton(
          icon: const Icon(
            Icons.search,
          ),
          onPressed: () {
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
                _,
              ) => Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                    ),
                    onPressed: () {
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
                      right: 6,
                      top: 6,
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
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
        ),
        IconButton(
          icon: const Icon(
            Icons.qr_code_rounded,
          ),
          onPressed: () => showQrCodePopup(
            context,
          ),
        ),
        const SizedBox(
          width: 8,
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
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 80,
          ),
          const SizedBox(
            height: 12,
          ),
          const Text(
            'No products',
          ),
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
        childAspectRatio: 0.7,
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
