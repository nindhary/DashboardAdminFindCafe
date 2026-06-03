import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AdminService adminService = AdminService();

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
          SnackBar(content: Text('Gagal mengambil data: $e')),
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
            .where((place) => (place['name'] ?? '')
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
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
          SnackBar(content: Text('Berhasil $action place')),
        );
        fetchPlaces();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal $action place')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
      appBar: AppBar(
        title: const Text(
          'FindCafe Admin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        actions: [
          IconButton(
            onPressed: fetchPlaces,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload Data',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchPlaces,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // Summary Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildSummaryGrid(isDesktop),
                    ),
                  ),

                  // Search and Filter Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildSearchFilterBar(isDesktop),
                    ),
                  ),

                  // Places List
                  filteredPlaces.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.all(16.0),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final place = filteredPlaces[index];
                                return _PlaceCard(
                                  place: place,
                                  isProcessing: _processingIds[place['id']] ?? false,
                                  onApprove: () => _handleAction(place['id'], 'approve'),
                                  onReject: () => _handleAction(place['id'], 'reject'),
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
    return GridView.count(
      crossAxisCount: isDesktop ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: isDesktop ? 2.5 : 1.6,
      children: [
        _SummaryCard(
          title: 'Total Places',
          value: summary['Total'].toString(),
          icon: Icons.storefront,
          color: Colors.blue,
        ),
        _SummaryCard(
          title: 'Pending',
          value: summary['Pending'].toString(),
          icon: Icons.pending_actions,
          color: Colors.orange,
        ),
        _SummaryCard(
          title: 'Approved',
          value: summary['Approved'].toString(),
          icon: Icons.check_circle_outline,
          color: Colors.green,
        ),
        _SummaryCard(
          title: 'Rejected',
          value: summary['Rejected'].toString(),
          icon: Icons.highlight_off,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildSearchFilterBar(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Flex(
        direction: isDesktop ? Axis.horizontal : Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Expanded(
            flex: isDesktop ? 3 : 0,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama cafe...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                searchQuery = value;
                _applySearch();
              },
            ),
          ),
          if (!isDesktop) const SizedBox(height: 12),
          if (isDesktop) const SizedBox(width: 12),
          // Filter Dropdown
          Expanded(
            flex: isDesktop ? 1 : 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedStatus,
                  isExpanded: true,
                  icon: const Icon(Icons.filter_list, size: 20),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('Semua Status')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'approved', child: Text('Approved')),
                    DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                    DropdownMenuItem(value: 'archived', child: Text('Archived')),
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
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data ditemukan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah filter atau kata kunci pencarian Anda',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              place['address'] ?? 'No address provided',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                const Spacer(),
                // Show Reject button if not already rejected
                if (status != 'rejected')
                  TextButton.icon(
                    onPressed: isProcessing ? null : onReject,
                    icon: isProcessing 
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.close, size: 18, color: Colors.red),
                    label: const Text('Reject', style: TextStyle(color: Colors.red)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                if (status != 'rejected' && status != 'approved')
                  const SizedBox(width: 8),
                // Show Approve button if not already approved
                if (status != 'approved')
                  FilledButton.icon(
                    onPressed: isProcessing ? null : onApprove,
                    icon: isProcessing 
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                if (status == 'approved' || status == 'rejected' && false) // Logic for when no buttons shown
                  Text(
                    'No further actions',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ],
        ),
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
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
