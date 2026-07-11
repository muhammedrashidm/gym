import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/trainer_live_clients/trainer_live_clients_cubit.dart';
import '../cubit/trainer_live_clients/trainer_live_clients_state.dart';

class TrainerLiveClientsPage extends StatefulWidget {
  const TrainerLiveClientsPage({super.key});

  @override
  State<TrainerLiveClientsPage> createState() => _TrainerLiveClientsPageState();
}

class _TrainerLiveClientsPageState extends State<TrainerLiveClientsPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<TrainerLiveClientsCubit>().loadClients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const sinewGreen = Color(0xFF34D399);
    final outlineColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E7EB);
    final bgColor = isDark ? const Color(0xFF131313) : const Color(0xFFF7F9FD);
    final cardBg = isDark ? const Color(0xFF1C1B1B) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFE5E2E1) : const Color(0xFF111827);
    final textSecondary = isDark ? const Color(0xFFA1A1A1) : const Color(0xFF5F5E5E);
    final inputBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEBE7E7);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF131313) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'LIVE SESSIONS',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: textPrimary,
          ),
        ),
      ),
      body: BlocBuilder<TrainerLiveClientsCubit, TrainerLiveClientsState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (failure) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 48, color: textSecondary),
                  const SizedBox(height: 16),
                  Text('Failed to load clients.',
                      style: GoogleFonts.manrope(color: textPrimary)),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () =>
                        context.read<TrainerLiveClientsCubit>().loadClients(),
                    child: const Text('RETRY'),
                  ),
                ],
              ),
            ),
            loaded: (activeClients, idleClients) {
              final filteredActive = activeClients
                  .where((c) => c.clientName
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                  .toList();
              final filteredIdle = idleClients
                  .where((c) => c.clientName
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                  .toList();

              return RefreshIndicator(
                onRefresh: () =>
                    context.read<TrainerLiveClientsCubit>().loadClients(),
                child: CustomScrollView(
                  slivers: [
                    // Aggregate header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${activeClients.length} ACTIVE SESSION${activeClients.length == 1 ? '' : 'S'}',
                              style: GoogleFonts.manrope(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                color: textPrimary,
                              ),
                            ),
                            if (activeClients.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Builder(builder: (context) {
                                final totalCompleted = activeClients
                                    .fold(0, (s, c) => s + c.completedTasks);
                                return Text(
                                  '$totalCompleted tasks logged across ${activeClients.length} client${activeClients.length == 1 ? '' : 's'}',
                                  style: GoogleFonts.inter(
                                      fontSize: 13, color: textSecondary),
                                );
                              }),
                            ],
                            const SizedBox(height: 20),
                            // Search
                            Container(
                              decoration: BoxDecoration(
                                color: inputBg,
                                border: Border.all(color: outlineColor, width: 1),
                              ),
                              child: TextField(
                                controller: _searchController,
                                style: GoogleFonts.inter(
                                    color: textPrimary, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'SEARCH CLIENTS',
                                  hintStyle: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                    color: textSecondary,
                                  ),
                                  prefixIcon: Icon(Icons.search, color: textSecondary),
                                  filled: false,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                ),
                                onChanged: (v) =>
                                    setState(() => _searchQuery = v),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Active Now section
                    if (filteredActive.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: _SectionHeader(
                          label: 'ACTIVE NOW',
                          count: filteredActive.length,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          accentColor: sinewGreen,
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final client = filteredActive[index];
                            return _ActiveClientRow(
                              client: client,
                              outlineColor: outlineColor,
                              cardBg: cardBg,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              sinewGreen: sinewGreen,
                              onTap: () => context.push(
                                '/staff/clients/${client.clientProfileId}/session',
                                extra: client.clientName,
                              ),
                            );
                          },
                          childCount: filteredActive.length,
                        ),
                      ),
                    ],

                    // Divider
                    SliverToBoxAdapter(
                      child: Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        color: outlineColor,
                      ),
                    ),

                    // Start a session
                    SliverToBoxAdapter(
                      child: _SectionHeader(
                        label: 'START A SESSION',
                        count: filteredIdle.length,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        accentColor: textSecondary,
                      ),
                    ),

                    if (filteredIdle.isEmpty && filteredActive.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(Icons.group_off,
                                  size: 48, color: textSecondary),
                              const SizedBox(height: 16),
                              Text(
                                'No clients assigned yet.',
                                style: GoogleFonts.manrope(
                                    color: textPrimary, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),

                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final client = filteredIdle[index];
                          return _IdleClientRow(
                            client: client,
                            outlineColor: outlineColor,
                            cardBg: cardBg,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            onTap: () => context.push(
                              '/staff/clients/${client.clientProfileId}/session',
                              extra: client.clientName,
                            ),
                          );
                        },
                        childCount: filteredIdle.length,
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;

  const _SectionHeader({
    required this.label,
    required this.count,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Container(width: 3, height: 14, color: accentColor),
          const SizedBox(width: 10),
          Text(
            '$label ($count)',
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveClientRow extends StatelessWidget {
  final ClientWithSessionStatus client;
  final Color outlineColor;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color sinewGreen;
  final VoidCallback onTap;

  const _ActiveClientRow({
    required this.client,
    required this.outlineColor,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.sinewGreen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final draft = client.activeDraft!;
    final elapsed = DateTime.now().difference(draft.startedAt);
    final elapsedStr = elapsed.inMinutes >= 60
        ? '${elapsed.inHours}h ${elapsed.inMinutes.remainder(60)}m'
        : '${elapsed.inMinutes}m';

    // Estimate tasks total from day plan (we use drafts count as completed)
    final completed = draft.taskDrafts.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border.all(color: outlineColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF1C1B1B),
                    child: Text(
                      client.clientName.isNotEmpty
                          ? client.clientName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.clientName.toUpperCase(),
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          draft.dayPlanLabel ?? 'Today\'s Session',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        elapsedStr,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: sinewGreen,
                        ),
                      ),
                      Text(
                        '$completed tasks logged',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar (visual, proportional to tasks logged)
              ClipRect(
                child: SizedBox(
                  height: 4,
                  child: LinearProgressIndicator(
                    value: completed > 0 ? (completed / (completed + 3)).clamp(0.0, 1.0) : 0,
                    backgroundColor: outlineColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IdleClientRow extends StatelessWidget {
  final ClientWithSessionStatus client;
  final Color outlineColor;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;

  const _IdleClientRow({
    required this.client,
    required this.outlineColor,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border.all(color: outlineColor, width: 1),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: outlineColor,
                child: Text(
                  client.clientName.isNotEmpty
                      ? client.clientName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                      color: textPrimary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  client.clientName.toUpperCase(),
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
              ),
              Icon(Icons.play_circle_outline, color: textSecondary, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
