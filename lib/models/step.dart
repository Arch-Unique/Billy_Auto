class CStep {
  int id;
  String title;
  bool isExpanded;

  CStep(
    this.id,
    this.title,
    [this.isExpanded = false]
  );
}