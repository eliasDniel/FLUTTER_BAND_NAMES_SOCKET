class Band {
  final String id;
  final String name;
  final int votes;
  Band({required this.id, required this.name, required this.votes});

  factory Band.fromMap(Map<String, dynamic> obj) => Band(
    id: obj['id'] ?? '',
    name: obj['name'] ?? '',
    votes: obj['votes'] ?? 0,
  );

  Map<String, dynamic> get to => {
    'id': id,
    'name': name,
    'votes': votes,
  };
}
