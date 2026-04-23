import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class UserProfile {
  String name;
  String email;
  String role;
  UserProfile({required this.name, required this.email, required this.role});
}

final ValueNotifier<UserProfile> profileNotifier = ValueNotifier(UserProfile(name: 'Alfin', email: 'alfin@example.com', role: 'User'));

// -- COLORS (Style Guide) --
const Color primaryBlue = Color(0xFF2563EB);
const Color darkNavy = Color(0xFF1E3A5F);
const Color slateGray = Color(0xFF64748B);
const Color successGreen = Color(0xFF16A34A);
const Color warningOrange = Color(0xFFD97706);
const Color dangerRed = Color(0xFFDC2626);
const Color lightBlueBg = Color(0xFFDBEAFE);
const Color lightGrayBg = Color(0xFFF1F5F9);

const Color bgLight = lightGrayBg;
const Color bgDark = Color(0xFF12141D);
const Color cardDark = Color(0xFF1E202C);

// Ticket Badge Colors
const Color statusOpen = primaryBlue;
const Color statusProgress = warningOrange;
const Color statusResolved = successGreen;
const Color statusClosed = slateGray;

void main() {
  runApp(const HelpdeskApp());
}

class HelpdeskApp extends StatelessWidget {
  const HelpdeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp.router(
          title: 'E-Ticketing',
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Roboto',
            scaffoldBackgroundColor: bgLight,
            primaryColor: primaryBlue,
            colorScheme: ColorScheme.fromSeed(seedColor: primaryBlue, brightness: Brightness.light),
            appBarTheme: const AppBarTheme(backgroundColor: bgLight, elevation: 0, iconTheme: IconThemeData(color: Colors.black), titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            cardTheme: CardThemeData(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200))),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Roboto',
            scaffoldBackgroundColor: bgDark,
            primaryColor: primaryBlue,
            colorScheme: ColorScheme.fromSeed(seedColor: primaryBlue, brightness: Brightness.dark),
            appBarTheme: const AppBarTheme(backgroundColor: bgDark, elevation: 0, iconTheme: IconThemeData(color: Colors.white), titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            cardTheme: const CardThemeData(color: cardDark, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)))),
          ),
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

// -- ROUTING --
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
        GoRoute(path: '/tickets', builder: (context, state) => const TicketListScreen()),
        GoRoute(path: '/notifications', builder: (context, state) => const NotificationScreen()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      ],
    ),
    GoRoute(path: '/create-ticket', builder: (context, state) => const CreateTicketScreen()),
    GoRoute(path: '/ticket/:id', builder: (context, state) => TicketDetailScreen(ticketId: state.pathParameters['id']!)),
  ],
);

