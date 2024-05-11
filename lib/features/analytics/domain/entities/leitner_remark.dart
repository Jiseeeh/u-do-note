class LeitnerSystemRemarkEntity {
  final String? id;
  final List<String> remarks;
  final List<int> scores;

  LeitnerSystemRemarkEntity({
    this.id,
    required this.remarks,
    required this.scores,
  });
}
