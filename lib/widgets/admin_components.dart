import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class AdminComponents {
  static Widget statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    String? trend,
    bool? trendUp,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navy.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              if (trend != null)
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (trendUp == true
                                  ? const Color(0xFF4CAF50)
                                  : Colors.red)
                              .withOpacity(0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trendUp == true
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 10,
                          color: trendUp == true
                              ? const Color(0xFF4CAF50)
                              : Colors.red,
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            trend,
                            style: AppTheme.inter(
                              size: 10,
                              color: trendUp == true
                                  ? const Color(0xFF4CAF50)
                                  : Colors.red,
                              weight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTheme.inter(
                size: 22,
                color: AppTheme.navy,
                weight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: AppTheme.inter(size: 11, color: AppTheme.grey),
            ),
          ),
        ],
      ),
    );
  }

  static Widget approvalCard({
    required String name,
    required String rollNo,
    required String role,
    required String time,
    required VoidCallback onTap,
  }) {
    final isRider = role.toLowerCase() == 'rider';
    final roleColor = isRider
        ? const Color(0xFF4CAF50)
        : const Color(0xFF64B5F6);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: roleColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.navy.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: roleColor.withOpacity(0.12),
              child: Icon(
                isRider
                    ? Icons.two_wheeler_rounded
                    : Icons.person_outline_rounded,
                color: roleColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTheme.inter(
                      size: 14,
                      color: AppTheme.navy,
                      weight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$rollNo • ${role.toUpperCase()}',
                    style: AppTheme.inter(
                      size: 11.5,
                      color: AppTheme.grey,
                      weight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.yellow.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Review',
                    style: AppTheme.inter(
                      size: 11,
                      color: AppTheme.navy,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: AppTheme.inter(size: 10, color: AppTheme.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget activityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.inter(
                    size: 13.5,
                    color: AppTheme.navy,
                    weight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTheme.inter(size: 12, color: AppTheme.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(time, style: AppTheme.inter(size: 11, color: AppTheme.grey)),
        ],
      ),
    );
  }

  static Widget quickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.20)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: AppTheme.inter(
                  size: 11.5,
                  color: AppTheme.navy,
                  weight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget userRow({
    required String name,
    required String role,
    required String rollNo,
    required bool isActive,
    required VoidCallback onBan,
  }) {
    final roleColor = role.toLowerCase() == 'rider'
        ? const Color(0xFF4CAF50)
        : const Color(0xFF64B5F6);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navy.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: roleColor.withOpacity(0.12),
            child: Icon(
              role.toLowerCase() == 'rider'
                  ? Icons.two_wheeler_rounded
                  : Icons.person,
              color: roleColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTheme.inter(
                    size: 14,
                    color: AppTheme.navy,
                    weight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$rollNo • $role',
                  style: AppTheme.inter(size: 11.5, color: AppTheme.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (isActive ? const Color(0xFF4CAF50) : Colors.red)
                  .withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isActive ? 'Active' : 'Banned',
              style: AppTheme.inter(
                size: 11,
                color: isActive ? const Color(0xFF4CAF50) : Colors.red,
                weight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onBan();
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive
                    ? Icons.block_rounded
                    : Icons.check_circle_outline_rounded,
                size: 18,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget reportedUserTile({
    required String reportedBy,
    required String reportedUser,
    required String reason,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$reportedUser was reported',
                  style: AppTheme.inter(
                    size: 14,
                    color: AppTheme.navy,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reason: $reason',
                  style: AppTheme.inter(
                    size: 12,
                    color: AppTheme.navy.withOpacity(0.8),
                    weight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reported by: $reportedBy',
                  style: AppTheme.inter(size: 11, color: AppTheme.grey),
                ),
              ],
            ),
          ),
          Text(time, style: AppTheme.inter(size: 11, color: AppTheme.grey)),
        ],
      ),
    );
  }
}