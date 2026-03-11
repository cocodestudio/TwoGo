import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class LocationSelectScreen extends StatefulWidget {
  final bool isFrom;

  const LocationSelectScreen({super.key, required this.isFrom});

  @override
  State<LocationSelectScreen> createState() => _LocationSelectScreenState();
}

class _LocationSelectScreenState extends State<LocationSelectScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late AnimationController _entryCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;
  String _query = '';

  static const _recents = [
    (
      icon: Icons.history_rounded,
      label: 'Saharanpur City Center',
      sub: 'Recently used',
    ),
    (
      icon: Icons.history_rounded,
      label: 'Shobhit University, Gangoh',
      sub: 'Recently used',
    ),
    (
      icon: Icons.history_rounded,
      label: 'Old Bus Stand, Saharanpur',
      sub: '3 days ago',
    ),
  ];

  static const _suggestions = [
    (
      icon: Icons.school_rounded,
      label: 'Shobhit University',
      sub: 'Gangoh, Saharanpur',
    ),
    (
      icon: Icons.location_city_rounded,
      label: 'Saharanpur City Center',
      sub: 'Near Clock Tower',
    ),
    (
      icon: Icons.local_hospital_rounded,
      label: 'District Hospital',
      sub: 'Saharanpur',
    ),
    (
      icon: Icons.train_rounded,
      label: 'Saharanpur Railway Station',
      sub: '3.2 km away',
    ),
    (
      icon: Icons.shopping_bag_rounded,
      label: 'Emporium Mall',
      sub: 'Saharanpur',
    ),
    (icon: Icons.mosque_rounded, label: 'Dargah Sharif', sub: 'Saharanpur'),
  ];

  List<({IconData icon, String label, String sub})> get _filtered {
    if (_query.isEmpty) return [];
    return _suggestions
        .where((s) => s.label.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
    _entryCtrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  void _select(String location) {
    HapticFeedback.selectionClick();
    Navigator.pop(context, location);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isFrom = widget.isFrom;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Bg gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF8F8F4),
                  Color(0xFFEFEFEB),
                  Color(0xFFE8E8E3),
                ],
              ),
            ),
          ),

          // Top navy blob
          Positioned(
            top: -size.width * 0.4,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.85,
              height: size.width * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.navy.withOpacity(0.09),
                    AppTheme.navy.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppTheme.navy,
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isFrom ? 'From where?' : 'Where to?',
                                  style: AppTheme.playfair(
                                    size: 22,
                                    color: AppTheme.navy,
                                    weight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  isFrom
                                      ? 'Set your pickup location'
                                      : 'Set your drop-off location',
                                  style: AppTheme.inter(
                                    size: 12.5,
                                    color: AppTheme.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Dot indicator
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: isFrom ? AppTheme.yellow : AppTheme.navy,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (isFrom ? AppTheme.yellow : AppTheme.navy)
                                          .withOpacity(0.35),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.navy.withOpacity(0.07),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Icon(
                              Icons.search_rounded,
                              color: AppTheme.navy.withOpacity(0.45),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                autofocus: true,
                                style: AppTheme.inter(
                                  size: 14.5,
                                  color: AppTheme.navy,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: isFrom
                                      ? 'Search pickup...'
                                      : 'Search destination...',
                                  hintStyle: AppTheme.inter(
                                    size: 14,
                                    color: AppTheme.grey.withOpacity(0.7),
                                  ),
                                  isDense: true,
                                ),
                                onChanged: (v) => setState(() => _query = v),
                              ),
                            ),
                            if (_query.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchCtrl.clear();
                                  setState(() => _query = '');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: AppTheme.grey.withOpacity(0.7),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Use current location
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () => _select('Current Location'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.yellow.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppTheme.yellow.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppTheme.yellow,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.my_location_rounded,
                                  size: 18,
                                  color: AppTheme.navy,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Use current location',
                                    style: AppTheme.inter(
                                      size: 13.5,
                                      color: AppTheme.navy,
                                      weight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'GPS — accurate to ~10m',
                                    style: AppTheme.inter(
                                      size: 11.5,
                                      color: AppTheme.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: AppTheme.navy.withOpacity(0.3),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Results / Recents
                    Expanded(
                      child: _query.isEmpty
                          ? _buildRecents()
                          : _buildSearchResults(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
          child: Text(
            'Recent Places',
            style: AppTheme.inter(
              size: 12,
              color: AppTheme.grey,
              weight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: _recents.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: AppTheme.grey.withOpacity(0.1),
              indent: 56,
            ),
            itemBuilder: (_, i) => _LocationTile(
              icon: _recents[i].icon,
              label: _recents[i].label,
              sub: _recents[i].sub,
              onTap: () => _select(_recents[i].label),
              iconBg: AppTheme.navy.withOpacity(0.06),
              iconColor: AppTheme.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    final results = _filtered;
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppTheme.grey.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No results for "$_query"',
              style: AppTheme.inter(color: AppTheme.grey, size: 14),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: results.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: AppTheme.grey.withOpacity(0.1), indent: 56),
      itemBuilder: (_, i) => _LocationTile(
        icon: results[i].icon,
        label: results[i].label,
        sub: results[i].sub,
        onTap: () => _select(results[i].label),
        iconBg: AppTheme.navy.withOpacity(0.06),
        iconColor: AppTheme.navy,
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;
  final Color iconBg;
  final Color iconColor;

  const _LocationTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTheme.inter(
                      size: 14,
                      color: AppTheme.navy,
                      weight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: AppTheme.inter(size: 11.5, color: AppTheme.grey),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.north_west_rounded,
              size: 16,
              color: AppTheme.grey.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}