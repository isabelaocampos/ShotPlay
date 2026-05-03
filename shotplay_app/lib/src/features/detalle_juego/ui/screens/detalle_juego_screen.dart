import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetalleDelJuegoScreen extends StatefulWidget {
  const DetalleDelJuegoScreen({super.key});

  @override
  State<DetalleDelJuegoScreen> createState() => _DetalleDelJuegoScreenState();
}

class _DetalleDelJuegoScreenState extends State<DetalleDelJuegoScreen> {
  int _selectedNavIndex = 1; // "Juegos" tab active by default

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
            bottom: 87,
            child: SingleChildScrollView(
              child: _buildContent(),
            ),
          ),

          // Bottom navigation bar
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
      padding: const EdgeInsets.only(top: 47, left: 16, right: 16, bottom: 16),
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
              'Detalles del Juego',
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
    return Container(
      padding: const EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildGameImageCard(),
          const SizedBox(height: 16),
          _buildGameInfo(),
          const SizedBox(height: 16),
          _buildStatsRow(),
          const SizedBox(height: 16),
          _buildActionButtons(),
          const SizedBox(height: 16),
          _buildActiveRoomsSection(),
        ],
      ),
    );
  }

  Widget _buildGameImageCard() {
    return SizedBox(
      width: double.infinity,
      height: 201,
      child: Stack(
        children: [
          // Game image / placeholder
          Container(
            width: double.infinity,
            height: 201,
            decoration: BoxDecoration(
              color: const Color(0xFF2D1B3D),
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: AssetImage('assets/images/escaleras_serpientes.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Gradient overlay (bottom to transparent)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.60),
                    Colors.black.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          // POPULAR badge
          Positioned(
            left: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF339A),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                'POPULAR',
                style: GoogleFonts.spaceGrotesk(
                  color: const Color(0xFFF1F5F9),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                  letterSpacing: 1.20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Escaleras & Serpientes',
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFFF1F5F9),
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Un clásico emocionante de mesa reinventado\npara ShotPlay. Sube por las escaleras para\nalcanzar la gloria o deslízate por las\nserpientes en este juego de azar y estrategia\nligera. ¡Ideal para reuniones rápidas con\namigos!',
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFF94A3B8),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.63,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard(
          icon: Icons.group,
          label: 'JUGADORES',
          value: '2-4 personas',
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(
          icon: Icons.access_time,
          label: 'DURACIÓN',
          value: '~15 min',
        )),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x0CA50EEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0x33A50EEB),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFFA40EEA),
            size: 22,
          ),
          const SizedBox(height: 8),
          Opacity(
            opacity: 0.60,
            child: Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0xFFF1F5F9),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.43,
                letterSpacing: 0.70,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFFF1F5F9),
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 1.56,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crear sala — primary
          GestureDetector(
            onTap: () {
              // Navigate to sala de espera (host flow)
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFA40EEA),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x667F0DF2),
                    blurRadius: 15,
                    offset: Offset(0, 0),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle_outline, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Crear sala',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.56,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Unirse a sala — secondary
          GestureDetector(
            onTap: () {
              // Navigate to join sala flow
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0x19A50EEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0x66A50EEB),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.login, color: Color(0xFFA40EEA), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Unirse a sala',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color(0xFFA40EEA),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.56,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRoomsSection() {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              const Icon(
                Icons.circle,
                color: Color(0xFF22C55E),
                size: 10,
              ),
              const SizedBox(width: 8),
              Text(
                'Salas activas ahora',
                style: GoogleFonts.spaceGrotesk(
                  color: const Color(0xFFF1F5F9),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Room cards
          Column(
            children: [
              _buildRoomCard(
                roomName: 'Sala de Rodrigo',
                playerCount: '3/6 jugadores',
              ),
              const SizedBox(height: 12),
              _buildRoomCard(
                roomName: 'La Guarida Gamer',
                playerCount: '5/6 jugadores',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard({
    required String roomName,
    required String playerCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x0CA50EEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0x33A50EEB),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              // Avatar placeholder
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0x33A50EEB),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0x4CA50EEB),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFFA40EEA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Room info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roomName,
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color(0xFFF1F5F9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.43,
                    ),
                  ),
                  Text(
                    playerCount,
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Join button
          GestureDetector(
            onTap: () {
              // Join this room
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0x33A50EEB),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: const Color(0x4CA50EEB),
                  width: 1,
                ),
              ),
              child: Text(
                'Unirse',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  color: const Color(0xFFA40EEA),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.only(
        top: 12,
        left: 16,
        right: 16,
        bottom: 34,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF22172D),
        border: Border.all(
          color: const Color(0x197F0DF2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNavItem(
            icon: Icons.home_outlined,
            label: 'Inicio',
            index: 0,
          ),
          _buildNavItem(
            icon: Icons.sports_esports,
            label: 'Juegos',
            index: 1,
          ),
          _buildNavItem(
            icon: Icons.group_outlined,
            label: 'Social',
            index: 2,
          ),
          _buildNavItem(
            icon: Icons.person_outline,
            label: 'Perfil',
            index: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isActive = _selectedNavIndex == index;
    final Color activeColor = const Color(0xFFA40EEA);
    final Color inactiveColor = const Color(0xFFAB9CBA);

    return GestureDetector(
      onTap: () => setState(() => _selectedNavIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: 24,
            ),
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