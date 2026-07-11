import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffDashboardPage extends StatelessWidget {
  const StaffDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-specific colors
    final bgColor = isDark ? const Color(0xFF131313) : const Color(0xFFF9F9F9);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final mutedColor = isDark ? const Color(0xFFA3A3A3) : const Color(0xFF5F5E5E);
    final borderCol = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE2E2E2);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'STAFF COMMAND',
          style: GoogleFonts.manrope(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: cardColor,
              radius: 18,
              child: Icon(Icons.notifications_outlined, color: textColor, size: 20),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                context,
                label: 'ACTIVE CLIENTS',
                value: '12',
                change: '+2 this wk',
                isDark: isDark,
                cardColor: cardColor,
                textColor: textColor,
                mutedColor: mutedColor,
                borderCol: borderCol,
              ),
              _buildStatCard(
                context,
                label: "TODAY'S SESSIONS",
                value: '4',
                change: '2 completed',
                isDark: isDark,
                cardColor: cardColor,
                textColor: textColor,
                mutedColor: mutedColor,
                borderCol: borderCol,
              ),
              _buildStatCard(
                context,
                label: 'WEEKLY REVENUE',
                value: '\$1,420',
                change: '+15.2%',
                isDark: isDark,
                cardColor: cardColor,
                textColor: textColor,
                mutedColor: mutedColor,
                borderCol: borderCol,
              ),
              _buildStatCard(
                context,
                label: 'TRAINER RATING',
                value: '4.9 ★',
                change: '32 reviews',
                isDark: isDark,
                cardColor: cardColor,
                textColor: textColor,
                mutedColor: mutedColor,
                borderCol: borderCol,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Live Occupancy Section
          _buildSectionHeader(title: 'LIVE AT THE TEMPLE', mutedColor: mutedColor),
          const SizedBox(height: 8),
          Container(
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
                    Text(
                      'CURRENT CAPACITY: OPTIMAL',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: Colors.greenAccent,
                      ),
                    ),
                    Text(
                      '14 Athletes Present',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: mutedColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLiveAthleteTile(
                  name: 'MARCUS CHEN',
                  workout: 'Leg Day / Posterior Chain',
                  timeAgo: 'Checked in 10m ago',
                  isDark: isDark,
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
                const Divider(height: 24, thickness: 0.5, color: Colors.grey),
                _buildLiveAthleteTile(
                  name: 'ELARA VANCE',
                  workout: 'Hypertrophy / Upper Body',
                  timeAgo: 'Checked in 25m ago',
                  isDark: isDark,
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
                const Divider(height: 24, thickness: 0.5, color: Colors.grey),
                _buildLiveAthleteTile(
                  name: 'JULIAN ROSS',
                  workout: 'Mobility & Active Recovery',
                  timeAgo: 'Checked in 45m ago',
                  isDark: isDark,
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Pending Actions Section
          _buildSectionHeader(title: 'PENDING ACTIONS', mutedColor: mutedColor),
          const SizedBox(height: 8),
          _buildActionCard(
            title: 'WORKOUT PLAN REVIEW REQUEST',
            description: 'Julian Ross submitted his weekly plan feedback.',
            actionLabel: 'REVIEW',
            cardColor: cardColor,
            textColor: textColor,
            mutedColor: mutedColor,
            borderCol: borderCol,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            title: 'MILESTONE CELEBRATION',
            description: 'Sarah Jenkins hit a new deadlift max of 180kg.',
            actionLabel: 'CONGRATULATE',
            cardColor: cardColor,
            textColor: textColor,
            mutedColor: mutedColor,
            borderCol: borderCol,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required String change,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color mutedColor,
    required Color borderCol,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderCol, width: 1),
        borderRadius: BorderRadius.zero, // Sharp 0px borders
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: mutedColor,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          Text(
            change,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required Color mutedColor}) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.0,
        color: mutedColor,
      ),
    );
  }

  Widget _buildLiveAthleteTile({
    required String name,
    required String workout,
    required String timeAgo,
    required bool isDark,
    required Color textColor,
    required Color mutedColor,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE2E2E2),
            borderRadius: BorderRadius.zero,
          ),
          child: Center(
            child: Text(
              name.substring(0, 1),
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                workout,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: mutedColor,
                ),
              ),
            ],
          ),
        ),
        Text(
          timeAgo,
          style: GoogleFonts.inter(
            fontSize: 9,
            color: mutedColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required String actionLabel,
    required Color cardColor,
    required Color textColor,
    required Color mutedColor,
    required Color borderCol,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderCol, width: 1),
        borderRadius: BorderRadius.zero,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: mutedColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.4,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: textColor,
                foregroundColor: cardColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {},
              child: Text(
                actionLabel,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