// -- MAIN SCAFFOLD (BOTTOM NAV) --
class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int currentIndex = _getSelectedIndex(location);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAdmin = profileNotifier.value.role == 'Helpdesk';

    return Scaffold(
      body: child,
      floatingActionButton: isAdmin ? null : FloatingActionButton(
        onPressed: () => context.push('/create-ticket'),
        backgroundColor: primaryBlue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: isAdmin ? null : FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: isDark ? cardDark : Colors.white,
        shape: isAdmin ? null : const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: isAdmin ? MainAxisAlignment.spaceAround : MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(context, icon: Icons.dashboard, label: 'Dashboard', index: 0, currentIndex: currentIndex, path: '/dashboard'),
              _buildNavItem(context, icon: Icons.receipt_long, label: 'Tiket', index: 1, currentIndex: currentIndex, path: '/tickets'),
              if (!isAdmin) const SizedBox(width: 48), // Spacing for FAB
              _buildNavItem(context, icon: Icons.notifications_none, label: 'Notifikasi', index: 2, currentIndex: currentIndex, path: '/notifications'),
              _buildNavItem(context, icon: Icons.person_outline, label: 'Profil', index: 3, currentIndex: currentIndex, path: '/profile'),
            ],
          ),
        ),
      ),
    );
  }

  int _getSelectedIndex(String location) {
    if (location.contains('/dashboard')) return 0;
    if (location.contains('/tickets')) return 1;
    if (location.contains('/notifications')) return 2;
    if (location.contains('/profile')) return 3;
    return 0;
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required String label, required int index, required int currentIndex, required String path}) {
    final isSelected = index == currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected ? primaryBlue : (isDark ? Colors.grey.shade500 : Colors.grey.shade400);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.go(path),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

// -- COMPONENTS --
class CustomBadge extends StatelessWidget {
  final String text;
  final Color color;
  const CustomBadge({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

// -- SCREEN: SPLASH --
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Pindah ke halaman login setelah 2.5 detik
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(24)),
              child: const Center(child: Text('E', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(height: 32),
            const Text('E-Ticketing', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Helpdesk Mobile', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// -- SCREEN: LOGIN --
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Blue Area
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                    child: const Center(child: Text('E', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(height: 40),
                  const Text('Selamat Datang ??', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Masuk ke akun helpdesk Anda.', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // Bottom White/Dark Area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? bgDark : Colors.white,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                ),
                padding: const EdgeInsets.all(32),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'Ketik "admin" untuk Helpdesk',
                          filled: true,
                          fillColor: isDark ? cardDark : Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Password', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'masukkan password',
                          filled: true,
                          fillColor: isDark ? cardDark : Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          suffixIcon: const Icon(Icons.visibility_off, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('Lupa password?', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: () {
                            if (emailController.text.toLowerCase() == 'admin' || emailController.text.toLowerCase() == 'helpdesk') {
                              profileNotifier.value = UserProfile(name: 'Admin Helpdesk', email: 'admin@perusahaan.com', role: 'Helpdesk');
                            } else {
                              profileNotifier.value = UserProfile(name: 'Alfin', email: 'alfin@example.com', role: 'User');
                            }
                            context.go('/dashboard');
                          },
                          child: const Text('Masuk', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: RichText(text: TextSpan(text: 'Belum punya akun? ', style: TextStyle(color: isDark ? Colors.white70 : Colors.grey), children: [TextSpan(text: 'Daftar', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold))])),
                      )
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

// -- SCREEN: DASHBOARD --
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Selamat Pagi ??', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    Text('Halo, ${profileNotifier.value.name.split(' ')[0]}!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.dark_mode_outlined),
                      onPressed: () { themeNotifier.value = themeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark; },
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
                      child: const Icon(Icons.notifications_none, size: 20),
                    )
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),
            // Stat Cards Grid
            GridView.count(
              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.6,
              children: [
                _buildStatCard(context, profileNotifier.value.role == 'Helpdesk' ? 'Tiket Sistem' : 'Total Tiket', profileNotifier.value.role == 'Helpdesk' ? '45' : '5', const Color(0xFF5D7FFF), Icons.confirmation_num),
                _buildStatCard(context, 'Open', profileNotifier.value.role == 'Helpdesk' ? '12' : '2', const Color(0xFFF79009), Icons.radio_button_unchecked),
                _buildStatCard(context, 'In Progress', profileNotifier.value.role == 'Helpdesk' ? '8' : '1', const Color(0xFF9b51e0), Icons.headset_mic),
                _buildStatCard(context, 'Resolved', profileNotifier.value.role == 'Helpdesk' ? '25' : '1', const Color(0xFF27AE60), Icons.check_circle_outline),
              ],
            ),
            const SizedBox(height: 24),
            // Chart Mockup
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Statistik Tiket', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('7 Hari Terakhir', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Total Tiket', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildChartBar('Sen', 20),
                        _buildChartBar('Sel', 50),
                        _buildChartBar('Rab', 10),
                        _buildChartBar('Kam', 80, true),
                        _buildChartBar('Jum', 40),
                        _buildChartBar('Sab', 30),
                        _buildChartBar('Min', 20),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Recent Tickets
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(profileNotifier.value.role == 'Helpdesk' ? 'Semua Tiket Terbaru' : 'Tiket Terbaru Anda', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () => context.go('/tickets'), child: Text('Lihat Semua', style: TextStyle(color: primaryBlue))),
              ],
            ),
            const SizedBox(height: 8),
            _buildTicketListItem(context, 'T-001', 'Komputer tidak bisa menyala', statusProgress, 'In Progress', 'Hardware', 'High'),
            const SizedBox(height: 12),
            _buildTicketListItem(context, 'T-002', 'Tidak bisa akses email kantor', statusOpen, 'Open', 'Software', 'Medium'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String count, Color bgColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(count, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildChartBar(String day, double height, [bool isActive = false]) {
    return Column(
      children: [
        Container(
          width: 14, height: height,
          decoration: BoxDecoration(color: isActive ? primaryBlue : primaryBlue.withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildTicketListItem(BuildContext context, String id, String title, Color statusCol, String statusTxt, String cat, String prio) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.receipt_long, color: Colors.grey)),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(id, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: CustomBadge(text: statusTxt, color: statusCol),
        onTap: () => context.push('/ticket/$id'),
      ),
    );
  }
}

// -- SCREEN: TICKET LIST --
class TicketListScreen extends StatelessWidget {
  const TicketListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tiket')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFullTicketCard(context, 'T-001', 'Komputer tidak bisa menyala', statusProgress, 'In Progress', 'Hardware', 'High', '22 Apr', Colors.red),
          _buildFullTicketCard(context, 'T-002', 'Tidak bisa akses email kantor', statusOpen, 'Open', 'Software', 'Medium', '03 Jun', Colors.orange),
          _buildFullTicketCard(context, 'T-003', 'Printer lantai 2 error', statusResolved, 'Resolved', 'Hardware', 'Low', '25 Mei', Colors.green),
          _buildFullTicketCard(context, 'T-004', 'Koneksi internet lambat di ruang meeting', statusOpen, 'Open', 'Network', 'High', '04 Jun', Colors.red),
          _buildFullTicketCard(context, 'T-005', 'Request install software Figma', statusClosed, 'Closed', 'Software', 'Low', '20 Mei', Colors.green),
        ],
      ),
    );
  }

  Widget _buildFullTicketCard(BuildContext context, String id, String title, Color statusCol, String statusTxt, String cat, String prio, String date, Color prioCol) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/ticket/$id'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                  const SizedBox(width: 8),
                  CustomBadge(text: statusTxt, color: statusCol),
                ],
              ),
              const SizedBox(height: 4),
              Text(id, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomBadge(text: cat, color: Colors.purple.shade300),
                      const SizedBox(width: 8),
                      CustomBadge(text: prio, color: prioCol),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// -- SCREEN: CREATE TICKET --
class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});
  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  String selectedPriority = 'Medium';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Tiket Baru'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Judul Masalah', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(decoration: _inputDec(isDark, 'Contoh: Printer tidak bisa nyala')),
          const SizedBox(height: 16),
          
          const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(maxLines: 4, decoration: _inputDec(isDark, 'Jelaskan masalah secara detail...')),
          const SizedBox(height: 16),

          const Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: _inputDec(isDark, ''),
            value: 'Hardware',
            items: ['Hardware', 'Software', 'Network'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) {},
          ),
          const SizedBox(height: 16),

          const Text('Prioritas', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildPriorityBtn('Low', Colors.green, selectedPriority == 'Low'),
              const SizedBox(width: 12),
              _buildPriorityBtn('Medium', Colors.orange, selectedPriority == 'Medium'),
              const SizedBox(width: 12),
              _buildPriorityBtn('High', Colors.red, selectedPriority == 'High'),
            ],
          ),
          const SizedBox(height: 24),

          const Text('Lampiran (Opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.5), style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
              color: isDark ? cardDark : Colors.grey.shade50,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.attach_file, color: primaryBlue),
                const SizedBox(width: 8),
                Text('Tambah Lampiran', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () { context.pop(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tiket Dibuat'))); },
              child: const Text('Kirim Tiket', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDec(bool isDark, String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark ? cardDark : Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.transparent : Colors.grey.shade300)),
    );
  }

  Widget _buildPriorityBtn(String text, Color color, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedPriority = text),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? color.withOpacity(0.2) : color.withOpacity(0.1)) : (isDark ? cardDark : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? color : Colors.grey.shade300),
          ),
          alignment: Alignment.center,
          child: Text(text, style: TextStyle(color: isSelected ? color : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ),
      ),
    );
  }
}

