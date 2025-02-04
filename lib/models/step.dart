class CStep {
  int id;
  String title;
  bool isChecked;

  CStep(
    this.id,
    this.title,
    [this.isChecked = false]
  );
}