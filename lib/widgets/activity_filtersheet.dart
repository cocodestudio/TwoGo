import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class ActivityFilterSheet extends StatefulWidget {
  const ActivityFilterSheet({super.key});

  @override
  State<ActivityFilterSheet> createState() => _ActivityFilterSheetState();
}

class _ActivityFilterSheetState extends State<ActivityFilterSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  String _selectedType = 'All';
  String _selectedPeriod = 'All Time';
  String _selectedStatus = 'All';

  final _types = ['All', 'Scooter', 'Pillion', 'Express'];
  final _periods = ['Today', 'This Week', 'This Month', 'All Time'];
  final _statuses = ['All', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        // ── Blur scrim ─────────────────────────────────────────
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: Colors.black.withOpacity(0.4),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),

        // ── Sheet ──────────────────────────────────────────────
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
                ),
            child: Container(
              padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPad + 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Trips',
                        style: AppTheme.playfair(
                          size: 22,
                          color: AppTheme.navy,
                          weight: FontWeight.w700,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedType = 'All';
                            _selectedPeriod = 'All Time';
                            _selectedStatus = 'All';
                          });
                        },
                        child: Text(
                          'Reset',
                          style: AppTheme.inter(
                            size: 13,
                            color: AppTheme.yellow,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _filterGroup(
                    label: 'Ride Type',
                    items: _types,
                    selected: _selectedType,
                    onSelect: (v) => setState(() => _selectedType = v),
                  ),
                  const SizedBox(height: 20),
                  _filterGroup(
                    label: 'Time Period',
                    items: _periods,
                    selected: _selectedPeriod,
                    onSelect: (v) => setState(() => _selectedPeriod = v),
                  ),
                  const SizedBox(height: 20),
                  _filterGroup(
                    label: 'Status',
                    items: _statuses,
                    selected: _selectedStatus,
                    onSelect: (v) => setState(() => _selectedStatus = v),
                  ),

                  const SizedBox(height: 28),

                  // Apply button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context, _selectedType);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.navy,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.navy.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Apply Filters',
                          style: AppTheme.inter(
                            size: 15,
                            color: Colors.white,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterGroup({
    required String label,
    required List<String> items,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.inter(
            size: 13,
            color: AppTheme.grey,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            final active = selected == item;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelect(item);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: active ? AppTheme.navy : AppTheme.bg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: active
                        ? AppTheme.navy
                        : Colors.black.withOpacity(0.08),
                  ),
                ),
                child: Text(
                  item,
                  style: AppTheme.inter(
                    size: 13,
                    color: active ? Colors.white : AppTheme.grey,
                    weight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
