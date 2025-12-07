
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../data/database_helper.dart';
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

  void _showLocationAccuracyDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'For a better experience, your device will need to use Location Accuracy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _LocationRequirementRow(
                  icon: Icons.location_on_outlined,
                  title: 'Device location',
                  subtitle: 'Turn on location services for accurate attendance.',
                ),
                const SizedBox(height: 10),
                const _LocationRequirementRow(
                  icon: Icons.my_location_outlined,
                  title: 'Location accuracy',
                  subtitle:
                      'Allow high accuracy so the app can use GPS and nearby signals to verify your location.',
                ),
                const SizedBox(height: 16),
                const Text(
                  'You can change this at any time in location settings.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('No thanks'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _dashboardSecondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();
                        await Geolocator.openLocationSettings();
                      },
                      child: const Text('Turn on'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
                            onTap: _showLocationAccuracyDialog,
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<_DashboardTile> _tiles = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _tilesLoading = true;
  String? _tilesError;
  DateTime? _lastSnapshotUpdatedAt;
  bool _usingCachedSnapshot = false;

  @override
  void initState() {
    super.initState();
    _loadTiles();
  }

  Future<_CachedSnapshot> _loadCachedSnapshot({bool setStateIfMounted = true}) async {
    try {
      final cached = await _dbHelper.getCachedDashboardTiles();
      final tiles = cached.map(_DashboardTile.fromDb).toList();
      DateTime? updatedAt;
      if (cached.isNotEmpty) {
        final raw = cached.first['updated_at']?.toString();
        if (raw != null && raw.isNotEmpty) {
          updatedAt = DateTime.tryParse(raw);
        }
      }
      if (setStateIfMounted && tiles.isNotEmpty && mounted) {
        setState(() {
          _tiles
            ..clear()
            ..addAll(tiles);
          _tilesLoading = false;
          _lastSnapshotUpdatedAt = updatedAt;
          _usingCachedSnapshot = true;
        });
      }
      return _CachedSnapshot(tiles: tiles, updatedAt: updatedAt);
    } catch (e) {
      debugPrint('[Dashboard] cached tiles load failed: $e');
      return const _CachedSnapshot(tiles: [], updatedAt: null);
    }
  }

  Future<void> _loadTiles() async {
    debugPrint('[Dashboard] _loadTiles() start');

    final cachedSnapshot = await _loadCachedSnapshot();

    try {
      final connectivity = await Connectivity().checkConnectivity();
      final connected = connectivity.contains(ConnectivityResult.mobile) ||
          connectivity.contains(ConnectivityResult.wifi) ||
          connectivity.contains(ConnectivityResult.ethernet);
      debugPrint('[Dashboard] connectivity: $connectivity (connected=$connected)');

      if (!connected) {
        if (!mounted) return;
        if (cachedSnapshot.tiles.isNotEmpty) {
          debugPrint('[Dashboard] offline -> showing cached tiles');
          setState(() {
            _tilesError = _offlineSnapshotMessage(cachedSnapshot.updatedAt);
            _tilesLoading = false;
            _usingCachedSnapshot = true;
            _lastSnapshotUpdatedAt = cachedSnapshot.updatedAt ?? _lastSnapshotUpdatedAt;
          });
        } else {
          debugPrint('[Dashboard] offline -> no cached tiles');
          setState(() {
            _tilesLoading = false;
            _tilesError = 'No saved snapshot available offline.';
            _usingCachedSnapshot = false;
            _lastSnapshotUpdatedAt = null;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _tilesLoading = cachedSnapshot.tiles.isEmpty;
          _tilesError = null;
          // keep showing cached tiles while fetching online data
        });
      }

      final empInfoId = await _dbHelper.getEmpInfoId();
      if (empInfoId == null || empInfoId <= 0) {
        if (!mounted) return;
        if (cachedSnapshot.tiles.isNotEmpty) {
          debugPrint('[Dashboard] no empInfoId -> showing cached tiles');
          setState(() {
            _tilesLoading = false;
            _tilesError = 'Showing last saved snapshot (no user found).';
            _usingCachedSnapshot = true;
            _lastSnapshotUpdatedAt = cachedSnapshot.updatedAt ?? _lastSnapshotUpdatedAt;
          });
        } else {
          debugPrint('[Dashboard] no empInfoId and no cached tiles');
          setState(() {
            _tilesError = 'No employee info found. Please login again.';
            _tilesLoading = false;
            _usingCachedSnapshot = false;
            _lastSnapshotUpdatedAt = null;
          });
        }
        return;
      }

      final uri = Uri.parse(ApiConfig.dashboardTiles).replace(
        queryParameters: {'empInfoId': empInfoId.toString()},
      );

      final res = await http.get(uri).timeout(const Duration(seconds: 20));
      debugPrint('Dashboard tiles -> ${res.statusCode} ${res.body}');
      if (res.statusCode != 200) {
        throw Exception('Status ${res.statusCode}');
      }

      final decoded = jsonDecode(res.body);
      if (decoded is! List) {
        throw Exception('Unexpected response from server.');
      }

      final parsed = decoded
          .whereType<Map<String, dynamic>>()
          .map(_DashboardTile.fromJson)
          .toList();

      await _dbHelper.cacheDashboardTiles(
        parsed.map((e) => e.toDbMap()).toList(),
      );
      final now = DateTime.now();
      debugPrint('[Dashboard] cached ${parsed.length} tiles from API');

      if (!mounted) return;
      setState(() {
        _tiles
          ..clear()
          ..addAll(parsed);
        _tilesLoading = false;
        _tilesError = null;
        _lastSnapshotUpdatedAt = now;
        _usingCachedSnapshot = false;
      });
    } catch (e, st) {
      debugPrint('[Dashboard] error loading tiles: $e');
      debugPrint('$st');
      if (!mounted) return;
      if (cachedSnapshot.tiles.isNotEmpty) {
        debugPrint('[Dashboard] error -> showing cached tiles');
        setState(() {
          _tiles
            ..clear()
            ..addAll(cachedSnapshot.tiles);
          _tilesLoading = false;
          _tilesError = _offlineSnapshotMessage(cachedSnapshot.updatedAt);
          _usingCachedSnapshot = true;
          _lastSnapshotUpdatedAt = cachedSnapshot.updatedAt ?? _lastSnapshotUpdatedAt;
        });
      } else {
        debugPrint('[Dashboard] error and no cached tiles');
        setState(() {
          _tilesError = 'Unable to load snapshot. Please try again.';
          _tilesLoading = false;
          _usingCachedSnapshot = false;
          _lastSnapshotUpdatedAt = null;
        });
      }
    }
  }

  String _offlineSnapshotMessage(DateTime? updatedAt) {
    if (updatedAt == null) return 'Saved snapshot (offline).';
    return 'Saved snapshot from ${_formatTimestamp(updatedAt)} (offline).';
  }

  @override
  Widget build(BuildContext context) {
    final lastUpdatedLabel = _lastSnapshotUpdatedAt != null
        ? 'Last updated: ${_formatTimestamp(_lastSnapshotUpdatedAt!)}${_usingCachedSnapshot ? ' (saved)' : ''}'
        : null;
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
                child: RefreshIndicator(
                  color: _dashboardPrimary,
                  onRefresh: _loadTiles,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Today's Snapshot",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: _dashboardSecondary,
                                  ),
                            ),
                            const Spacer(),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.refresh),
                              color: _dashboardSecondary,
                              onPressed: _tilesLoading ? null : _loadTiles,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _SnapshotGrid(
                          tiles: _tiles,
                          loading: _tilesLoading,
                          error: _tilesError,
                          onRetry: _loadTiles,
                          lastUpdatedLabel: lastUpdatedLabel,
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
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: _buildStatGradient(color),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _shiftColor(color, -0.12).withOpacity(0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.22),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _shiftColor(color, 0.18),
                  _shiftColor(color, -0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: _dashboardSecondary.withOpacity(0.85),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: _dashboardSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapshotGrid extends StatelessWidget {
  final List<_DashboardTile> tiles;
  final bool loading;
  final String? error;
  final Future<void> Function() onRetry;
  final String? lastUpdatedLabel;

  const _SnapshotGrid({
    required this.tiles,
    required this.loading,
    required this.error,
    required this.onRetry,
    this.lastUpdatedLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: const [
            _SkeletonCard(width: 220),
            SizedBox(width: 12),
            _SkeletonCard(width: 220),
            SizedBox(width: 12),
            _SkeletonCard(width: 220),
          ],
        ),
      );
    }

    final children = <Widget>[];

    if (error != null) {
      children.add(
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_outlined, color: Colors.orange),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  error!,
                  style: const TextStyle(
                    color: Color(0xFF8A6D3B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (tiles.isEmpty) {
      children.add(const Text('No snapshot available right now.'));
    } else {
      children.add(
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: tiles
                .map((t) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 220,
                        child: _StatCard(
                          label: t.fieldName,
                          value: t.displayValue,
                          icon: t.icon,
                          color: t.color,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      );
    }

    if (lastUpdatedLabel != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            lastUpdatedLabel!,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double? width;
  const _SkeletonCard({this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 16,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
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

class _DashboardTile {
  final String fieldName;
  final String fieldBgColor;
  final String fieldIconCode;
  final int fieldCount;
  final String fieldValue;

  const _DashboardTile({
    required this.fieldName,
    required this.fieldBgColor,
    required this.fieldIconCode,
    required this.fieldCount,
    required this.fieldValue,
  });

  factory _DashboardTile.fromJson(Map<String, dynamic> json) {
    return _DashboardTile(
      fieldName: (json['fieldName'] ?? '').toString(),
      fieldBgColor: (json['fieldBgColor'] ?? '').toString(),
      fieldIconCode: (json['fieldIcon'] ?? '').toString(),
      fieldCount: json['fieldCount'] is int
          ? json['fieldCount'] as int
          : int.tryParse('${json['fieldCount']}') ?? 0,
      fieldValue: (json['fieldValue'] ?? '').toString(),
    );
  }

  factory _DashboardTile.fromDb(Map<String, dynamic> map) {
    return _DashboardTile(
      fieldName: (map['field_name'] ?? map['fieldName'] ?? '').toString(),
      fieldBgColor: (map['field_bg_color'] ?? map['fieldBgColor'] ?? '').toString(),
      fieldIconCode: (map['field_icon'] ?? map['fieldIcon'] ?? '').toString(),
      fieldCount: map['field_count'] is int
          ? map['field_count'] as int
          : int.tryParse('${map['field_count'] ?? map['fieldCount'] ?? 0}') ?? 0,
      fieldValue: (map['field_value'] ?? map['fieldValue'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'field_name': fieldName,
      'field_bg_color': fieldBgColor,
      'field_icon': fieldIconCode,
      'field_count': fieldCount,
      'field_value': fieldValue,
    };
  }

  Color get color => _parseColor(fieldBgColor) ?? _dashboardPrimary;

  IconData get icon => _iconFromApi(fieldIconCode);

  String get displayValue {
    if (fieldValue.trim().isNotEmpty) return fieldValue;
    return fieldCount.toString();
  }
}

class _CachedSnapshot {
  final List<_DashboardTile> tiles;
  final DateTime? updatedAt;

  const _CachedSnapshot({
    required this.tiles,
    required this.updatedAt,
  });
}

Color? _parseColor(String hex) {
  var value = hex.replaceAll('#', '').trim();
  if (value.length == 6) value = 'FF$value';
  try {
    final intVal = int.parse(value, radix: 16);
    return Color(intVal);
  } catch (_) {
    return null;
  }
}

IconData _iconFromApi(String iconCode) {
  switch (iconCode) {
    case 'ri-login-box-line':
      return Icons.login_rounded;
    case 'ri-logout-box-line':
      return Icons.logout_rounded;
    case 'ri-time-line':
      return Icons.timer;
    case 'ri-group-line':
      return Icons.groups_2_outlined;
    case 'ri-user-smile-line':
      return Icons.sentiment_satisfied_alt_outlined;
    case 'ri-task-line':
      return Icons.task_alt;
    case 'ri-book-2-line':
      return Icons.menu_book_outlined;
    case 'ri-road-map-line':
      return Icons.alt_route;
    default:
      return Icons.dashboard_customize_outlined;
  }
}

LinearGradient _buildStatGradient(Color base) {
  return LinearGradient(
    colors: [
      _shiftColor(base, 0.22).withOpacity(0.95),
      _shiftColor(base, -0.06).withOpacity(0.9),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

Color _shiftColor(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  final shifted = hsl.withLightness(
    (hsl.lightness + amount).clamp(0.0, 1.0),
  );
  return shifted.toColor();
}

String _formatTimestamp(DateTime dateTime) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  final local = dateTime.toLocal();
  final datePart = '${local.day.toString().padLeft(2, '0')} ${months[local.month - 1]} ${local.year}';
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';
  return '$datePart $hour:$minute $period';
}

class _QuickActionGrid extends StatelessWidget {
  final List<_ActionItem> actions;

  const _QuickActionGrid({required this.actions});

  static const _cardAccents = [
    Color(0xFF00A8E8),
    Color(0xFF7B61FF),
    Color(0xFF0EB29A),
    Color(0xFFEF476F),
    Color(0xFFEE9B00),
  ];

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
            final accent = _cardAccents[index % _cardAccents.length];
            return _QuickActionTile(action: action, accent: accent);
          },
        );
      },
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final _ActionItem action;
  final Color accent;

  const _QuickActionTile({required this.action, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: action.onTap != null ? () => action.onTap!(context) : null,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accent.withOpacity(0.10),
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withOpacity(0.20), width: 1),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.14),
                blurRadius: 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(action.icon, color: accent),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_outward_rounded, size: 18, color: accent.withOpacity(0.8)),
                ],
              ),
              const Spacer(),
              Text(
                action.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  height: 1.25,
                  color: _dashboardSecondary,
                  letterSpacing: 0.2,
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

class _LocationRequirementRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _LocationRequirementRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _dashboardPrimary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _dashboardPrimary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _dashboardSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
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
