import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shotplay_app/src/core/routing/app_routes.dart';
import 'package:shotplay_app/src/features/ingresar_codigo/ui/bloc/ingresar_codigo_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IngresoCodigoScreen extends StatefulWidget {
  const IngresoCodigoScreen({super.key});

  @override
  State<IngresoCodigoScreen> createState() => _IngresoCodigoScreenState();
}

class _IngresoCodigoScreenState extends State<IngresoCodigoScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  String get _fullCode =>
      _controllers.map((c) => c.text).join();

  bool get _isComplete => _fullCode.length == 4;

  @override
  void initState() {
    super.initState();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      context.read<IngresarCodigoBloc>().add(IngresarCodigoLoadRequested(userId));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onKeyChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _joinRoom() {
    if (!_isComplete) return;
    // Navigate to sala espera with code
    Navigator.pushNamed(context, AppRoutes.waitingRoom);
  }

  void _createRoom() {
    Navigator.pushNamed(context, AppRoutes.waitingRoom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191022),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Main scrollable content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ),

          // Bottom nav bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xCC191022),
        border: Border.all(color: const Color(0x197F0DF2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9999),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFFF1F5F9),
                size: 22,
              ),
            ),
          ),

          // Title
          Expanded(
            child: Text(
              'Escaleras y serpientes',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0xFFF1F5F9),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.25,
                letterSpacing: -0.45,
              ),
            ),
          ),

          // Share button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9999),
            ),
            child: const Icon(
              Icons.ios_share,
              color: Color(0xFFF1F5F9),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: 120, // space for bottom nav + player chip
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          _buildTitleSection(),
          const SizedBox(height: 40),
          _buildCodeInputs(),
          const SizedBox(height: 48),
          _buildActionButtons(),
          const SizedBox(height: 40),
          _buildPlayerChip(),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          'Unirse a una sala',
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFFF1F5F9),
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.20,
            letterSpacing: -0.75,
          ),
        ),
        const SizedBox(height: 11),
        Text(
          'Ingresa el código de 4 dígitos que te\ncompartió tu amigo',
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.63,
          ),
        ),
      ],
    );
  }

  Widget _buildCodeInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final bool isFocused = _focusNodes[index].hasFocus;
        final bool hasValue = _controllers[index].text.isNotEmpty;

        return Padding(
          padding: EdgeInsets.only(right: index < 3 ? 16 : 0),
          child: _buildSingleInput(index, isFocused, hasValue),
        );
      }),
    );
  }

  Widget _buildSingleInput(int index, bool isFocused, bool hasValue) {
    return Container(
      width: 64,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0x4C1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused
              ? const Color(0xFFA40EEA)
              : hasValue
                  ? const Color(0xFF7F0DF2)
                  : const Color(0xFF334155),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x4C7F0DF2),
            blurRadius: isFocused ? 20 : 15,
            offset: Offset.zero,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          maxLength: 1,
          textCapitalization: TextCapitalization.characters,
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            LengthLimitingTextInputFormatter(1),
          ],
          style: GoogleFonts.spaceGrotesk(
            color: hasValue
                ? const Color(0xFFA40EEA)
                : const Color(0xFF334155),
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) => _onKeyChanged(index, value),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary: Unirse a la sala
        GestureDetector(
          onTap: _isComplete ? _joinRoom : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: _isComplete
                  ? const Color(0xFFA40EEA)
                  : const Color(0xFFA40EEA).withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x337F0DF2),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: const Color(0x337F0DF2),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                  spreadRadius: -3,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Unirse a la sala',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Secondary: Crear mi propia sala
        GestureDetector(
          onTap: _createRoom,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Crear mi propia sala',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  color: const Color(0xFF94A3B8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerChip() {
    return BlocBuilder<IngresarCodigoBloc, IngresarCodigoState>(
      builder: (context, state) {
        final String chipUsername = state is IngresarCodigoLoaded
            ? state.user.username
            : 'Usuario';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0x661E293B),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: const Color(0x7F334155),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE967),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.black54, size: 18),
              ),
              const SizedBox(width: 12),

              // "Jugando como Majito"
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Jugando como ',
                      style: GoogleFonts.spaceGrotesk(
                        color: const Color(0xFFE2E8F0),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.43,
                      ),
                    ),
                    TextSpan(
                      text: chipUsername,
                      style: GoogleFonts.spaceGrotesk(
                        color: const Color(0xFFFF6B00),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Edit icon
              const Icon(Icons.edit_outlined, color: Color(0xFF64748B), size: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 34),
      decoration: BoxDecoration(
        color: const Color(0xFF22172D),
        border: Border.all(color: const Color(0x197F0DF2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNavItem(icon: Icons.home_outlined, label: 'Inicio', index: 0),
          _buildNavItem(icon: Icons.sports_esports, label: 'Juegos', index: 1),
          _buildNavItem(icon: Icons.group_outlined, label: 'Social', index: 2),
          _buildNavItem(icon: Icons.person_outline, label: 'Perfil', index: 3),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    // "Juegos" is active on this screen
    final bool isActive = index == 1;
    final Color activeColor = const Color(0xFFA40EEA);
    final Color inactiveColor = const Color(0xFFAB9CBA);

    return GestureDetector(
      onTap: () {
        if (index == 3) {
          Navigator.pushNamed(context, AppRoutes.home);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? activeColor : inactiveColor, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                color: isActive ? activeColor : inactiveColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.50,
                letterSpacing: 0.30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}