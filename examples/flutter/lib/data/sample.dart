import 'package:plass_ui/plass_ui.dart';

/// One person in the sample data. Every name is made up.
class Person {
  /// Creates a person.
  const Person(this.name, this.image);

  /// What they are called.
  final String name;

  /// The asset of their picture, if they have one.
  final String? image;
}

/// The people who send messages.
const List<Person> people = <Person>[
  Person('Nadia Rowan', 'assets/images/nadia-rowan.webp'),
  Person('Theo Quinn', 'assets/images/theo-quinn.webp'),
  Person('Anya Sol', 'assets/images/anya-sol.webp'),
  Person('Lucas Adebayo', 'assets/images/lucas-adebayo.webp'),
  Person('Noa Marin', 'assets/images/noa-marin.webp'),
  Person('Ines Holm', null),
];

/// One conversation in the inbox.
class Conversation {
  /// Creates a conversation.
  const Conversation(this.person, this.subject, this.preview, this.time, this.unread);

  /// Who it is with.
  final Person person;

  /// What it is about.
  final String subject;

  /// The start of the latest message.
  final String preview;

  /// When the latest message came.
  final String time;

  /// How many messages are unread.
  final int unread;
}

/// Every conversation.
final List<Conversation> conversations = <Conversation>[
  Conversation(
    people[0],
    'Spring release',
    'The gradient turns rather than shades. Have a look at the new fills before Friday.',
    '09:12',
    3,
  ),
  Conversation(people[1], 'Invoice INV-0104', 'Paid in full, thank you.', '08:47', 0),
  Conversation(people[2], 'Design review', 'Can we move it to Thursday afternoon?', 'Mon', 1),
  Conversation(people[3], 'Offsite', 'Train tickets are booked for all of us.', 'Mon', 0),
  Conversation(people[4], 'New hire', 'Their first day is the third of next month.', 'Sun', 0),
  Conversation(people[5], 'Support rota', 'I can cover the weekend.', 'Sat', 0),
];

/// One order in the table.
class Order {
  /// Creates an order.
  const Order(this.id, this.customer, this.status, this.total);

  /// Its number.
  final String id;

  /// Who placed it.
  final String customer;

  /// Where it has got to.
  final String status;

  /// What it came to.
  final double total;
}

const List<String> _customers = <String>['Acme Inc', 'Globex', 'Initech', 'Soylent', 'Umbrella'];
const List<String> _statuses = <String>['Paid', 'Open', 'Paid', 'Overdue'];

/// Every order.
final List<Order> orders = <Order>[
  for (var index = 0; index < 23; index += 1)
    Order(
      'INV-${(104 - index).toString().padLeft(4, '0')}',
      _customers[index % _customers.length],
      _statuses[index % _statuses.length],
      89.5 + index * 137.25,
    ),
];

/// The colour each order status is shown in.
const Map<String, PlassColor> statusColors = <String, PlassColor>{
  'Paid': PlassColor.success,
  'Open': PlassColor.primary,
  'Overdue': PlassColor.danger,
};

/// The local pictures.
const List<(String, String)> photos = <(String, String)>[
  ('assets/images/alpine-lake-dawn.webp', 'A still mountain lake at first light'),
  ('assets/images/forest-trail-sunbeams.webp', 'Sunbeams across a forest trail'),
  ('assets/images/lighthouse-cliff-wildflowers.webp', 'A lighthouse above wildflowers'),
  ('assets/images/rowboat-misty-pond-sunrise.webp', 'A rowboat on a misty pond'),
  ('assets/images/ceramic-bowl-citrus.webp', 'A ceramic bowl of citrus'),
  ('assets/images/greenhouse-fern-shadows.webp', 'Fern shadows in a greenhouse'),
];
