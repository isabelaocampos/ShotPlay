import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:shotplay_app/src/common_widgets/room_code_input.dart';

import 'package:shotplay_app/src/core/constants/room_code_constants.dart';

import 'package:shotplay_app/src/core/routing/app_routes.dart';

import 'package:shotplay_app/src/core/routing/game_navigator.dart';

import 'package:shotplay_app/src/core/utils/supabase_safe.dart';

import 'package:shotplay_app/src/domain/entities/room_entry_destination.dart';

import 'package:shotplay_app/src/features/enter_code/ui/bloc/enter_code_bloc.dart';



/// Bottom-sheet modal that lets a user enter a 6-character room code.

class EnterCodeScreen extends StatefulWidget {

  const EnterCodeScreen({

    super.key,

    required this.gameName,

    this.expectedGameId,

  });



  final String gameName;

  final int? expectedGameId;



  @override

  State<EnterCodeScreen> createState() => _EnterCodeScreenState();

}



class _EnterCodeScreenState extends State<EnterCodeScreen> {

  String _code = '';



  bool get _isComplete => RoomCodeConstants.isValid(_code);



  @override

  void initState() {

    super.initState();

    final userId = safeCurrentUserId();

    if (userId != null) {

      context.read<EnterCodeBloc>().add(EnterCodeLoadRequested(userId));

    }

  }



  void _onCodeChanged(String code) {

    setState(() => _code = code);

  }



  void _joinRoom() {

    if (!_isComplete) return;



    context.read<EnterCodeBloc>().add(

          EnterCodeJoinRequested(

            roomCode: RoomCodeConstants.normalize(_code),

            expectedGameId: widget.expectedGameId,

          ),

        );

  }



  @override

  Widget build(BuildContext context) {

    return BlocListener<EnterCodeBloc, EnterCodeState>(

      listener: (context, state) {

        if (state is EnterCodeJoinSuccess) {

          final navigator = Navigator.of(context);

          final result = state.result;

          final currentUserId = safeCurrentUserId();

          final isAdmin = currentUserId != null &&

              currentUserId == result.room.adminId;



          navigator.pop();



          switch (result.destination) {

            case RoomEntryDestination.waitingRoom:

              navigator.pushNamed(

                AppRoutes.waitingRoom,

                arguments: result.room,

              );

              break;

            case RoomEntryDestination.snakesGame:

            case RoomEntryDestination.impostorGame:

              GameNavigator.pushGame(

                context: context,

                room: result.room,

                players: result.players,

                isAdmin: isAdmin,

                isReconnect: result.isReconnect,

                persistedGameState: result.persistedGameState,

              );

              break;

            case RoomEntryDestination.roomFinished:

              ScaffoldMessenger.of(context).showSnackBar(

                const SnackBar(

                  content: Text('Esta partida ya finalizó.'),

                ),

              );

              break;

          }

        } else if (state is EnterCodeError) {

          ScaffoldMessenger.of(context).showSnackBar(

            SnackBar(content: Text(state.message)),

          );

        }

      },

      child: BlocBuilder<EnterCodeBloc, EnterCodeState>(

        builder: (context, state) {

          final joining = state is EnterCodeJoining;



          return Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              Container(

                margin: const EdgeInsets.only(top: 12, bottom: 8),

                width: 36,

                height: 4,

                decoration: BoxDecoration(

                  color: Colors.white24,

                  borderRadius: BorderRadius.circular(99),

                ),

              ),

              Padding(

                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),

                child: Row(

                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [

                    Text(

                      widget.gameName,

                      style: GoogleFonts.spaceGrotesk(

                        color: const Color(0xFFF1F5F9),

                        fontSize: 16,

                        fontWeight: FontWeight.w700,

                        letterSpacing: -0.4,

                      ),

                    ),

                    const Icon(Icons.ios_share,

                        color: Color(0xFFF1F5F9), size: 20),

                  ],

                ),

              ),

              const Divider(color: Color(0x197F0DF2), height: 16),

              Padding(

                padding: EdgeInsets.only(

                  top: 24,

                  left: 24,

                  right: 24,

                  bottom: MediaQuery.of(context).viewInsets.bottom + 32,

                ),

                child: Column(

                  children: [

                    _buildTitleSection(),

                    const SizedBox(height: 32),

                    RoomCodeInput(

                      enabled: !joining,

                      autofocus: true,

                      onChanged: _onCodeChanged,

                    ),

                    const SizedBox(height: 32),

                    _buildJoinButton(joining: joining),

                    const SizedBox(height: 24),

                    _buildPlayerChip(),

                  ],

                ),

              ),

            ],

          );

        },

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

