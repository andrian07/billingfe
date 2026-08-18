import 'package:flutter/material.dart';

import '../../services/session_storage.dart';
import 'app_header.dart';
import 'app_sidebar.dart';

class AppLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final String? subtitle;
  final bool showSearch;
  final String activeMenuKey;
  final ValueChanged<String> onMenuSelect;

  const AppLayout({
    super.key,
    required this.child,
    required this.title,
    this.subtitle,
    this.showSearch = true,
    required this.activeMenuKey,
    required this.onMenuSelect,
  });

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  // Null shows every sidebar item, which is also the correct look while
  // permissions are still loading (SessionStorage caches after the first
  // read, so this only actually awaits once per app run).
  Set<String>? _allowedMenuKeys;

  // Static: every page route builds its own AppLayout instance (see
  // app_router.dart), so instance state would reset the sidebar to
  // expanded on every navigation. This keeps the collapsed/expanded
  // choice consistent across pages for the rest of the app run.
  static bool _sidebarCollapsed = false;

  @override
  void initState() {
    super.initState();
    _loadAllowedMenuKeys();
  }

  Future<void> _loadAllowedMenuKeys() async {
    final keys = await SessionStorage().getAllowedMenuKeys();
    if (mounted) setState(() => _allowedMenuKeys = keys);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            activeKey: widget.activeMenuKey,
            onSelect: widget.onMenuSelect,
            allowedMenuKeys: _allowedMenuKeys,
            collapsed: _sidebarCollapsed,
            onToggleCollapse: () {
              setState(() => _sidebarCollapsed = !_sidebarCollapsed);
            },
          ),

          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: widget.title,
                  subtitle: widget.subtitle,
                  showSearch: widget.showSearch,
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
