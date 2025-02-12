class CStep {
  int id;
  int rawId;
  String title;
  bool isChecked;

  CStep(
    this.id,
    this.rawId,
    this.title,
    [this.isChecked = false]
  );
}