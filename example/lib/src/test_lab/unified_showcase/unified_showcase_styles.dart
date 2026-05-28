import 'package:flutter/material.dart';

BoxDecoration collapsedSurfaceDecoration(Color accent) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(22),
  border: Border.all(color: accent.withAlpha(34)),
  boxShadow: [
    BoxShadow(
      color: accent.withAlpha(18),
      blurRadius: 18,
      offset: const Offset(0, 10),
    ),
  ],
);

BoxDecoration expandedSurfaceDecoration(Color accent) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(24),
  border: Border.all(color: accent.withAlpha(34)),
  boxShadow: const [
    BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 14)),
  ],
);

BoxDecoration calendarSurfaceDecoration(Color accent, Color tint) =>
    BoxDecoration(
      color: tint,
      borderRadius: BorderRadius.circular(18),
    );
