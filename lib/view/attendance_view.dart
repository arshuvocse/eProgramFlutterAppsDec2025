import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_snackbar.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../viewmodel/attendance_viewmodel.dart';

class AttendanceView extends StatelessWidget {
  const AttendanceView({super.key});

  static const _brand = Color(0xFF0D47A1); // আপনার স্ক্রিনশটের মতো নীল
  static const _accent = Color(0xFF008080); // অ্যাপের teal

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AttendanceViewModel()..init(),
      child: Consumer<AttendanceViewModel>(
        builder: (context, vm, _) {
          if (vm.snackMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              AppSnackBar.show(context, vm.snackMessage!, tone: vm.snackTone);
              vm.consumeSnackMessage();
            });
          }
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              toolbarHeight: 70,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_accent, _brand],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              title: const Text(
                'Daily Attendance',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: vm.busy ? null : vm.refreshLocation,
                ),
              ],
            ),

            body: Column(
              children: [
                if (vm.statusVisible && vm.statusMessage != null)
                  _StatusBar(
                    message: vm.statusMessage!,
                    onClose: vm.hideStatusMessage,
                  ),
                // ====== Map ======
                SizedBox(
                  height: 280,
                  width: double.infinity,
                  child: vm.center == null
                      ? const Center(child: CircularProgressIndicator())
                      : GoogleMap(
                    markers: vm.markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                    initialCameraPosition: CameraPosition(
                      target: vm.center!,
                      zoom: 16,
                    ),
                    onMapCreated: vm.onMapCreated,
                  ),
                ),

                // ====== Bottom Card ======
                Expanded(
                  child: SafeArea(
                    top: false,
                    bottom: true,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            color: Color(0x1A000000),
                            offset: Offset(0, -3),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date & Time row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _yyyyMmDd(DateTime.now()),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _hhMmAmPm(DateTime.now()),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: _brand,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            TextField(
                              onChanged: vm.setRemarks,
                              decoration: const InputDecoration(
                                hintText: 'Enter Remarks Here',
                                contentPadding:
                                EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black38),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: _brand, width: 2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            if (vm.punchedIn && vm.punchedAt != null)
                              Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Colors.green),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Punch In done at ${_hhMmAmPm(vm.punchedAt!)}',
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            if (vm.punchedOut && vm.punchedOutAt != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.green),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Punch Out done at ${_hhMmAmPm(vm.punchedOutAt!)}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 24),

                            // Button or completion card
                            if (vm.punchedIn && vm.punchedOut)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.check_circle, color: Colors.green),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Punch In/Out done',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                              child: ElevatedButton(
                                onPressed: vm.busy
                                    ? null
                                    : () async {
                                        if (!vm.punchedIn) {
                                          await vm.punchIn();
                                        } else if (!vm.punchedOut) {
                                          await vm.punchOut();
                                        }
                                      },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _brand,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: vm.busy
                                      ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                      : Text(
                                          !vm.punchedIn
                                              ? 'PUNCH IN'
                                              : (!vm.punchedOut ? 'PUNCH OUT' : 'PUNCHED OUT'),
                                          style: const TextStyle(
                                            letterSpacing: 0.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _yyyyMmDd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _hhMmAmPm(DateTime d) {
    int h = d.hour;
    final m = d.minute.toString().padLeft(2, '0');
    final am = h < 12 ? 'AM' : 'PM';
    if (h == 0) h = 12;
    if (h > 12) h -= 12;
    return '${h.toString().padLeft(2, '0')}:$m $am';
  }
}

class _StatusBar extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  const _StatusBar({
    required this.message,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_off, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF8A6D3B),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.close, size: 18, color: Colors.orange),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
