import 'package:flutter/material.dart';

class Header extends SliverPersistentHeaderDelegate {
  final double extent;
  final Widget child;

  Header({required this.extent, required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  double get maxExtent => extent;

  @override
  double get minExtent => extent;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}