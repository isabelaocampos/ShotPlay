import 'dart:math';

class ChallengeCard {
  const ChallengeCard({
    required this.title,
    required this.prompt,
  });

  final String title;
  final String prompt;

  static const _neverHaveIEverPrompts = [
    'Never have I ever lied to get out of class.',
    'Never have I ever sent a text to the wrong person.',
    'Never have I ever pretended to know a song just to fit in.',
    'Never have I ever stalked an ex on social media.',
  ];

  static const _mostLikelyToPrompts = [
    'Who is most likely to text their ex tonight?',
    'Who is most likely to start a fight over a meme?',
    'Who is most likely to forget their own birthday?',
    'Who is most likely to dance before the chorus starts?',
  ];

  static ChallengeCard randomNeverHaveIEver() {
    final index = Random().nextInt(_neverHaveIEverPrompts.length);
    return ChallengeCard(
      title: 'Never have I ever...',
      prompt: _neverHaveIEverPrompts[index],
    );
  }

  static ChallengeCard randomMostLikelyTo() {
    final index = Random().nextInt(_mostLikelyToPrompts.length);
    return ChallengeCard(
      title: 'Who is most likely to...',
      prompt: _mostLikelyToPrompts[index],
    );
  }
}