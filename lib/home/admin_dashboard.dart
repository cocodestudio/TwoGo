import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_components.dart';
import '../utils/api_config.dart';

class AdminDashboard extends StatefulWidget {
  final VoidCallback onOpenSidebar;
  const AdminDashboard({super.key, required this.onOpenSidebar});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryCtrl;
  int _activeSection = 0;
  final _sections = ['Overview', 'Approvals', 'Users'];

  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _userFilter = 'All';

  bool _isLoading = true;
  List<dynamic> _pendingApprovals = [];
  List<dynamic> _users = [];
  List<dynamic> _recentActivities = [];

  int _totalUsers = 0;
  int _totalRiders = 0;
  int _totalPax = 0;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text;
      });
    });
    _fetchAdminData();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchAdminData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.get(
        Uri.parse(ApiConfig.adminDashboardData),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _pendingApprovals = data['pending_approvals'] ?? [];
          _users = data['users'] ?? [];
          _recentActivities = data['recent_activities'] ?? [];

          _totalUsers = _users.length;
          _totalRiders = _users
              .where((u) => u['role'].toString().toLowerCase() == 'rider')
              .length;
          _totalPax = _users
              .where((u) => u['role'].toString().toLowerCase() == 'passenger')
              .length;
        });
      }
    } catch (e) {
      debugPrint("Admin Fetch Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleApproval(dynamic user, bool isApproved) async {
    Navigator.pop(context);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.post(
        Uri.parse(ApiConfig.reviewUser),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': user['id'],
          'status': isApproved ? 'approved' : 'rejected',
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _pendingApprovals.removeWhere((u) => u['id'] == user['id']);
          if (isApproved) {
            user['active'] = true;
            _users.insert(0, user);
            _totalUsers++;
            if (user['role'].toString().toLowerCase() == 'rider')
              _totalRiders++;
            if (user['role'].toString().toLowerCase() == 'passenger')
              _totalPax++;

            _recentActivities.insert(0, {
              'icon': Icons.verified_user_rounded.codePoint,
              'title': 'New ${user['role']} Verified',
              'subtitle': '${user['name']} joined the platform',
              'time': 'Just now',
              'color_hex': '0xFF4CAF50',
            });
          }
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isApproved
                  ? '${user['name']} approved successfully!'
                  : '${user['name']} request rejected.',
              style: AppTheme.inter(size: 13, color: Colors.white),
            ),
            backgroundColor: isApproved ? const Color(0xFF4CAF50) : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      debugPrint("Approval Error: $e");
    }
  }

  Future<void> _handleUserBan(dynamic user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final newStatus = !(user['active'] as bool);

      final response = await http.post(
        Uri.parse(ApiConfig.toggleUserStatus),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'user_id': user['id'], 'active': newStatus}),
      );

      if (response.statusCode == 200) {
        setState(() {
          user['active'] = newStatus;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus
                  ? '${user['name']} unbanned.'
                  : '${user['name']} banned.',
              style: AppTheme.inter(size: 13, color: Colors.white),
            ),
            backgroundColor: newStatus ? const Color(0xFF4CAF50) : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      debugPrint("Ban Error: $e");
    }
  }

  List<dynamic> get _filteredUsers {
    return _users.where((u) {
      final nameStr = u['name']?.toString().toLowerCase() ?? '';
      final rollStr = u['roll_number']?.toString().toLowerCase() ?? '';
      final roleStr = u['role']?.toString().toLowerCase() ?? '';

      final matchesSearch =
          nameStr.contains(_searchQuery.toLowerCase()) ||
          rollStr.contains(_searchQuery.toLowerCase());
      final matchesFilter =
          _userFilter == 'All' ||
          (_userFilter == 'Riders' && roleStr == 'rider') ||
          (_userFilter == 'Passengers' && roleStr == 'passenger');
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final pendingCount = _pendingApprovals.length;

    return Column(
      children: [
        Container(
          color: AppTheme.navy,
          padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: widget.onOpenSidebar,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Panel',
                          style: AppTheme.playfair(
                            size: 20,
                            color: Colors.white,
                            weight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Shobhit University — TwoGo',
                          style: AppTheme.inter(
                            size: 12,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      if (pendingCount > 0)
                        Positioned(
                          top: 6,
                          right: 8,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE53935),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: Row(
                  children: _sections.asMap().entries.map((e) {
                    final active = _activeSection == e.key;
                    final isPending = e.key == 1 && pendingCount > 0;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _activeSection = e.key);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? AppTheme.yellow
                              : Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              e.value,
                              style: AppTheme.inter(
                                size: 13.5,
                                color: active ? AppTheme.navy : Colors.white60,
                                weight: active
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            if (isPending) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE53935),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$pendingCount',
                                    style: AppTheme.inter(
                                      size: 10,
                                      color: Colors.white,
                                      weight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.navy),
                )
              : SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 16,
                    bottom: bottomPad + 20,
                  ),
                  child: _buildSection(),
                ),
        ),
      ],
    );
  }

  Widget _buildSection() {
    switch (_activeSection) {
      case 0:
        return _buildOverview();
      case 1:
        return _buildApprovals();
      case 2:
        return _buildUsers();
      default:
        return _buildOverview();
    }
  }

  Widget _buildOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FadeSlide(
          ctrl: _entryCtrl,
          delay: 0.0,
          child: GridView.count(
            padding: EdgeInsets.zero,
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.5,
            children: [
              AdminComponents.statCard(
                icon: Icons.people_rounded,
                label: 'Total Users',
                value: '$_totalUsers',
                color: const Color(0xFF64B5F6),
              ),
              AdminComponents.statCard(
                icon: Icons.two_wheeler_rounded,
                label: 'Total Riders',
                value: '$_totalRiders',
                color: const Color(0xFF4CAF50),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _FadeSlide(
          ctrl: _entryCtrl,
          delay: 0.15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Actions',
                style: AppTheme.inter(
                  size: 16,
                  color: AppTheme.navy,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              GridView.count(
                padding: EdgeInsets.zero,
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
                children: [
                  AdminComponents.quickAction(
                    icon: Icons.campaign_rounded,
                    label: 'Broadcast',
                    color: AppTheme.yellow,
                    onTap: () => _showBroadcastSheet(context),
                  ),
                  AdminComponents.quickAction(
                    icon: Icons.verified_user_rounded,
                    label: 'Approvals',
                    color: const Color(0xFF4CAF50),
                    onTap: () => setState(() => _activeSection = 1),
                  ),
                  AdminComponents.quickAction(
                    icon: Icons.people_rounded,
                    label: 'Users',
                    color: const Color(0xFF64B5F6),
                    onTap: () => setState(() => _activeSection = 2),
                  ),
                  AdminComponents.quickAction(
                    icon: Icons.price_change_rounded,
                    label: 'Pricing',
                    color: const Color(0xFFBA68C8),
                    onTap: () => _showPricingSheet(context),
                  ),
                  AdminComponents.quickAction(
                    icon: Icons.report_problem_rounded,
                    label: 'Reports',
                    color: Colors.orange,
                    onTap: () => _showReportsSheet(context),
                  ),
                  AdminComponents.quickAction(
                    icon: Icons.gavel_rounded,
                    label: 'Disputes',
                    color: Colors.red,
                    onTap: () => _showDisputesSheet(context),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _FadeSlide(
          ctrl: _entryCtrl,
          delay: 0.28,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Activity',
                style: AppTheme.inter(
                  size: 16,
                  color: AppTheme.navy,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.navy.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _recentActivities.isEmpty
                    ? Text(
                  "No recent activity found",
                  style: AppTheme.inter(size: 13, color: AppTheme.grey),
                )
                    : Column(
                  children: _recentActivities
                      .map(
                        (a) => AdminComponents.activityItem(
                      icon: Icons.notifications,
                      title: a['title'] ?? '',
                      subtitle: a['subtitle'] ?? '',
                      time: a['time'] ?? '',
                      color: Color(
                        int.parse(a['color_hex'] ?? '0xFF022B3A'),
                      ),
                    ),
                  )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApprovals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_pendingApprovals.isNotEmpty) ...[
          Text(
            'Action Required (${_pendingApprovals.length})',
            style: AppTheme.inter(
              size: 15,
              color: AppTheme.navy,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ..._pendingApprovals.map((user) {
            return AdminComponents.approvalCard(
              name: user['name'] ?? 'Unknown',
              rollNo: user['roll_number'] ?? 'N/A',
              role: user['role'] ?? 'user',
              time: user['created_at'] ?? 'Recently',
              onTap: () => _showApprovalDetailsSheet(context, user),
            );
          }),
        ] else
          _emptyState(
            icon: Icons.task_alt_rounded,
            message: 'All caught up! No pending requests.',
          ),
      ],
    );
  }

  Widget _buildUsers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppTheme.navy.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: AppTheme.grey, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  style: AppTheme.inter(size: 14, color: AppTheme.navy),
                  decoration: InputDecoration(
                    hintText: 'Search by name or roll no...',
                    hintStyle: AppTheme.inter(size: 14, color: AppTheme.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    FocusScope.of(context).unfocus();
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppTheme.grey,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _TargetChip(
                label: 'All ($_totalUsers)',
                selected: _userFilter == 'All',
                onTap: () => setState(() => _userFilter = 'All'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TargetChip(
                label: 'Riders ($_totalRiders)',
                selected: _userFilter == 'Riders',
                onTap: () => setState(() => _userFilter = 'Riders'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TargetChip(
                label: 'Pax ($_totalPax)',
                selected: _userFilter == 'Passengers',
                onTap: () => setState(() => _userFilter = 'Passengers'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ..._filteredUsers.map((u) {
          return AdminComponents.userRow(
            name: u['name'] ?? 'Unknown',
            role: u['role'] ?? 'User',
            rollNo: u['roll_number'] ?? 'N/A',
            isActive: u['active'] ?? false,
            onBan: () => _handleUserBan(u),
          );
        }),
      ],
    );
  }

  void _showApprovalDetailsSheet(BuildContext context, dynamic user) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isRider = user['role'].toString().toLowerCase() == 'rider';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPad + 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor:
                      (isRider
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF64B5F6))
                          .withOpacity(0.15),
                  child: Icon(
                    isRider
                        ? Icons.two_wheeler_rounded
                        : Icons.person_outline_rounded,
                    color: isRider
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF64B5F6),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'] ?? '',
                        style: AppTheme.playfair(
                          size: 24,
                          color: AppTheme.navy,
                          weight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${(user['role'] ?? '').toString().toUpperCase()} Request',
                        style: AppTheme.inter(
                          size: 13,
                          color: AppTheme.grey,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              'Registration Details',
              style: AppTheme.inter(
                size: 15,
                color: AppTheme.navy,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _DetailRow(label: 'Email', value: user['email'] ?? 'N/A'),
            _DetailRow(
              label: 'Roll Number',
              value: user['roll_number'] ?? 'N/A',
            ),
            _DetailRow(label: 'Gender', value: user['gender'] ?? 'N/A'),
            _DetailRow(label: 'Submitted', value: user['created_at'] ?? 'N/A'),
            const SizedBox(height: 24),
            Text(
              'ID Card Document',
              style: AppTheme.inter(
                size: 15,
                color: AppTheme.navy,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.navy.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.navy.withOpacity(0.1)),
                image: user['id_image_url'] != null
                    ? DecorationImage(
                        image: NetworkImage(user['id_image_url']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: user['id_image_url'] == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.badge_rounded,
                          size: 40,
                          color: AppTheme.navy.withOpacity(0.4),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No ID Document Provided',
                          style: AppTheme.inter(
                            size: 13,
                            color: AppTheme.navy,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _handleApproval(user, false),
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Center(
                        child: Text(
                          'Reject',
                          style: AppTheme.inter(
                            size: 15,
                            color: Colors.redAccent,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () => _handleApproval(user, true),
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Approve',
                          style: AppTheme.inter(
                            size: 15,
                            color: Colors.white,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReportsSheet(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPad + 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Reported Users',
              style: AppTheme.playfair(
                size: 22,
                color: AppTheme.navy,
                weight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            AdminComponents.reportedUserTile(
              reportedBy: 'Neha Gupta',
              reportedUser: 'Vikram Das',
              reason: 'Rash Driving on campus',
              time: '10m ago',
            ),
            AdminComponents.reportedUserTile(
              reportedBy: 'System',
              reportedUser: 'Arjun T.',
              reason: 'Suspicious ID Card upload',
              time: '2 hrs ago',
            ),
          ],
        ),
      ),
    );
  }

  void _showBroadcastSheet(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPad + 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Broadcast Notification',
                style: AppTheme.playfair(
                  size: 20,
                  color: AppTheme.navy,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Send message to all users or specific roles',
                style: AppTheme.inter(size: 13, color: AppTheme.grey),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Message title...',
                        hintStyle: AppTheme.inter(
                          size: 14,
                          color: AppTheme.grey,
                        ),
                        border: InputBorder.none,
                      ),
                      style: AppTheme.inter(
                        size: 14,
                        color: AppTheme.navy,
                        weight: FontWeight.w700,
                      ),
                    ),
                    Divider(color: AppTheme.grey.withOpacity(0.15), height: 1),
                    const SizedBox(height: 8),
                    TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Type your message here...',
                        hintStyle: AppTheme.inter(
                          size: 13,
                          color: AppTheme.grey,
                        ),
                        border: InputBorder.none,
                      ),
                      style: AppTheme.inter(size: 13, color: AppTheme.navy),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppTheme.navy,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.navy.withOpacity(0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Send Broadcast',
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
    );
  }

  void _showPricingSheet(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPad + 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Pricing Control',
              style: AppTheme.playfair(
                size: 20,
                color: AppTheme.navy,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _PriceTile(
              label: 'Pillion (Base)',
              price: '₹15',
              color: AppTheme.yellow,
            ),
            const SizedBox(height: 10),
            _PriceTile(
              label: 'Scooter (Base)',
              price: '₹25',
              color: const Color(0xFF64B5F6),
            ),
            const SizedBox(height: 10),
            _PriceTile(
              label: 'Express (Base)',
              price: '₹40',
              color: const Color(0xFFBA68C8),
            ),
          ],
        ),
      ),
    );
  }

  void _showDisputesSheet(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPad + 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Open Disputes',
              style: AppTheme.playfair(
                size: 20,
                color: AppTheme.navy,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            AdminComponents.reportedUserTile(
              reportedBy: 'Amit Singh',
              reportedUser: 'Priya M.',
              reason: 'Fare mismatch issue',
              time: '22 min ago',
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState({required IconData icon, required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.grey.withOpacity(0.4), size: 54),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTheme.inter(
              size: 15,
              color: AppTheme.grey,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTheme.inter(size: 13, color: AppTheme.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.inter(
                size: 14,
                color: AppTheme.navy,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TargetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppTheme.navy : AppTheme.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? AppTheme.navy : Colors.black.withOpacity(0.07),
        ),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: AppTheme.inter(
              size: 13,
              color: selected ? Colors.white : AppTheme.grey,
              weight: FontWeight.w700,
            ),
          ),
        ),
      ),
    ),
  );
}

class _PriceTile extends StatelessWidget {
  final String label, price;
  final Color color;
  const _PriceTile({
    required this.label,
    required this.price,
    required this.color,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: AppTheme.bg,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTheme.inter(
              size: 14,
              color: AppTheme.navy,
              weight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          price,
          style: AppTheme.inter(
            size: 15,
            color: AppTheme.navy,
            weight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _FadeSlide extends StatelessWidget {
  final AnimationController ctrl;
  final double delay;
  final Widget child;
  const _FadeSlide({
    required this.ctrl,
    required this.delay,
    required this.child,
  });
  @override
  Widget build(BuildContext context) {
    final end = (delay + 0.5).clamp(0.0, 1.0);
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: ctrl,
          curve: Interval(delay, end, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.07), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: ctrl,
                curve: Interval(delay, end, curve: Curves.easeOutCubic),
              ),
            ),
        child: child,
      ),
    );
  }
}