// -- SCREEN: TICKET DETAIL --
class TicketDetailScreen extends StatelessWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context) {
    final isAdmin = profileNotifier.value.role == 'Helpdesk';
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
          title: Text(ticketId),
          bottom: const TabBar(
            labelColor: primaryBlue,
            indicatorColor: primaryBlue,
            unselectedLabelColor: Colors.grey,
            tabs: [Tab(text: 'Detail'), Tab(text: 'Komentar'), Tab(text: 'Riwayat')],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDetailTab(context),
            const Center(child: Text('Belum ada komentar')),
            const Center(child: Text('Riwayat perubahan tiket')),
          ],
        ),
        bottomNavigationBar: isAdmin ? Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: () { context.pop(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tiket ditandai selesai'))); },
            child: const Text('TANDAI SELESAI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ) : null,
      ),
    );
  }

  Widget _buildDetailTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('tes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: const [
            CustomBadge(text: 'Open', color: statusOpen), SizedBox(width: 8),
            CustomBadge(text: 'Medium', color: Colors.orange), SizedBox(width: 8),
            CustomBadge(text: 'Hardware', color: Colors.purple),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(children: const [Icon(Icons.calendar_today, size: 16, color: Colors.grey), SizedBox(width: 8), Text('Dibuat: 22 Apr 2026, 08:26', style: TextStyle(color: Colors.grey, fontSize: 13))]),
              const SizedBox(height: 8),
              Row(children: const [Icon(Icons.update, size: 16, color: Colors.grey), SizedBox(width: 8), Text('Diperbarui: 22 Apr 2026, 08:26', style: TextStyle(color: Colors.grey, fontSize: 13))]),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('tes', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 24),
        const Text('Lampiran Gambar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(color: isDark ? cardDark.withOpacity(0.5) : Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
          alignment: Alignment.center,
          child: const Icon(Icons.image, size: 40, color: Colors.grey),
        )
      ],
    );
  }
}

