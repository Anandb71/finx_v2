import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/enhanced_portfolio_provider.dart';
import '../services/data_cache.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  bool _soundEnabled = true;
  bool _hapticEnabled = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final portfolio = context.watch<EnhancedPortfolioProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(isDesktop),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: EdgeInsets.all(isDesktop ? 32.0 : 20.0),
                    child: Column(
                      children: [
                        _buildUserProfileCard(portfolio, isDesktop),
                        const SizedBox(height: 24),
                        _buildQuickStats(portfolio, isDesktop),
                        const SizedBox(height: 32),
                        _buildSettingsSections(isDesktop),
                        const SizedBox(height: 32),
                        _buildDangerZone(isDesktop),
                        const SizedBox(height: 100),
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

  Widget _buildSliverAppBar(bool isDesktop) {
    return SliverAppBar(
      expandedHeight: isDesktop ? 120 : 100,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isDesktop ? 32 : 20,
              MediaQuery.of(context).padding.top + 20,
              isDesktop ? 32 : 20,
              20,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FFA3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00FFA3).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Color(0xFF00FFA3),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Settings',
                        style: GoogleFonts.inter(
                          fontSize: isDesktop ? 32 : 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Customize your Finx experience',
                        style: GoogleFonts.inter(
                          fontSize: isDesktop ? 16 : 14,
                          color: Colors.white70,
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

  Widget _buildUserProfileCard(EnhancedPortfolioProvider portfolio, bool isDesktop) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00FFA3).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFA3).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isDesktop ? 80 : 60,
            height: isDesktop ? 80 : 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00FFA3), Color(0xFF00D4FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(isDesktop ? 20 : 15),
            ),
            child: Center(
              child: Text(
                user?.displayName?.isNotEmpty == true
                    ? user!.displayName![0].toUpperCase()
                    : user?.email?.isNotEmpty == true
                    ? user!.email![0].toUpperCase()
                    : 'U',
                style: GoogleFonts.inter(
                  fontSize: isDesktop ? 32 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'User',
                  style: GoogleFonts.inter(
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'user@example.com',
                  style: GoogleFonts.inter(
                    fontSize: isDesktop ? 16 : 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FFA3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF00FFA3).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Level ${portfolio.userLevel} • ${portfolio.userXp} XP',
                    style: GoogleFonts.inter(
                      fontSize: isDesktop ? 14 : 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF00FFA3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(EnhancedPortfolioProvider portfolio, bool isDesktop) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Portfolio Value',
            '\$${portfolio.virtualCash.toStringAsFixed(0)}',
            Icons.account_balance_wallet,
            isDesktop,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Trades',
            '${portfolio.totalTrades}',
            Icons.trending_up,
            isDesktop,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Achievements',
            '${portfolio.recentAchievements.length}',
            Icons.emoji_events,
            isDesktop,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    bool isDesktop,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF00FFA3), size: isDesktop ? 28 : 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isDesktop ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: isDesktop ? 12 : 10,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSections(bool isDesktop) {
    return Column(
      children: [
        _buildSettingsSection('Preferences', Icons.tune, [
          _buildSwitchTile(
            'Dark Mode',
            'Use dark theme throughout the app',
            _darkModeEnabled,
            (value) => setState(() => _darkModeEnabled = value),
            Icons.dark_mode,
          ),
          _buildSwitchTile(
            'Notifications',
            'Receive push notifications',
            _notificationsEnabled,
            (value) => setState(() => _notificationsEnabled = value),
            Icons.notifications,
          ),
          _buildSwitchTile(
            'Sound Effects',
            'Play sounds for interactions',
            _soundEnabled,
            (value) => setState(() => _soundEnabled = value),
            Icons.volume_up,
          ),
          _buildSwitchTile(
            'Haptic Feedback',
            'Vibrate on interactions',
            _hapticEnabled,
            (value) => setState(() => _hapticEnabled = value),
            Icons.vibration,
          ),
        ], isDesktop),
        const SizedBox(height: 24),
        _buildSettingsSection('Data Management', Icons.storage, [
          _buildActionTile(
            'Clear Cache',
            'Free up storage space',
            () => _clearCache(),
            Icons.cleaning_services,
          ),
          _buildActionTile(
            'Reset Portfolio',
            'Reset all trading data and start fresh',
            () => _showResetPortfolioDialog(),
            Icons.refresh,
          ),
        ], isDesktop),
      ],
    );
  }

  Widget _buildSettingsSection(
    String title,
    IconData icon,
    List<Widget> children,
    bool isDesktop,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 20 : 16),
            decoration: BoxDecoration(
              color: const Color(0xFF00FFA3).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF00FFA3),
                  size: isDesktop ? 24 : 20,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: isDesktop ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00FFA3), size: 20),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF00FFA3),
        activeTrackColor: const Color(0xFF00FFA3).withOpacity(0.3),
        inactiveThumbColor: Colors.white70,
        inactiveTrackColor: Colors.white.withOpacity(0.1),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    VoidCallback onTap,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00FFA3), size: 20),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white70,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDangerZone(bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.red, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Account',
                  style: GoogleFonts.inter(
                    fontSize: isDesktop ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          _buildActionTile(
            'Sign Out',
            'Sign out of your account',
            () => _signOut(),
            Icons.logout,
          ),
        ],
      ),
    );
  }

  void _clearCache() async {
    final cache = context.read<DataCache>();
    await cache.clearCache();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cache cleared successfully'),
          backgroundColor: const Color(0xFF00FFA3),
        ),
      );
    }
  }

  void _showResetPortfolioDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Reset Portfolio',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will reset all your trading data, portfolio, and achievements. This action cannot be undone.',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<EnhancedPortfolioProvider>().resetPortfolio();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Portfolio reset successfully'),
                  backgroundColor: Color(0xFF00FFA3),
                ),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }
}
