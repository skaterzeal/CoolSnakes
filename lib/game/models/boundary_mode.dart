/// Boundary mode determining world edge behavior.
enum BoundaryMode {
  wrap('WRAP'),
  border('BORDER');

  final String label;

  const BoundaryMode(this.label);
}
