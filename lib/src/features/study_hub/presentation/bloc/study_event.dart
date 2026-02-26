/// Events represent user actions or system triggers that the BLoC listens to.
/// In clean architecture, events are the INPUT to the presentation layer.
/// Think of events as "commands" that tell the BLoC what to do.
///
/// Example flow: User taps a "Load Studies" button → StudyLoadRequested event is created
/// → BLoC listens for this event → BLoC processes it and emits new states
abstract class StudyEvent {
  const StudyEvent();
}

/// StudyLoadRequested: Triggered when the app needs to load the list of study items.
/// This event tells the BLoC: "Hey, please go fetch the studies from the domain layer!"
///
/// Where it's used: In StudyHomePage.initState() when the page first loads
class StudyLoadRequested extends StudyEvent {
  const StudyLoadRequested();
}
