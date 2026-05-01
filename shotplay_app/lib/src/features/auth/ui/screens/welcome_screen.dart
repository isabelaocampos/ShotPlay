import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shotplay_app/src/features/auth/ui/widgets/welcome_hero_circle.dart';
import 'package:shotplay_app/src/features/auth/ui/widgets/welcome_primary_button.dart';
import 'package:shotplay_app/src/features/auth/ui/widgets/welcome_secondary_button.dart';
import 'package:shotplay_app/src/features/auth/ui/widgets/welcome_social_proof.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16111C),
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: Color(0xFF16111C)),
            ),
          ),
          Positioned(
            left: -39,
            top: -88.39,
            child: Container(
              width: 195,
              height: 442,
              decoration: ShapeDecoration(
                gradient: const RadialGradient(
                  center: Alignment(0.50, 0.50),
                  radius: 1.24,
                  colors: [Color(0x267F0DF2), Color(0x007F0DF2)],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
          ),
          Positioned(
            left: 195,
            top: 442,
            child: Container(
              width: 234,
              height: 530.39,
              decoration: ShapeDecoration(
                gradient: const RadialGradient(
                  center: Alignment(0.50, 0.50),
                  radius: 1.24,
                  colors: [Color(0x267F0DF2), Color(0x007F0DF2)],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: Color(0x66191022)),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                // Allow scroll only when content is taller than the viewport.
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: SizedBox(
                                  width: 159.48,
                                  height: 40,
                                  child: Text(
                                    'SHOTPLAY',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.spaceGrotesk(
                                      color: const Color(0xFF7F0DF2),
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      height: 1.11,
                                      letterSpacing: -1.8,
                                      shadows: [
                                        Shadow(
                                          offset: const Offset(0, 0),
                                          blurRadius: 15,
                                          color: const Color(0xFF7F0DF2)
                                              .withOpacity(0.80),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 227.67,
                                height: 16,
                                child: Text(
                                  'JUEGA. COMPITE. CONQUISTA.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.spaceGrotesk(
                                    color: const Color(0xFFCEC2D9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    height: 1.33,
                                    letterSpacing: 2.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 57),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 448),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 35),
                              child: WelcomeHeroCircle(),
                            ),
                          ),
                          const SizedBox(height: 57),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                WelcomePrimaryButton(
                                  label: 'Iniciar Sesion',
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/login');
                                  },
                                ),
                                const SizedBox(height: 16),
                                WelcomeSecondaryButton(
                                  label: 'Crear Cuenta',
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/signup');
                                  },
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  width: double.infinity,
                                  height: 1,
                                  color:
                                      const Color(0xFFCEC2D9).withOpacity(0.12),
                                ),
                                const SizedBox(height: 12),
                                const WelcomeSocialProof(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