// -- SCREEN: NOTIFICATION --
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [TextButton(style: TextButton.styleFrom(foregroundColor: Colors.grey), onPressed: (){}, child: const Text('Tandai semua', style: TextStyle(color: Colors.grey)))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotifItem(context, 'Tiket T-001 Diperbarui', 'Status tiket "Komputer tidak bisa menyala" berubah menjadi In Progress.', true),
          _buildNotifItem(context, 'Komentar Baru di T-001', 'Abdullah menambahkan komentar pada tiket Anda.\n02 Jun, 10:30', true),
          _buildNotifItem(context, 'Tiket T-003 Selesai', 'Tiket "Printer lantai 2 error" telah diselesaikan.\n28 May, 14:00', false),
          _buildNotifItem(context, 'Tiket T-005 Ditutup', 'Tiket "Request install software Figma" telah ditutup.\n21 May, 11:30', false),
        ],
      ),
    );
  }

  Widget _buildNotifItem(BuildContext context, String title, String desc, bool isUnread) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? (isDark ? primaryBlue.withOpacity(0.2) : primaryBlue.withOpacity(0.05)) : (isDark ? cardDark : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isUnread ? primaryBlue.withOpacity(0.3) : Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.notifications, color: isUnread ? primaryBlue : Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          if (isUnread) Container(width: 8, height: 8, decoration: const BoxDecoration(color: primaryBlue, shape: BoxShape.circle)),
        ],
      ),
    );
  }
}

// -- SCREEN: PROFILE --
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ValueListenableBuilder<UserProfile>(
        valueListenable: profileNotifier,
        builder: (context, userProfile, child) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // User Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(color: isDark ? Colors.black : Colors.black87, borderRadius: BorderRadius.circular(16)),
                        alignment: Alignment.center,
                        child: Text(userProfile.name[0], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userProfile.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(userProfile.email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                              child: Text(userProfile.role, style: const TextStyle(fontSize: 11)),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Stats
              Row(
                children: [
                  Expanded(child: _buildProfileStat(context, '6', 'Total')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildProfileStat(context, '3', 'Open')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildProfileStat(context, '2', 'Selesai')),
                ],
              ),
              const SizedBox(height: 32),
              const Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ValueListenableBuilder<ThemeMode>(
                      valueListenable: themeNotifier,
                      builder: (_, mode, __) => ListTile(
                        leading: const Icon(Icons.dark_mode_outlined),
                        title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Switch(
                          activeColor: Colors.white, activeTrackColor: primaryBlue,
                          value: mode == ThemeMode.dark,
                          onChanged: (val) { themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light; },
                        ),
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                    ListTile(
                      leading: const Icon(Icons.notifications_none),
                      title: const Text('Notifikasi', style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () => context.push('/notifications'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () => context.go('/login'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.red.withOpacity(0.1) : Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            ],
          );
        }
      ),
    );
  }

  Widget _buildProfileStat(BuildContext context, String count, String label) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
