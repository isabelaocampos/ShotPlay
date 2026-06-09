enum SpecialCellType {
  takeShot,
  giveShot,
  truthOrDare,
  waterfall,
  splitShots,
  giveShots,
  revengeShot,
  neverHaveIEver,
  mostLikelyTo,
  trapCell,
  silentRound,
}

extension SpecialCellTypeX on SpecialCellType {
  String get label => switch (this) {
        SpecialCellType.takeShot => 'Take 2 shots',
        SpecialCellType.giveShot => 'Give shot',
        SpecialCellType.truthOrDare => 'Truth or Dare',
        SpecialCellType.waterfall => 'WATERFALL',
        SpecialCellType.splitShots => 'Split 4 shots',
        SpecialCellType.giveShots => 'GIVE 2 SHOTS',
        SpecialCellType.revengeShot => 'REVENGE SHOT',
        SpecialCellType.neverHaveIEver => 'Never Have I Ever',
        SpecialCellType.mostLikelyTo => 'Most Likely To',
        SpecialCellType.trapCell => 'TRAP CELL',
        SpecialCellType.silentRound => 'SILENT ROUND',
      };
}