export 'dart:async';
export 'dart:convert';
export 'package:logger/logger.dart';
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:provider/provider.dart';
export 'package:flutter/foundation.dart';
export 'package:url_launcher/url_launcher.dart';
export 'package:url_launcher/url_launcher_string.dart';
export 'package:shared_preferences/shared_preferences.dart';
export 'package:youtube_player_flutter/youtube_player_flutter.dart';

export 'cart.dart';
export 'product.dart';
export 'home_page.dart';
export 'sheets_api.dart';
export 'cart_screen.dart';
export 'home_tabbar.dart';
export 'product_tile.dart';
export 'checkout_page.dart';
export 'loading_screen.dart';
export 'search_delegate.dart';
export 'product_detail_page.dart';

import 'package:flutter/material.dart';




class AppConfig {
  static const String spreadsheetId = "1GV8J2hbXzDt6iD6k-6rJF47O6YSa8tcFraRaUI6W01k";
  static const String apiKey = "AIzaSyD0mNaq5yk5w1lgIOOIA7u1u4Rr6TksWGM";
  static const String appName = "Radhe Collection";
  static const String appVersion = "1.0.0";

  static const Color loadingScreenColor = Colors.cyan;
  static const Color themePink = Colors.pink;
  static const Color error = Colors.red;
  static const Color lineThrough = Colors.red;
  static const Color warning = Colors.amber;
  static const Color loadingIndicator = Colors.white;
  static const Color whiteText = Colors.white;
  static const Color blackText = Colors.black;
  static const Color dontKnow = Colors.orange;
  static const Color dontKnow2 = Colors.green;
  static const Color bg = Color.fromARGB(255, 3, 115, 117);
  static const Color imageBG =  Color.fromARGB(49, 201, 201, 201);

}

Widget
buildTagChipFromContext(
  BuildContext context,
  String tag,
) {
  // Use the standard text theme from the context
  final textTheme = Theme.of(
    context,
  ).textTheme;

  final tagLower = tag.toLowerCase().trim();
  String label = tag;

  // Default neutral colors based on the current theme's color scheme
  Color bgColor = Theme.of(
    context,
  ).colorScheme.secondaryContainer;
  Color textColor = Theme.of(
    context,
  ).colorScheme.onSecondaryContainer;
  BorderSide? border;

  // Define a set of vibrant, single-scheme colors
  switch (tagLower) {
    case 'hot':
      label = 'Hot 🔥';
      // Vibrant Red/Orange for "Hot"
      bgColor = const Color(
        0xFFFFE0E0,
      ); // Light Red Background
      textColor = const Color(
        0xFFD32F2F,
      ); // Deep Red Text
      break;

    case 'trending':
      label = 'Trending 📈';
      // Fresh Green for "Trending"
      bgColor = const Color(
        0xFFE8F5E9,
      ); // Pale Green Background
      textColor = const Color(
        0xFF388E3C,
      ); // Dark Green Text
      break;

    case 'onsale':
    case 'on sale':
      label = 'On Sale 🏷️';
      // Bright Blue for "On Sale"
      bgColor = const Color(
        0xFFE3F2FD,
      ); // Light Blue Background
      textColor = const Color(
        0xFF1976D2,
      ); // Dark Blue Text
      break;

    case 'new':
      label = 'New ✨';
      // Deep Purple for "New"
      bgColor = const Color(
        0xFFF3E5F5,
      ); // Very Light Purple Background
      textColor = const Color(
        0xFF7B1FA2,
      ); // Deep Purple Text
      break;

    default:
      // Neutral small capsule (uses default Theme colors)
      bgColor = Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest;
      textColor = Theme.of(
        context,
      ).colorScheme.onSurfaceVariant;
      break;
  }

  return Chip(
    visualDensity: VisualDensity.compact,
    padding: const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 0,
    ),
    backgroundColor: bgColor,

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        8,
      ),
      side:
          border ??
          BorderSide.none,
    ),

    label: Text(
      label,
      style: textTheme.labelSmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}


Widget
appImage(
  String url, {
  BoxFit fit = BoxFit.contain,
  double? width,
  double? height,
}) {
  return Image.network(
    url,
    width: width,
    height: height,
    fit: fit,

    // Smooth loading UX
    loadingBuilder:
        (
          context,
          child,
          progress,
        ) {
          if (progress ==
              null) {
            return child;
          }
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          );
        },

    // Graceful failure (never crash)
    errorBuilder:
        (
          context,
          error,
          stack,
        ) {
          debugPrint(
            '[ImageError] $url → $error',
          );
          return Container(
            color: Colors.black12,
            alignment: Alignment.center,
            child: const Icon(
              Icons.broken_image_outlined,
              size: 36,
            ),
          );
        },
  );
}
