import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lab3/models/ispit.dart';
import 'package:lab3/notifications.dart';
import 'package:lab3/screens/calendar_screen.dart';
import 'package:lab3/utils.dart';
import 'package:lab3/widget_tree.dart';

import 'auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'scheduler_channel',
        channelName: 'Scheduled Notifications',
        defaultColor: Colors.blueGrey,
        importance: NotificationImportance.High,
        channelDescription: '',
      ),
    ],
  );
  AwesomeNotifications().requestPermissionToSendNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '191279 Lab3',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WidgetTree(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Ispit> ispiti = [
    Ispit(
        ime: "Mobilni Platformi i Programiranje",
        datum: DateTime.now(),
        vreme: TimeOfDay.now()),
    Ispit(
        ime: "Mobilni Informaciski Sistemi",
        datum: DateTime.now(),
        vreme: TimeOfDay.now()),
  ];

  final TextEditingController _ime = TextEditingController();
  final TextEditingController _date = TextEditingController();
  final TextEditingController _vreme = TextEditingController();

  @override
  void initState() {
    createNotis();
    super.initState();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Allow Notifications'),
            content: const Text('Our app would like to send you notifications'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Don\'t Allow',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                ),
              ),
              TextButton(
                  onPressed: () => AwesomeNotifications()
                      .requestPermissionToSendNotifications()
                      .then((_) => Navigator.pop(context)),
                  child: const Text(
                    'Allow',
                    style: TextStyle(
                      color: Colors.teal,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ))
            ],
          ),
        );
      }
    });
    AwesomeNotifications().createdStream.listen((notification) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notification Created on ${notification.channelKey}'),
        ),
      );
    });
    AwesomeNotifications().actionStream.listen((notification) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => CalendarScreen(exams: ispiti),
          ),
          (route) => route.isFirst);
    });
  }

  void createNotis() {
    for (var element in ispiti) {
      if (element.datum.isTomorrow) {
        createExamDayBeforeNotification(element);
      }
    }
  }

  @override
  void dispose() {
    AwesomeNotifications().actionSink.close();
    AwesomeNotifications().createdSink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _createAppBar(),
      body: _createBody(),
    );
  }

  PreferredSizeWidget _createAppBar() {
    return AppBar(
      // The title text which will be shown on the action bar
      title: const Text("Lab3"),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _addItemFunction(context),
        ),
        IconButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => CalendarScreen(exams: ispiti))),
            icon: const Icon(Icons.calendar_month)),
        _signOutButton(),
      ],
    );
  }

  void _addListItemFunction(Ispit toAdd) {
    setState(() {
      ispiti.add(toAdd);
    });
  }

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  void _deleteItem(String ime) {
    setState(() {
      ispiti.removeWhere((elem) => elem.ime == ime);
    });
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
  }

  Widget _createBody() {
    return Center(
      child: ispiti.isEmpty
          ? const Text("Empty List")
          : ListView.builder(
              itemBuilder: (ctx, index) {
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                  child: ListTile(
                    title: Text(ispiti[index].ime,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    // ignore: prefer_interpolation_to_compose_strings
                    subtitle: Text(
                        '${DateFormat.yMMMEd().format(ispiti[index].datum)} ${ispiti[index].vreme.format(context)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteItem(ispiti[index].ime),
                    ),
                  ),
                );
              },
              itemCount: ispiti.length,
            ),
    );
  }

  void _addItemFunction(BuildContext ct) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _ime,
                      decoration: const InputDecoration(
                        labelText: "Ime na ispit",
                        icon: Icon(Icons.add_card),
                      ),
                    ),
                    TextField(
                      controller: _date,
                      decoration: const InputDecoration(
                        labelText: "Datum na ispit",
                        icon: Icon(Icons.calendar_today_rounded),
                      ),
                      onTap: () async {
                        DateTime? pickeddate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100));

                        if (pickeddate != null) {
                          setState(() {
                            _date.text =
                                DateFormat("yyyy-MM-dd").format(pickeddate);
                          });
                        }
                      },
                    ),
                    TextField(
                      controller: _vreme,
                      decoration: const InputDecoration(
                        labelText: "Vreme na ispit",
                        icon: Icon(Icons.lock_clock),
                      ),
                      onTap: () async {
                        TimeOfDay? pickedtime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          initialEntryMode: TimePickerEntryMode.dial,
                        );

                        if (pickedtime != null) {
                          setState(() {
                            _vreme.text = pickedtime.format(context);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Otkazi")),
              ElevatedButton(
                  child: const Text("Dodadi termin"),
                  onPressed: () {
                    final format = DateFormat.Hm();
                    _addListItemFunction(Ispit(
                        ime: _ime.text,
                        datum: DateTime.parse(_date.text),
                        vreme:
                            TimeOfDay.fromDateTime(format.parse(_vreme.text))));
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }
}
