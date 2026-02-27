/// Counter Entity: Represents the counter value
///
/// This is the simplest possible domain entity.
/// It just holds a single integer value.
///
/// Why have an entity for something so simple?
/// - Consistency: All features follow the same architecture
/// - Future-proofing: If counter logic grows, we have a home for it
/// - Learning: See how even simple features fit into clean architecture
class Counter {
  final int value;

  const Counter({required this.value});
}
