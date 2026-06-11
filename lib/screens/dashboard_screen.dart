import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/admin_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../main.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AdminService adminService = AdminService();
  final AuthService authService = AuthService();

  List allPlaces = [];
  List filteredPlaces = [];
  bool isLoading = true;
  String selectedStatus = '';
  String searchQuery = '';

  // Track loading state for each action (approve/reject)
  final Map<String, bool> _processingIds = {};

  @override
  void initState() {
    super.initState();
    fetchPlaces();
  }

  Future<void> fetchPlaces() async {
    setState(() => isLoading = true);
    try {
      final result = await adminService.getPlaces(selectedStatus);
      setState(() {
        allPlaces = result;
        _applySearch();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil data: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _applySearch() {
    setState(() {
      if (searchQuery.isEmpty) {
        filteredPlaces = List.from(allPlaces);
      } else {
        filteredPlaces = allPlaces
            .where(
              (place) => (place['name'] ?? '').toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  Map<String, int> get _summary {
    int total = allPlaces.length;
    int pending = allPlaces.where((p) => p['status'] == 'pending').length;
    int approved = allPlaces.where((p) => p['status'] == 'approved').length;
    int rejected = allPlaces.where((p) => p['status'] == 'rejected').length;

    return {
      'Total': total,
      'Pending': pending,
      'Approved': approved,
      'Rejected': rejected,
    };
  }

  Future<void> _handleAction(String id, String action, {String? reason}) async {
    setState(() => _processingIds[id] = true);

    bool success = false;
    if (action == 'approve') {
      success = await adminService.approvePlace(id);
    } else if (action == 'reject') {
      success = await adminService.rejectPlace(id, reason ?? 'Tidak sesuai');
    }

    if (mounted) {
      setState(() => _processingIds[id] = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil $action place'),
            backgroundColor: MyApp.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        fetchPlaces();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal $action place'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  /// Menampilkan dialog konfirmasi logout
  Future<void> _showLogoutDialog() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Logout',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: MyApp.darkText,
            fontSize: 20,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin logout?',
          style: GoogleFonts.inter(
            color: MyApp.darkText.withOpacity(0.7),
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.inter(
                color: MyApp.darkText.withOpacity(0.6),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );

    // Jika user memilih logout dan widget masih mounted
    if (shouldLogout == true && mounted) {
      await _handleLogout();
    }
  }

  /// Menangani proses logout
  Future<void> _handleLogout() async {
    try {
      // Panggil method logout dari AuthService
      await authService.logout();

      // Navigasi ke LoginScreen dan hapus seluruh stack
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal logout: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: MyApp.creamWhite,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Hello, ',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: MyApp.darkText.withOpacity(0.8),
                ),
              ),
              TextSpan(
                text: 'Admin!',
                style: GoogleFonts.caveat(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: MyApp.primaryBlue,
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: MyApp.darkText,
        actions: [
          IconButton(
            onPressed: fetchPlaces,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: MyApp.lightGray, width: 1),
              ),
              child: Icon(
                Icons.refresh_rounded,
                size: 20,
                color: MyApp.darkText.withOpacity(0.7),
              ),
            ),
            tooltip: 'Reload Data',
          ),
          IconButton(
            onPressed: _showLogoutDialog,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: MyApp.lightGray, width: 1),
              ),
              child: Icon(
                Icons.logout_outlined,
                size: 20,
                color: MyApp.darkText.withOpacity(0.7),
              ),
            ),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchPlaces,
        color: MyApp.primaryBlue,
        backgroundColor: Colors.white,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // Summary Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryGrid(isDesktop),
                          const SizedBox(height: 24),
                          // Management Buttons
                          LayoutBuilder(
                            builder: (context, constraints) {
                              // If width is small, use Column, else Row
                              if (constraints.maxWidth <= 600) {
                                return Column(
                                  children: [
                                    _buildManagementButton(
                                      icon: Icons.category_outlined,
                                      label: 'Kelola Kategori',
                                      color: MyApp.primaryBlue,
                                      onTap: () {
                                        Navigator.pushNamed(context, '/categories');
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    _buildManagementButton(
                                      icon: Icons.sell_outlined,
                                      label: 'Kelola Tag',
                                      color: MyApp.favoriteAccent,
                                      onTap: () {
                                        Navigator.pushNamed(context, '/tags');
                                      },
                                    ),
                                  ],
                                );
                              } else {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: _buildManagementButton(
                                        icon: Icons.category_outlined,
                                        label: 'Kelola Kategori',
                                        color: MyApp.primaryBlue,
                                        onTap: () {
                                          Navigator.pushNamed(context, '/categories');
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildManagementButton(
                                        icon: Icons.sell_outlined,
                                        label: 'Kelola Tag',
                                        color: MyApp.favoriteAccent,
                                        onTap: () {
                                          Navigator.pushNamed(context, '/tags');
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 28),
                          // Search and Filter Section Title
                          Text(
                            'Coffee Shops',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: MyApp.darkText,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildSearchFilterBar(isDesktop),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),

                  // Places List
                  filteredPlaces.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final place = filteredPlaces[index];
                                return _PlaceCard(
                                  place: place,
                                  isProcessing:
                                      _processingIds[place['id']] ?? false,
                                  onApprove: () =>
                                      _handleAction(place['id'], 'approve'),
                                  onReject: () =>
                                      _handleAction(place['id'], 'reject'),
                                );
                              },
                              childCount: filteredPlaces.length,
                            ),
                          ),
                        ),
                ],
              ),
      ),
    );
  }

  Widget _buildSummaryGrid(bool isDesktop) {
    final summary = _summary;
    final List<Map<String, dynamic>> items = [
      {
        'title': 'Total Places',
        'value': summary['Total'].toString(),
        'icon': Icons.storefront_outlined,
        'color': MyApp.primaryBlue,
      },
      {
        'title': 'Pending',
        'value': summary['Pending'].toString(),
        'icon': Icons.pending_actions_outlined,
        'color': MyApp.favoriteAccent,
      },
      {
        'title': 'Approved',
        'value': summary['Approved'].toString(),
        'icon': Icons.check_circle_outline,
        'color': MyApp.success,
      },
      {
        'title': 'Rejected',
        'value': summary['Rejected'].toString(),
        'icon': Icons.highlight_off_outlined,
        'color': Colors.red,
      },
    ];

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: isDesktop ? 2.2 : 1.5,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: MyApp.lightGray, width: 1),
            boxShadow: [
              BoxShadow(
                color: MyApp.darkText.withOpacity(0.02),
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item['icon'],
                      color: item['color'],
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    item['value'],
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: MyApp.darkText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item['title'],
                style: GoogleFonts.inter(
                  color: MyApp.darkText.withOpacity(0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchFilterBar(bool isDesktop) {
    return Column(
      children: [
        TextField(
          style: GoogleFonts.inter(
            color: MyApp.darkText,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Cari nama cafe...',
            hintStyle: GoogleFonts.inter(
              color: MyApp.darkText.withOpacity(0.4),
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(
              Icons.search_outlined,
              size: 22,
              color: MyApp.darkText.withOpacity(0.4),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: MyApp.lightGray, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: MyApp.lightGray, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: MyApp.primaryBlue, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
          ),
          onChanged: (value) {
            searchQuery = value;
            _applySearch();
          },
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: MyApp.lightGray,
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedStatus,
              isExpanded: true,
              icon: Icon(
                Icons.filter_list_rounded,
                size: 20,
                color: MyApp.darkText.withOpacity(0.4),
              ),
              style: GoogleFonts.inter(
                color: MyApp.darkText,
                fontWeight: FontWeight.w600,
              ),
              items: const [
                DropdownMenuItem(
                  value: '',
                  child: Text('Semua Status'),
                ),
                DropdownMenuItem(
                  value: 'pending',
                  child: Text('Pending'),
                ),
                DropdownMenuItem(
                  value: 'approved',
                  child: Text('Approved'),
                ),
                DropdownMenuItem(
                  value: 'rejected',
                  child: Text('Rejected'),
                ),
                DropdownMenuItem(
                  value: 'archived',
                  child: Text('Archived'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedStatus = value ?? '';
                });
                fetchPlaces();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: MyApp.lightGray.withOpacity(0.5),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 56,
                color: MyApp.darkText.withOpacity(0.25),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak ada data ditemukan',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: MyApp.darkText.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Coba ubah filter atau kata kunci pencarian Anda',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: MyApp.darkText.withOpacity(0.4),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 18,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: MyApp.lightGray,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: MyApp.darkText.withOpacity(0.03),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: MyApp.darkText,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final Map<String, dynamic> place;
  final bool isProcessing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PlaceCard({
    required this.place,
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final status = (place['status'] ?? 'pending').toString().toLowerCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MyApp.lightGray,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MyApp.darkText.withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place['name'] ?? 'Unnamed Cafe',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: MyApp.darkText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: MyApp.darkText.withOpacity(0.4),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            place['address'] ?? 'No address provided',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: MyApp.darkText.withOpacity(0.55),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                flex: 0,
                child: _StatusBadge(status: status),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(
            height: 1,
            color: MyApp.lightGray,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              // Show Reject button if not already rejected
              if (status != 'rejected')
                TextButton.icon(
                  onPressed: isProcessing ? null : onReject,
                  icon: isProcessing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.red,
                          ),
                        )
                      : const Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: Colors.red,
                        ),
                  label: Text(
                    'Reject',
                    style: GoogleFonts.inter(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                ),
              // Show Approve button if not already approved
              if (status != 'approved')
                ElevatedButton.icon(
                  onPressed: isProcessing ? null : onApprove,
                  icon: isProcessing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.check_rounded,
                          size: 20,
                        ),
                  label: Text(
                    'Approve',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyApp.success,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              if (status == 'approved' && status == 'rejected')
                Text(
                  'No further actions',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: MyApp.darkText.withOpacity(0.35),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'approved':
        color = MyApp.success;
        break;
      case 'pending':
        color = MyApp.favoriteAccent;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      case 'archived':
        color = Colors.grey;
        break;
      default:
        color = Colors.blueGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.inter(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
