// Full example app and showcase:
// https://github.com/Abdualsslam/elastic_sheet/tree/main/example
//
// Includes:
// - Interactive playground with live spring controls
// - Care Desk unified showcase
// - Multiple real-world scenarios

import 'package:flutter/material.dart';
import 'src/elastic_sheet_checkout_showcase_page.dart';
import 'src/elastic_sheet_playground.dart';
import 'src/elastic_sheet_unified_showcase_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
      ),
      routes: {
        ElasticSheetUnifiedShowcasePage.routeName: (_) =>
            const ElasticSheetUnifiedShowcasePage(),
        ElasticSheetCheckoutShowcasePage.routeName: (_) =>
            const ElasticSheetCheckoutShowcasePage(),
      },
      home: const ElasticSheetPlayground(),
    );
  }
}
