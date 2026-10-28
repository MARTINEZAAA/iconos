import 'package:flutter/material.dart';

void main() {
  runApp(const SocialDemoApp());
}

class SocialDemoApp extends StatelessWidget {
  const SocialDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peoples, Chats & Calls',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
          surface: const Color(0xFF1C1B22),
        ),
        scaffoldBackgroundColor: const Color(0xFF111116),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Person> _people = [
    const Person('Sofia Ramirez', 'Disponible', Color(0xFFB05B79), true),
    const Person('Mateo Garcia', 'En una reunion', Color(0xFF5476A8), false),
    const Person('Valentina Cruz', 'Disponible', Color(0xFF68936E), true),
    const Person('Diego Torres', 'Desconectado', Color(0xFFB08045), false),
    const Person('Camila Flores', 'Disponible', Color(0xFF7B65A8), true),
    const Person('Nicolas Herrera', 'Desconectado', Color(0xFF4F8E91), false),
    const Person('Lucia Morales', 'Disponible', Color(0xFFBC6C57), true),
  ];

  final List<ChatPreview> _chats = [
    const ChatPreview('Sofia Ramirez', 'Nos vemos a las 6?', '10:42', 2),
    const ChatPreview('Mateo Garcia', 'Perfecto, muchas gracias', 'Ayer', 0),
    const ChatPreview('Valentina Cruz', 'Te envie las fotos', 'Ayer', 1),
    const ChatPreview('Diego Torres', 'Hablamos luego', 'Lun', 0),
    const ChatPreview('Camila Flores', 'Que buena idea!', 'Dom', 0),
  ];

  void _addContact(String name) {
    final colors = [
      const Color(0xFFB05B79),
      const Color(0xFF5476A8),
      const Color(0xFF68936E),
      const Color(0xFF7B65A8),
      const Color(0xFF4F8E91),
    ];
    setState(() {
      _people.insert(
        0,
        Person(
            name, 'Disponible', colors[_people.length % colors.length], true),
      );
    });
  }

  void _addConversation(Person person) {
    setState(() {
      if (!_chats.any((chat) => chat.name == person.name)) {
        _chats.insert(
            0, ChatPreview(person.name, 'Nueva conversacion', 'Ahora', 0));
      }
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      PeoplesPage(
        people: _people,
        onAddContact: _addContact,
        onStartChat: _addConversation,
      ),
      ChatsPage(
        people: _people,
        chats: _chats,
        onNewConversation: _addConversation,
      ),
      CallsPage(people: _people),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Peoples',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call_outlined),
            activeIcon: Icon(Icons.call),
            label: 'Calls',
          ),
        ],
      ),
    );
  }
}

class PeoplesPage extends StatelessWidget {
  const PeoplesPage({
    required this.people,
    required this.onAddContact,
    required this.onStartChat,
    super.key,
  });

  final List<Person> people;
  final ValueChanged<String> onAddContact;
  final ValueChanged<Person> onStartChat;

  @override
  Widget build(BuildContext context) {
    return _PageScaffold(
      title: 'Peoples',
      subtitle: 'Encuentra a tus personas',
      action: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Buscar personas',
            onPressed: () => _showMessage(context, 'Busqueda simulada'),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Agregar contacto',
            onPressed: () async {
              final name = await _showNewContactDialog(context);
              if (name != null) onAddContact(name);
            },
            icon: const Icon(Icons.person_add_alt_1),
          ),
        ],
      ),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: people.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final person = people[index];
          return _PersonTile(
            person: person,
            trailing: IconButton(
              tooltip: 'Iniciar chat con ${person.name}',
              onPressed: () => onStartChat(person),
              icon: const Icon(Icons.chat_outlined),
            ),
          );
        },
      ),
    );
  }
}

class ChatsPage extends StatelessWidget {
  const ChatsPage({
    required this.people,
    required this.chats,
    required this.onNewConversation,
    super.key,
  });

  final List<Person> people;
  final List<ChatPreview> chats;
  final ValueChanged<Person> onNewConversation;

  @override
  Widget build(BuildContext context) {
    return _PageScaffold(
      title: 'Chats',
      subtitle: 'Tus conversaciones recientes',
      action: IconButton(
        tooltip: 'Nueva conversacion',
        onPressed: () async {
          final person = await _showNewConversationDialog(context, people);
          if (person != null) onNewConversation(person);
        },
        icon: const Icon(Icons.edit_square),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: chats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final chat = chats[index];
          final person = people.firstWhere(
            (person) => person.name == chat.name,
          );
          return _PersonTile(
            person: person,
            subtitle: Text(chat.lastMessage),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.time,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                if (chat.unreadCount > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${chat.unreadCount}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            onTap: () => _showMessage(
              context,
              'Conversacion con ${chat.name} (simulada)',
            ),
          );
        },
      ),
    );
  }
}

