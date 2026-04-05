import 'package:flutter/material.dart';
import 'package:versystems_app/config/helpers/app_strings_icon_helper.dart';

sealed class SidebarEntry {
  const SidebarEntry();
}

class SidebarSection extends SidebarEntry {
  final String label;
  const SidebarSection({required this.label});
}

class SidebarDivider extends SidebarEntry {
  const SidebarDivider();
}

final class MenuItemModel extends SidebarEntry {
  final IconData icon;
  final String name;
  final String route;
  final List<MenuItemModel>? subItems;
  final bool initiallyExpanded;

  MenuItemModel({required this.icon, required this.name, required this.route, this.subItems, this.initiallyExpanded = false});

  factory MenuItemModel.fromJson(Map<String, dynamic> json) => MenuItemModel(
    icon: iconMap[json['icon']] ?? Icons.circle_rounded,
    name: json['name'] ?? '',
    route: json['route'] ?? '',
    initiallyExpanded: json['initiallyExpanded'],
    subItems: json['subItems'] != null ? (json['subItems'] as List).map((item) => MenuItemModel.fromJson(item as Map<String, dynamic>)).toList() : [],
  );
}
