import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PassengerComponents {
  static Widget locationInputCard({
    required String fromLocation,
    required String toLocation,
    required VoidCallback onFromTap,
    required VoidCallback onToTap,
    required VoidCallback onSwap,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.navy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navy.withOpacity(0.22),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Schedule pill
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.yellow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    color: AppTheme.navy,
                    size: 15,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Pickup Now',
                    style: AppTheme.inter(
                      size: 12.5,
                      color: AppTheme.navy,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.navy,
                    size: 17,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          Stack(
            children: [
              // Timeline line
              Positioned(
                left: 11,
                top: 26,
                bottom: 26,
                child: Container(
                  width: 2,
                  color: Colors.white.withOpacity(0.12),
                ),
              ),

              Column(
                children: [
                  // FROM row
                  GestureDetector(
                    onTap: onFromTap,
                    behavior: HitTestBehavior.opaque,
                    child: _locationRow(
                      dotColor: AppTheme.yellow,
                      label: 'From',
                      value: fromLocation,
                      isPlaceholder: fromLocation == 'Set pickup location',
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Divider(
                      color: Colors.white.withOpacity(0.08),
                      height: 1,
                    ),
                  ),

                  // TO row
                  GestureDetector(
                    onTap: onToTap,
                    behavior: HitTestBehavior.opaque,
                    child: _locationRow(
                      dotColor: Colors.white,
                      label: 'To',
                      value: toLocation,
                      isPlaceholder: toLocation == 'Set destination',
                    ),
                  ),
                ],
              ),

              // Swap button
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: onSwap,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppTheme.yellow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.swap_vert_rounded,
                        color: AppTheme.navy,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _locationRow({
    required Color dotColor,
    required String label,
    required String value,
    required bool isPlaceholder,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor.withOpacity(0.15),
            ),
            child: Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.inter(
                    size: 11,
                    color: Colors.white38,
                    weight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTheme.inter(
                    size: 14.5,
                    color: isPlaceholder ? Colors.white30 : Colors.white,
                    weight: isPlaceholder ? FontWeight.w400 : FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  // ── Quick filter pills ────────────────────────────────────
  static Widget quickFilterPill({
    required IconData icon,
    required String text,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppTheme.yellow : AppTheme.navy.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: active
              ? null
              : Border.all(color: AppTheme.grey.withOpacity(0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? AppTheme.navy : AppTheme.navy.withOpacity(0.6),
            ),
            const SizedBox(width: 7),
            Text(
              text,
              style: AppTheme.inter(
                size: 12.5,
                color: active ? AppTheme.navy : AppTheme.navy.withOpacity(0.7),
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Ride option card ─────────────────────────────────────
  static Widget rideOptionCard({
    required double width,
    required String title,
    required String price,
    required IconData icon,
    required VoidCallback onTap,
    bool featured = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: featured ? AppTheme.navy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: featured
                  ? AppTheme.navy.withOpacity(0.18)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: featured
                    ? AppTheme.yellow
                    : AppTheme.navy.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: featured
                    ? AppTheme.navy
                    : AppTheme.navy.withOpacity(0.7),
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: AppTheme.inter(
                size: 13.5,
                color: featured ? Colors.white : AppTheme.navy,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              price,
              style: AppTheme.inter(
                size: 12,
                color: featured ? AppTheme.yellow : AppTheme.grey,
                weight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: featured ? AppTheme.yellow : AppTheme.navy,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 15,
                  color: featured ? AppTheme.navy : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section header ────────────────────────────────────────
  static Widget sectionHeader({
    required String title,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTheme.inter(
            size: 16,
            color: AppTheme.navy,
            weight: FontWeight.w700,
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel,
              style: AppTheme.inter(
                size: 13,
                color: AppTheme.yellow,
                weight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // ── Nearby ride card (horizontal list) ───────────────────
  static Widget nearbyRideCard({
    required String name,
    required String from,
    required String to,
    required String price,
    required String eta,
    required double rating,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar + rating
            Column(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.navy.withOpacity(0.08),
                    border: Border.all(
                      color: AppTheme.yellow.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppTheme.navy,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 11, color: AppTheme.yellow),
                    const SizedBox(width: 2),
                    Text(
                      rating.toStringAsFixed(1),
                      style: AppTheme.inter(
                        size: 10.5,
                        color: AppTheme.navy,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTheme.inter(
                      size: 13.5,
                      color: AppTheme.navy,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _routeMini(from: from, to: to),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Price + ETA
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.navy,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    price,
                    style: AppTheme.inter(
                      size: 12.5,
                      color: AppTheme.yellow,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 11,
                      color: AppTheme.grey,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      eta,
                      style: AppTheme.inter(size: 11, color: AppTheme.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _routeMini({required String from, required String to}) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.yellow,
              ),
            ),
            Container(
              width: 1.5,
              height: 14,
              color: AppTheme.grey.withOpacity(0.3),
            ),
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.navy,
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                from,
                style: AppTheme.inter(size: 11.5, color: AppTheme.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                to,
                style: AppTheme.inter(
                  size: 11.5,
                  color: AppTheme.navy,
                  weight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
