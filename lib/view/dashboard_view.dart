
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:e_program_apps/view/approval_view.dart';
import 'package:e_program_apps/view/reports_view.dart';
import 'package:e_program_apps/view/settings_view.dart';
import 'package:e_program_apps/view/attendance_view.dart'; // path অনুযায়ী দিন
import 'package:e_program_apps/view/tour_plan_view.dart';
import 'package:e_program_apps/view/providers_list_view.dart';
import 'package:e_program_apps/view/checklist_response_view.dart';
import 'package:e_program_apps/view/training_view.dart';
import 'package:e_program_apps/view/stock_list_view.dart';

const _dashboardPrimary = Color(0xFF008080);
const _dashboardSecondary = Color(0xFF0A2540);
const _dashboardBg = Color(0xFFF5F7FB);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String? _locationStatusMessage;
  bool _showLocationBanner = false;
  Timer? _locationBannerTimer;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ApprovalScreen(),
    const ReportsView(),
    const SettingsView(),
  ];

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  Future<void> _checkLocationStatus() async {
    final status = await Geolocator.isLocationServiceEnabled();
    setState(() {
      if (!status) {
        _showLocationStatus('Your location is off. Please turn it on for accurate attendance.');
      } else {
        _hideLocationStatus();
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _locationBannerTimer?.cancel();
    super.dispose();
  }

  void _showLocationStatus(String message) {
    _locationBannerTimer?.cancel();
    setState(() {
      _locationStatusMessage = message;
      _showLocationBanner = true;
    });
    _locationBannerTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showLocationBanner = false;
          _locationStatusMessage = null;
        });
      }
    });
  }

  void _hideLocationStatus() {
    _locationBannerTimer?.cancel();
    if (!_showLocationBanner && _locationStatusMessage == null) return;
    setState(() {
      _showLocationBanner = false;
      _locationStatusMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OfflineBuilder(
      connectivityBuilder: (BuildContext context,
          List<ConnectivityResult> connectivity, Widget child) {
        final bool connected = connectivity.contains(ConnectivityResult.mobile) ||
            connectivity.contains(ConnectivityResult.wifi);
        return Scaffold(
          backgroundColor: _dashboardBg,
          appBar: AppBar(
            elevation: 0,
            toolbarHeight: 70,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_dashboardSecondary, _dashboardPrimary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: Text(
              _getAppBarTitle(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            leading: _selectedIndex != 0
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                  )
                : null,
            bottom: !connected || _showLocationBanner
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(40.0),
                    child: Column(
                      children: [
                        if (!connected)
                          Container(
                            color: Colors.amber,
                            width: double.infinity,
                            padding: const EdgeInsets.all(8.0),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.warning, color: Colors.black, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'No internet connection. Please check your network.',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        if (_showLocationBanner && _locationStatusMessage != null)
                          GestureDetector(
                            onTap: () async {
                              await Geolocator.openLocationSettings();
                            },
                            child: Container(
                              color: Colors.red.shade400,
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.location_off, color: Colors.white, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _locationStatusMessage!,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.close, color: Colors.white, size: 18),
                                    onPressed: _hideLocationStatus,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : null,
          ),
          body: _screens[_selectedIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: const Color.fromRGBO(0, 0, 0, 0.1),
                )
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                child: GNav(
                  rippleColor: Colors.grey[300]!,
                  hoverColor: Colors.grey[100]!,
                  gap: 8,
                  activeColor: Colors.white,
                  iconSize: 24,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  duration: const Duration(milliseconds: 400),
                  tabBackgroundColor: const Color(0xFF008080),
                  color: Colors.black,
                  tabs: const [
                    GButton(
                      icon: Icons.home,
                      text: 'Home',
                    ),
                    GButton(
                      icon: Icons.approval,
                      text: 'Approval',
                    ),
                    GButton(
                      icon: Icons.bar_chart,
                      text: 'Reports',
                    ),
                    GButton(
                      icon: Icons.settings,
                      text: 'Settings',
                    ),
                  ],
                  selectedIndex: _selectedIndex,
                  onTabChange: _onItemTapped,
                ),
              ),
            ),
          ),
        );
      },
      child: const Center(child: Text('No internet connection')),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Approval List';
      case 2:
        return 'Reports';
      case 3:
        return 'Settings';
      default:
        return 'Dashboard';
    }
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(
        title: 'Attendance',
        icon: Icons.calendar_today,
        onTap: (context) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AttendanceView()),
          );
        },
      ),
      _ActionItem(
        title: 'Provider List',
        icon: Icons.people_outline,
        onTap: (context) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProvidersListView()),
          );
        },
      ),
      _ActionItem(
        title: 'Tour Plan',
        icon: Icons.location_on_outlined,
        onTap: (context) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TourPlanView()),
          );
        },
      ),
      _ActionItem(
        title: 'Checklist',
        icon: Icons.playlist_add_check,
        onTap: (context) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProvidersListView()),
          );
        },
      ),
      _ActionItem(
        title: 'Checklist Response',
        icon: Icons.fact_check_outlined,
        onTap: (context) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ChecklistResponseView()),
          );
        },
      ),
      _ActionItem(
        title: 'Training',
        icon: Icons.model_training,
        onTap: (context) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TrainingView()),
          );
        },
      ),
      _ActionItem(
        title: 'Stock List',
        icon: Icons.inventory_2_outlined,
        onTap: (context) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const StockListView()),
          );
        },
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_dashboardSecondary, _dashboardPrimary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: _AttendanceButton(
                    onTap: () {},
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Snapshot",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _dashboardSecondary,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: const [
                          Expanded(
                            child: _StatCard(
                              label: 'Punch In',
                              value: '08:35 AM',
                              icon: Icons.login_rounded,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Working Hrs',
                              value: '08h 15m',
                              icon: Icons.timer,
                              color: Color(0xFF673AB7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: const [
                          Expanded(
                            child: _StatCard(
                              label: 'Meetings',
                              value: '03',
                              icon: Icons.handshake,
                              color: Color(0xFFFF9800),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Pending Tasks',
                              value: '05',
                              icon: Icons.assignment_late,
                              color: Color(0xFFE53935),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _dashboardSecondary,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _QuickActionGrid(actions: actions),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _AttendanceButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AttendanceButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              colors: [Color(0xFF0BAF9A), _dashboardPrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _dashboardPrimary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'MMS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: onTap,
                            splashRadius: 22,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.refresh, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            _buildMmsRow('Total Provider', '1'),
                            _buildMmsRow('Visited Provider', '0'),
                            _buildMmsRow('Self Visited Provider', '0'),
                            _buildMmsRow('Self Visit Count', '0', showDivider: false),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMmsRow(String label, String value, {bool showDivider = true}) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: const TextStyle(
                color: _dashboardSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: _dashboardSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (!showDivider) return row;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row,
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey.shade300,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _dashboardSecondary,
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

class _QuickActionGrid extends StatelessWidget {
  final List<_ActionItem> actions;

  const _QuickActionGrid({required this.actions});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 500 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 150,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];
            return _QuickActionTile(action: action);
          },
        );
      },
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final _ActionItem action;

  const _QuickActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F8FF),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: action.onTap != null ? () => action.onTap!(context) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
              decoration: BoxDecoration(
                  color: _dashboardPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  action.icon,
                  color: _dashboardPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                action.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  height: 1.2,
                  color: _dashboardSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionItem {
  final String title;
  final IconData icon;
  final void Function(BuildContext context)? onTap;

  const _ActionItem({
    required this.title,
    required this.icon,
    this.onTap,
  });
}
