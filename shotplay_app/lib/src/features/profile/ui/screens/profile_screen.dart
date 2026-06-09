import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shotplay_app/src/core/routing/app_routes.dart';
import 'package:shotplay_app/src/core/utils/supabase_safe.dart';
import 'package:shotplay_app/src/features/profile/ui/bloc/profile_bloc.dart';
import 'package:shotplay_app/src/features/profile/ui/widgets/profile_background.dart';
import 'package:shotplay_app/src/features/profile/ui/widgets/profile_stat_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final userId = safeCurrentUserId();
    if (userId != null) {
      context.read<ProfileBloc>().add(ProfileLoadRequested(userId));
    }
  }

  Future<void> _logout() async {
    if (isSupabaseReady()) {
      await Supabase.instance.client.auth.signOut();
    }
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16111C),
      body: ProfileBackground(
        child: SafeArea(
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading || state is ProfileInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF7F0DF2)),
                );
              }

              if (state is ProfileError) {
                return Center(
                  child: Text(
                    state.message,
                    style: GoogleFonts.spaceGrotesk(color: Colors.white),
                  ),
                );
              }

              if (state is ProfileLoaded) {
                final p = state.profile;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    children: [
                      // ── Header ───────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'SHOTPLAY',
                            style: GoogleFonts.spaceGrotesk(
                              color: const Color(0xFF7F0DF2),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // ── Avatar & Online Status ───────────────────────────
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF7F0DF2),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7F0DF2).withOpacity(0.4),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 56,
                              backgroundColor: Colors.white10,
                              child: Text(
                                p.username.isNotEmpty ? p.username[0].toUpperCase() : '?',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 12,
                            bottom: 8,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF16111C),
                                  width: 4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Username & Role Badge ────────────────────────────
                      Text(
                        p.username,
                        style: GoogleFonts.spaceGrotesk(
                          color: const Color(0xFFE9DFEF),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFE6B00),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFE6B00).withOpacity(0.4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Text(
                          p.role == 'player' ? 'JUGADOR' : p.role.toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(
                            color: const Color(0xFF572000),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // ── Stats Grid ───────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: ProfileStatCard(
                              label: 'Partidas Jugadas',
                              value: p.gamesPlayed.toString(),
                              icon: const Icon(Icons.sports_esports, color: Color(0xFF7F0DF2)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: ProfileStatCard(
                              label: 'ESTADO',
                              value: 'EN LÍNEA',
                              valueColor: Color(0xFF34D399),
                              valueFontSize: 16,
                              icon: Icon(Icons.online_prediction_rounded, color: Color(0xFF34D399)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // ── Info Section ─────────────────────────────────────
                      ProfileInfoTile(
                        label: 'Nombre',
                        value: p.username,
                        icon: Icons.person_outline_rounded,
                      ),
                      ProfileInfoTile(
                        label: 'Correo Electrónico',
                        value: p.email,
                        icon: Icons.email_outlined,
                      ),
                      ProfileInfoTile(
                        label: 'Rol',
                        value: p.role,
                        icon: Icons.shield_outlined,
                      ),
                      const SizedBox(height: 32),

                      // ── Action Buttons ───────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7F0DF2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                            shadowColor: const Color(0xFF7F0DF2).withOpacity(0.4),
                          ),
                          icon: const Icon(Icons.edit_outlined, color: Colors.white),
                          label: Text(
                            'EDITAR PERFIL',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: TextButton.icon(
                          onPressed: _logout,
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF38323F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.logout_rounded, color: Color(0xFFFFB4AB)),
                          label: Text(
                            'CERRAR SESIÓN',
                            style: GoogleFonts.spaceGrotesk(
                              color: const Color(0xFFFFB4AB),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
