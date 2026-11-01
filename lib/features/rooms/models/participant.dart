class Participant {
  final String id;
  final String name;
  final String avatarUrl; // can be asset or network
  bool muted;
  bool locked;

  Participant({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.muted = false,
    this.locked = false,
  });
}