class CallsPage extends StatelessWidget {
  const CallsPage({required this.people, super.key});

  final List<Person> people;

  static const List<CallRecord> _calls = [
    CallRecord('Sofia Ramirez', 'Hoy, 10:15', true, true),
    CallRecord('Mateo Garcia', 'Ayer, 18:32', false, true),
    CallRecord('Valentina Cruz', 'Ayer, 14:08', true, false),
    CallRecord('Diego Torres', 'Lunes, 09:45', false, false),
  ];

  @override
  Widget build(BuildContext context) {
    return _PageScaffold(
      title: 'Calls',
      subtitle: 'Tu actividad de llamadas',
      action: IconButton(
        tooltip: 'Iniciar llamada',
        onPressed: () => _showMessage(context, 'Llamada nueva (simulada)'),
        icon: const Icon(Icons.add_call),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: _calls.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final call = _calls[index];
          final person = people.firstWhere(
            (person) => person.name == call.name,
          );
          return _PersonTile(
            person: person,
            subtitle: Row(
              children: [
                Icon(
                  call.wasIncoming ? Icons.call_received : Icons.call_made,
                  size: 16,
                  color: call.wasAnswered
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 6),
                Text(call.date),
              ],
            ),
            trailing: IconButton(
              tooltip: 'Llamar a ${call.name}',
              onPressed: () => _showMessage(
                context,
                'Llamada con ${call.name} (simulada)',
              ),
              icon: const Icon(Icons.call_outlined),
            ),
          );
        },
      ),
    );
  }
}

class _PageScaffold extends StatelessWidget {
  const _PageScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              if (action != null) action!,
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({
    required this.person,
    required this.trailing,
    this.subtitle,
    this.onTap,
  });

  final Person person;
  final Widget trailing;
  final Widget? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: _PersonAvatar(person: person),
        title: Text(
          person.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle ??
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 9,
                  color:
                      person.isOnline ? const Color(0xFF40A56B) : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(person.status),
              ],
            ),
        trailing: trailing,
      ),
    );
  }
}

class _PersonAvatar extends StatelessWidget {
  const _PersonAvatar({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final initials =
        person.name.split(' ').take(2).map((part) => part[0]).join();
    return CircleAvatar(
      backgroundColor: person.color,
      foregroundColor: Colors.white,
      child:
          Text(initials, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class Person {
  const Person(this.name, this.status, this.color, this.isOnline);

  final String name;
  final String status;
  final Color color;
  final bool isOnline;
}

class ChatPreview {
  const ChatPreview(
    this.name,
    this.lastMessage,
    this.time,
    this.unreadCount,
  );

  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
}

class CallRecord {
  const CallRecord(this.name, this.date, this.wasIncoming, this.wasAnswered);

  final String name;
  final String date;
  final bool wasIncoming;
  final bool wasAnswered;
}

Future<String?> _showNewContactDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const _NewContactDialog(),
  );
}

class _NewContactDialog extends StatefulWidget {
  const _NewContactDialog();

  @override
  State<_NewContactDialog> createState() => _NewContactDialogState();
}

class _NewContactDialogState extends State<_NewContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_nameController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar contacto'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            hintText: 'Escribe el nombre del contacto',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Escribe un nombre';
            }
            return null;
          },
          onFieldSubmitted: (_) => _save(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

Future<Person?> _showNewConversationDialog(
  BuildContext context,
  List<Person> people,
) {
  return showDialog<Person>(
    context: context,
    builder: (_) => _NewConversationDialog(people: people),
  );
}

class _NewConversationDialog extends StatefulWidget {
  const _NewConversationDialog({required this.people});

  final List<Person> people;

  @override
  State<_NewConversationDialog> createState() => _NewConversationDialogState();
}

class _NewConversationDialogState extends State<_NewConversationDialog> {
  Person? _selectedPerson;

  @override
  void initState() {
    super.initState();
    if (widget.people.isNotEmpty) {
      _selectedPerson = widget.people.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva conversacion'),
      content: widget.people.isEmpty
          ? const Text('Agrega un contacto antes de iniciar una conversacion.')
          : DropdownButtonFormField<Person>(
              initialValue: _selectedPerson,
              decoration: const InputDecoration(
                labelText: 'Contacto',
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: widget.people
                  .map(
                    (person) => DropdownMenuItem(
                      value: person,
                      child: Text(person.name),
                    ),
                  )
                  .toList(),
              onChanged: (person) => setState(() => _selectedPerson = person),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _selectedPerson == null
              ? null
              : () => Navigator.of(context).pop(_selectedPerson),
          child: const Text('Crear'),
        ),
      ],
    );
  }
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
