import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SalaEsperaScreen extends StatefulWidget {
  const SalaEsperaScreen({super.key});

  @override
  State<SalaEsperaScreen> createState() => _SalaEsperaScreenState();
}

class _SalaEsperaScreenState extends State<SalaEsperaScreen> {
  late String _roomCode;

  @override
  void initState() {
    super.initState();
    _roomCode = _generateRoomCode();
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(4, (_) => chars[random.nextInt(chars.length)]).join();
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: _roomCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Código copiado al portapapeles',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
        backgroundColor: const Color(0xFFA40EEA),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191022),
      body: Stack(
        children: [
          // Top header
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            child: _buildHeader(),
          ),

          // Main scrollable content
          Positioned(
            left: 0,
            top: 104,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 47, left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF191022),
        border: Border.all(color: const Color(0x197F0DF2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
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
          const SizedBox(width: 16),
          Text(
            'Sala de espera',
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFFF1F5F9),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.25,
              letterSpacing: -0.27,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          // Decorative glowing circles
          Positioned(
            right: -96,
            top: -96,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                color: const Color(0x197F0DF2),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          Positioned(
            left: -116,
            top: 715,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                color: const Color(0x197F0DF2),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildRoomCodeSection(),
              const SizedBox(height: 20),
              _buildPlayersHeader(),
              const SizedBox(height: 12),
              _buildPlayersList(),
              const SizedBox(height: 24),
              _buildStartSection(),
              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCodeSection() {
    return Column(
      children: [
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -4,
                top: -4,
                right: -4,
                bottom: -4,
                child: Opacity(
                  opacity: 0.25,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7F0DF2), Color(0xFFC084FC)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _roomCode,
                  style: GoogleFonts.spaceGrotesk(
                    color: const Color(0xFFA40EEA),
                    fontSize: 60,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    letterSpacing: 6,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'CÓDIGO SALA',
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.50,
            letterSpacing: 2.80,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _copyLink,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x197F0DF2),
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: const Color(0x337F0DF2), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.copy_outlined,
                  color: Color(0xFFA40EEA),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'COPIAR LINK',
                  style: GoogleFonts.spaceGrotesk(
                    color: const Color(0xFFA40EEA),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayersHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Jugadores conectados',
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFFF1F5F9),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.25,
            letterSpacing: -0.50,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFA40EEA),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Text(
            '2 / 4',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.33,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayersList() {
    return Column(
      children: [
        _buildPlayerCard(
          name: 'Majito (Host)',
          status: 'Listo para jugar',
          statusColor: const Color(0xFFA40EEA),
          avatarBgColor: const Color(0xFFFEE967),
          isHost: true,
          indicatorColor: null,
        ),
        const SizedBox(height: 8),
        _buildPlayerCard(
          name: 'Daniel',
          status: 'Conectado',
          statusColor: const Color(0xFF94A3B8),
          avatarBgColor: const Color(0xFFBFFBF9),
          isHost: false,
          indicatorColor: const Color(0xFF22C55E),
        ),
        const SizedBox(height: 8),
        _buildPlayerCard(
          name: 'Sara',
          status: 'Uniéndose...',
          statusColor: const Color(0xFF94A3B8),
          avatarBgColor: const Color(0xFFFFBDF5),
          isHost: false,
          indicatorColor: const Color(0xFFF59E0B),
        ),
        const SizedBox(height: 8),
        _buildEmptySlot(),
      ],
    );
  }

  Widget _buildPlayerCard({
    required String name,
    required String status,
    required Color statusColor,
    required Color avatarBgColor,
    required bool isHost,
    required Color? indicatorColor,
  }) {
    return Container(
      width: double.infinity,
      height: 82,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHost ? const Color(0x7F1E293B) : const Color(0x4C1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHost ? const Color(0xFF334155) : const Color(0xFF1E293B),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: avatarBgColor,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Container(
                    color: avatarBgColor,
                    child: Center(
                      child: Icon(
                        Icons.person,
                        color: Colors.black.withOpacity(0.3),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color(0xFFF1F5F9),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.50,
                    ),
                  ),
                  Text(
                    status,
                    style: GoogleFonts.spaceGrotesk(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: isHost ? FontWeight.w500 : FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isHost)
            const Icon(
              Icons.workspace_premium,
              color: Color(0xFFA40EEA),
              size: 22,
            )
          else if (indicatorColor != null)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: indicatorColor.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptySlot() {
    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1E293B),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          'Esperando más jugadores ...',
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFF475569),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.43,
          ),
        ),
      ),
    );
  }

  Widget _buildStartSection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFA40EEA),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x667F0DF2),
                blurRadius: 20,
                offset: Offset(0, 0),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'INICIAR PARTIDA',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Minimum 3 players required to start the game',
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.33,
          ),
        ),
      ],
    );
  }
}