            fontSize: 26,

            fontWeight: FontWeight.w700,

            letterSpacing: -0.65,

          ),

        ),

        const SizedBox(height: 10),

        Text(

          'Ingresa el código de 6 caracteres que te\ncompartió tu amigo',

          textAlign: TextAlign.center,

          style: GoogleFonts.spaceGrotesk(

            color: const Color(0xFF94A3B8),

            fontSize: 14,

            fontWeight: FontWeight.w400,

            height: 1.6,

          ),

        ),

      ],

    );

  }



  Widget _buildJoinButton({required bool joining}) {

    final enabled = _isComplete && !joining;



    return GestureDetector(

      onTap: enabled ? _joinRoom : null,

      child: Container(

        width: double.infinity,

        padding: const EdgeInsets.symmetric(vertical: 18),

        decoration: BoxDecoration(

          color: enabled

              ? const Color(0xFFA40EEA)

              : const Color(0xFFA40EEA).withValues(alpha: 0.4),

          borderRadius: BorderRadius.circular(16),

          boxShadow: enabled

              ? const [

                  BoxShadow(

                    color: Color(0x337F0DF2),

                    blurRadius: 15,

                    offset: Offset(0, 6),

                  ),

                ]

              : null,

        ),

        child: Row(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            if (joining) ...[

              const SizedBox(

                width: 18,

                height: 18,

                child: CircularProgressIndicator(

                  strokeWidth: 2,

                  color: Colors.white,

                ),

              ),

              const SizedBox(width: 10),

            ],

            Text(

              joining ? 'Uniéndose...' : 'Unirse a la sala',

              style: GoogleFonts.spaceGrotesk(

                color: Colors.white,

                fontSize: 16,

                fontWeight: FontWeight.w700,

              ),

            ),

            if (!joining) ...[

              const SizedBox(width: 8),

              const Icon(Icons.play_arrow, color: Colors.white, size: 20),

            ],

          ],

        ),

      ),

    );

  }



  Widget _buildPlayerChip() {

    return BlocBuilder<EnterCodeBloc, EnterCodeState>(

      builder: (context, state) {

        final String chipUsername = switch (state) {

          EnterCodeLoaded(:final user) => user.username,

          EnterCodeJoining(:final user) => user.username,

          _ => 'Usuario',

        };



        return Container(

          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

          decoration: BoxDecoration(

            color: const Color(0x661E293B),

            borderRadius: BorderRadius.circular(9999),

            border: Border.all(color: const Color(0x7F334155)),

          ),

          child: Row(

            mainAxisSize: MainAxisSize.min,

            children: [

              Container(

                width: 30,

                height: 30,

                decoration: const BoxDecoration(

                  color: Color(0xFFFEE967),

                  shape: BoxShape.circle,

                ),

                child:

                    const Icon(Icons.person, color: Colors.black54, size: 16),

              ),

              const SizedBox(width: 10),

              Text.rich(

                TextSpan(

                  children: [

                    TextSpan(

                      text: 'Jugando como ',

                      style: GoogleFonts.spaceGrotesk(

                        color: const Color(0xFFE2E8F0),

                        fontSize: 13,

                        fontWeight: FontWeight.w500,

                      ),

                    ),

                    TextSpan(

                      text: chipUsername,

                      style: GoogleFonts.spaceGrotesk(

                        color: const Color(0xFFFF6B00),

                        fontSize: 13,

                        fontWeight: FontWeight.w600,

                      ),

                    ),

                  ],

                ),

              ),

              const SizedBox(width: 10),

              const Icon(Icons.edit_outlined,

                  color: Color(0xFF64748B), size: 14),

            ],

          ),

        );

      },

    );

  }

}

