import 'const.dart';

class HomeTabBar
    extends
        StatelessWidget {
  final int selectedIndex;
  final void Function(
    int,
  )
  onTap;

  const HomeTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  // ─────────────────────────────────────────────
  // REQUIRED BREAKPOINTS (AS REQUESTED)
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

  static const List<
    String
  >
  tabs = [
    "All Products",
    "New Arrivals",
    "Most Selling",
    "On Sale",
  ];

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(
        4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.05,
        ),
        borderRadius: BorderRadius.circular(
          14,
        ),
      ),
      child:
          isPhone(
            context,
          )
          // 📱 PHONE → scrollable tabs
          ? 
          ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              separatorBuilder:
                  (
                    _,
                    _,
                  ) => const SizedBox(
                    width: 2,
                  ),
              itemBuilder:
                  (
                    _,
                    i,
                  ) => _TabItem(
                    label: tabs[i],
                    isSelected:
                        selectedIndex ==
                        i,
                    onTap: () => onTap(
                      i,
                    ),
                    isWeb: false,
                  ),
            )
          // Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: List.generate(
          //       tabs.length,
          //       (
          //         i,
          //       ) => _TabItem(
          //         label: tabs[i],
          //         isSelected:
          //             selectedIndex ==
          //             i,
          //         onTap: () => onTap(
          //           i,
          //         ),
          //         isWeb: true,
          //       ),
          //     ),
          //   )
          // 🖥 WEB → evenly spaced tabs
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                tabs.length,
                (
                  i,
                ) => _TabItem(
                  label: tabs[i],
                  isSelected:
                      selectedIndex ==
                      i,
                  onTap: () => onTap(
                    i,
                  ),
                  isWeb: true,
                ),
              ),
            ),
    );
  }
}

/// ─────────────────────────────────────────────
/// SINGLE TAB ITEM (REUSABLE)
/// ─────────────────────────────────────────────
class _TabItem
    extends
        StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isWeb;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isWeb,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        12,
      ),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 200,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isWeb
              ? 20
              : 8,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppConfig.whiteText.withAlpha(90)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(
            12,
          ),
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isWeb
                  ? 24
                  : 15,
              fontWeight: isSelected
                  ? FontWeight.bold
                  : FontWeight.w500,
              color: isSelected
                  ? AppConfig.blackText
                  : AppConfig.whiteText.withValues(
                      alpha: 0.65,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
