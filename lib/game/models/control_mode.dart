/// Supported player control modes.
enum ControlMode {
  swipe('SWIPE'),
  buttons('BUTTONS');

  final String label;

  const ControlMode(this.label);
}
