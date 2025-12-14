import 'app_logger.dart';
import 'const.dart';

enum DeliveryMethod {
  homeDelivery,
  selfPickup,
}

class CheckoutPage
    extends
        StatefulWidget {
  final String vendorWhatsAppNumber;
  const CheckoutPage({
    super.key,
    this.vendorWhatsAppNumber = '',
  });

  @override
  State<
    CheckoutPage
  >
  createState() => _CheckoutPageState();
}

class _CheckoutPageState
    extends
        State<
          CheckoutPage
        > {
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

  bool _showItems = false;

  @override
  void dispose() {
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // WHATSAPP MESSAGE
  // ─────────────────────────────────────────────
  String buildWhatsAppMessage(
    Cart cart,
  ) {
    final b = StringBuffer();
    b.writeln(
      '🛒 ORDER SUMMARY',
    );
    b.writeln(
      '',
    );
    for (final it in cart.items.values) {
      b.writeln(
        '${it.qty} × ${it.price} × ${it.name} = ₹${it.total.toStringAsFixed(2)}',
      );
    }
    b.writeln(
      '',
    );
    b.writeln(
      'TOTAL: ₹${cart.totalAmount.toStringAsFixed(2)}',
    );
    return b.toString();
  }

  Future<
    void
  >
  _sendToWhatsApp(
    Cart cart,
  ) async {


    if (cart.itemCount ==
        0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Cart is empty',
          ),
        ),
      );
      return;
    }

    final msg = buildWhatsAppMessage(
      cart,
    );
    final encoded = Uri.encodeComponent(
      msg,
    );

    if (widget.vendorWhatsAppNumber.isEmpty) {
      await Clipboard.setData(
        ClipboardData(
          text: msg,
        ),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Order copied to clipboard',
          ),
        ),
      );
      return;
    }

    final num = widget.vendorWhatsAppNumber.replaceAll(
      '+',
      '',
    );
    final url = 'https://wa.me/$num?text=$encoded';

    try {
      await launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (
      e
    ) {
      appLogger.e(
        'WhatsApp launch failed: $e',
      );
    }
  }

  Widget _summary(
    Cart cart,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          12,
        ),
        child: Column(
          children: [
            Container(
              child: buildWhatsAppMessagePreview(
                context,
                buildWhatsAppMessage(
                  cart,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                ),
                Text(
                  '₹${cart.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => setState(
                () => _showItems = !_showItems,
              ),
              child: Text(
                _showItems
                    ? 'Hide items'
                    : 'View items',
              ),
            ),
            if (_showItems)
              ...cart.items.values.map(
                (
                  it,
                ) => ListTile(
                  title: Text(
                    it.name,
                  ),
                  trailing: Text(
                    'x${it.qty}',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
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
          'Checkout',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          16,
        ),
        child:
            isPhone(
              context,
            )
            // 📱 PHONE LAYOUT
            ? Column(
                children: [
                
                  _summary(
                    cart,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _sendToWhatsApp(
                      cart,
                    ),
                    icon: const Image(
                      image: AssetImage(
                        'web/WA.png',
                      ),
                      width: 24,
                      height: 24,
                    ),
                    label: const Text(
                      'Send Order via WhatsApp',
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(
                        48,
                      ),
                    ),
                  ),
                ],
              )
            // 🖥 WEB LAYOUT

            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _summary(
                          cart,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _sendToWhatsApp(
                            cart,
                          ),
                          icon: const Image(
                            image: AssetImage(
                              'web/WA.png',
                            ),
                            width: 24,
                            height: 24,
                          ),
                          label: const Text(
                            'Send Order via WhatsApp',
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(
                              48,
                            ),
                          ),
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




// Widget buildWhatsAppMessagePreview(BuildContext context, String message) {
//   // Use a light green color scheme to resemble WhatsApp
//   final Color bubbleColor = Colors.green.shade50; 
//   final Color borderColor = Colors.green.shade300;
//   final Color textColor = Colors.black87;

//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Optional Title/Hint
//         const Text(
//           'Message Preview (Ready to Share):',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey,
//           ),
//         ),
//         const SizedBox(height: 8.0),
        
//         // The Styled Message Bubble
//         Container(
//           // 1. Styling the container to look like a message bubble
//           padding: const EdgeInsets.all(12.0),
//           decoration: BoxDecoration(
//             color: bubbleColor,
//             border: Border.all(color: borderColor, width: 0.5),
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(16.0),
//               topRight: Radius.circular(16.0),
//               bottomRight: Radius.circular(16.0),
//               bottomLeft: Radius.circular(4.0), // Smaller corner for the "sender" side
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(
//                   alpha: 0.1,
//                 ),
//                 blurRadius: 2,
//                 offset: const Offset(1, 1),
//               ),
//             ],
//           ),
          
//           // 2. The Text Content
//           child: Text(
//             message,
//             style: TextStyle(
//               fontSize: 16,
//               color: textColor,
//               height: 1.4, // Improve readability for long messages
//             ),
//           ),
//         ),
//         const SizedBox(height: 8.0),
//       ],
//     ),
//   );
// }

Widget
buildWhatsAppMessagePreview(
  BuildContext context,
  String message,
) {
  return Padding(
    padding: const EdgeInsets.all(
      16,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Message Preview (Ready to Share)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(
          height: 10,
        ),

        // Chat background
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(
            12,
          ),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage(
                'assets/WABG.jpg',
              ),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),

          // Message bubble
          child: Align(
            alignment: Alignment.centerRight, // outgoing msg
            child: Stack(
              children: [
                // Bubble
                Container(
                  constraints: BoxConstraints(
                    maxWidth:
                        MediaQuery.of(
                          context,
                        ).size.width *
                        0.75,
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    12,
                    8,
                    46,
                    22,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFE7FFDB,
                    ), // WhatsApp green
                    borderRadius: BorderRadius.circular(
                      14,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.12,
                        ),
                        blurRadius: 4,
                        offset: const Offset(
                          1,
                          2,
                        ),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.35,
                    ),
                  ),
                ),

                // Time + ticks
                Positioned(
                  bottom: 4,
                  right: 8,
                  child: Row(
                    children: [
                      Text(
                        formatTime(),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Icon(
                        Icons.done_all,
                        size: 16,
                        color: Color(
                          0xFF4FC3F7,
                        ), // blue ticks
                      ),
                    ],
                  ),
                ),

                // Bubble tail
                Positioned(
                  right: -6,
                  bottom: 0,
                  child: CustomPaint(
                    painter: _BubbleTailPainter(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}


class _BubbleTailPainter
    extends
        CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = const Color(
        0xFFE7FFDB,
      )
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(
      0,
      10,
    );
    path.lineTo(
      10,
      15,
    );
    path.lineTo(
      0,
      20,
    );
    path.close();

    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    CustomPainter oldDelegate,
  ) => false;
}


String
formatTime() {
  final now = DateTime.now();
  final hour =
      now.hour %
              12 ==
          0
      ? 12
      : now.hour %
            12;
  final minute = now.minute.toString().padLeft(
    2,
    '0',
  );
  final period =
      now.hour >=
          12
      ? 'pm'
      : 'am';
  return '$hour:$minute $period';
}
