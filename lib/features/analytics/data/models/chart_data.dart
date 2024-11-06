class ChartData {
  final String reviewMethod;
  final int usage;

  const ChartData(this.reviewMethod, this.usage);

  @override
  String toString() {
    return "Review method: $reviewMethod\n usage: $usage";
  }
}
