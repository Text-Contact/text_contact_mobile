import "package:functional_widget_annotation/functional_widget_annotation.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:flutter/material.dart";
import "../ihp/querybuilder.dart";
import "../contacts.dart";
import "../ihp/types.dart";
import "../ui.dart";

part "dashboard.g.dart";

Future<Iterable<Message>> getMessages() async {
  List<Map<String, dynamic>> json = await query("messages")
      .distinctOn("threadId")
      .orderBy("threadId")
      .orderByDesc("receivedAt")
      .fetch();

  return json.map(Message.fromJson);
}

@hwidget
Widget dashboard() {
  final future = useMemoized(getMessages);
  final messages = useFuture(future);

  return MaterialApp(
      title: "Text Contact",
      theme: ThemeData(
          appBarTheme: const AppBarTheme(backgroundColor: colorRipeOrange)),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Text Contact",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          actions: [
            PopupMenuButton<Text>(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              enableFeedback: true,
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    child: Text(
                      "One",
                    ),
                  ),
                  const PopupMenuItem(
                    child: Text(
                      "Two",
                    ),
                  ),
                  const PopupMenuItem(
                    child: Text(
                      "Three",
                    ),
                  ),
                ];
              },
            )
          ],
        ),
        body: Scaffold(
            body: messages.hasData
                ? ListView(
                    children: List.from(messages.data!.map(showMessage)),
                  )
                : Text("Loading Messages...")),
      ));
}

//

Widget showMessage(Message message) {
  return Container(
      height: 50,
      color: Colors.amber,
      child: Center(child: Text(message.messageBody)));
}
