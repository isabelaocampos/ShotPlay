import 'dart:math';

class ChallengeCard {
  const ChallengeCard({
    required this.title,
    required this.prompt,
  });

  final String title;
  final String prompt;

  static const _neverHaveIEverPrompts = [
    'Yo nunca le he mentido a alguien para salir de clase.',
    'Yo nunca le he escrito un mensaje al contacto equivocado.',
    'Yo nunca he fingido conocer una canción para encajar.',
    'Yo nunca le he revisado el perfil a un ex en redes sociales.',
  ];

  static const _mostLikelyToPrompts = [
    'Quien es mas probable que le escriba a su ex esta noche?',
    'Quien es mas probable que pelee por un meme?',
    'Quien es mas probable que se olvide de su propio cumpleanos?',
    'Quien es mas probable que baile antes de que llegue el coro?',
  ];

  static ChallengeCard randomNeverHaveIEver() {
    final index = Random().nextInt(_neverHaveIEverPrompts.length);
    return ChallengeCard(
      title: 'Yo nunca...',
      prompt: _neverHaveIEverPrompts[index],
    );
  }

  static ChallengeCard randomMostLikelyTo() {
    final index = Random().nextInt(_mostLikelyToPrompts.length);
    return ChallengeCard(
      title: 'Quien es mas probable que...',
      prompt: _mostLikelyToPrompts[index],
    );
  }
}