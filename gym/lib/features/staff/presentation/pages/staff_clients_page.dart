import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/client_profile.dart';
import '../cubit/staff_clients_cubit.dart';
import '../cubit/staff_clients_state.dart';

class StaffClientsPage extends StatelessWidget {
  const StaffClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StaffClientsCubit(getIt())..loadClients(),
      child: const _StaffClientsView(),
    );
  }
}

class _StaffClientsView extends StatefulWidget {
  const _StaffClientsView();

  @override
  State<_StaffClientsView> createState() => _StaffClientsViewState();
}

class _StaffClientsViewState extends State<_StaffClientsView> {
  String _selectedFilter = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isFabExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ClientProfile> _getFilteredClients(List<ClientProfile> clients) {
    return clients.where((client) {
      final matchesSearch =
          client.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              client.phoneNumber.contains(_searchQuery);

      if (!matchesSearch) return false;

      if (_selectedFilter == 'ALL') return true;
      if (_selectedFilter == 'ACTIVE')
        return client.isActive && client.isClaimed;
      if (_selectedFilter == 'REQUESTS') return !client.isClaimed;
      if (_selectedFilter == 'INACTIVE') return !client.isActive;

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-specific colors
    final bgColor = isDark ? const Color(0xFF131313) : const Color(0xFFF9F9F9);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final mutedColor =
        isDark ? const Color(0xFFA3A3A3) : const Color(0xFF5F5E5E);
    final borderCol =
        isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE2E2E2);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'ATHLETES',
          style: GoogleFonts.manrope(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: BlocBuilder<StaffClientsCubit, StaffClientsState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            loading: () => const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'FAILED TO LOAD ATHLETES',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.redAccent,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: mutedColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () =>
                        context.read<StaffClientsCubit>().loadClients(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: textColor),
                      ),
                      child: Text(
                        'RETRY',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            loaded: (clients) {
              final filtered = _getFilteredClients(clients);

              return Column(
                children: [
                  // Search Bar
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      style: GoogleFonts.manrope(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: cardColor,
                        hintText: 'SEARCH ATHLETES...',
                        hintStyle: GoogleFonts.inter(
                          color: mutedColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                        prefixIcon:
                            Icon(Icons.search, color: mutedColor, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear,
                                    color: textColor, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: borderCol, width: 1),
                          borderRadius: BorderRadius.zero,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: borderCol, width: 1),
                          borderRadius: BorderRadius.zero,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: textColor, width: 1.5),
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                  ),

                  // Filters Row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      children: ['ALL', 'ACTIVE', 'REQUESTS', 'INACTIVE']
                          .map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? textColor : cardColor,
                                border: Border.all(color: borderCol, width: 1),
                                borderRadius: BorderRadius.zero,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              child: Text(
                                filter,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  color: isSelected ? cardColor : textColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Clients List
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () =>
                          context.read<StaffClientsCubit>().loadClients(),
                      color: textColor,
                      backgroundColor: cardColor,
                      child: filtered.isEmpty
                          ? Center(
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Container(
                                  height: 300,
                                  alignment: Alignment.center,
                                  child: Text(
                                    'NO ATHLETES FOUND',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                      color: mutedColor,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final client = filtered[index];
                                return GestureDetector(
                                  onTap: () {
                                    context.push('/staff/clients/${client.id}/workout');
                                  },
                                  child: _buildAthleteCard(
                                    client: client,
                                    cardColor: cardColor,
                                    textColor: textColor,
                                    mutedColor: mutedColor,
                                    borderCol: borderCol,
                                    isDark: isDark,
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: _buildExpandableFab(),
    );
  }

  Widget _buildExpandableFab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fabBgColor = isDark ? Colors.white : Colors.black;
    final fabIconColor = isDark ? Colors.black : Colors.white;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isFabExpanded) ...[
          // Sub-button 1: Add Client
          GestureDetector(
            onTap: () async {
              setState(() {
                _isFabExpanded = false;
              });
              await context.push(AppRoute.staffAddClient.path);
              if (context.mounted) {
                context.read<StaffClientsCubit>().loadClients();
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.zero,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    'ADD CLIENT',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: fabBgColor,
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Icon(Icons.person_add, color: fabIconColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Sub-button 2: Show QR
          GestureDetector(
            onTap: () {
              setState(() {
                _isFabExpanded = false;
              });
              context.push(AppRoute.staffQr.path);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.zero,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    'SHOW QR',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: fabBgColor,
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Icon(Icons.qr_code, color: fabIconColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        // Main FAB toggle button
        GestureDetector(
          onTap: () {
            setState(() {
              _isFabExpanded = !_isFabExpanded;
            });
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: fabBgColor,
              borderRadius: BorderRadius.zero,
            ),
            child: Icon(
              _isFabExpanded ? Icons.close : Icons.add,
              color: fabIconColor,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAthleteCard({
    required ClientProfile client,
    required Color cardColor,
    required Color textColor,
    required Color mutedColor,
    required Color borderCol,
    required bool isDark,
  }) {
    Color statusBadgeColor;
    Color statusTextColor;
    String statusText;

    if (!client.isActive) {
      statusBadgeColor = Colors.grey.withValues(alpha: 0.15);
      statusTextColor = Colors.grey;
      statusText = 'INACTIVE';
    } else if (!client.isClaimed) {
      statusBadgeColor = Colors.blueAccent.withValues(alpha: 0.15);
      statusTextColor = Colors.blueAccent;
      statusText = 'UNCLAIMED';
    } else {
      statusBadgeColor = Colors.greenAccent.withValues(alpha: 0.15);
      statusTextColor = Colors.greenAccent;
      statusText = 'ACTIVE';
    }

    final physicalDetails = [
      if (client.height != null) '${client.height!.toStringAsFixed(0)} CM',
      if (client.weight != null) '${client.weight!.toStringAsFixed(1)} KG',
      if (client.sex != null) client.sex!,
      if (client.expLevel != null) client.expLevel!,
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderCol, width: 1),
        borderRadius: BorderRadius.zero,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  client.fullName.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: statusBadgeColor,
                  borderRadius: BorderRadius.zero,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  statusText,
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: statusTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            client.phoneNumber,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: textColor,
            ),
          ),
          if (physicalDetails.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              physicalDetails.join(' • '),
              style: GoogleFonts.inter(
                fontSize: 11,
                color: mutedColor,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BODY FAT %',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: mutedColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    client.bodyFatPct != null
                        ? '${client.bodyFatPct!.toStringAsFixed(1)}%'
                        : 'N/A',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'MUSCLE MASS %',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: mutedColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    client.muscleMass != null
                        ? '${client.muscleMass!.toStringAsFixed(1)}%'
                        : 'N/A',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
