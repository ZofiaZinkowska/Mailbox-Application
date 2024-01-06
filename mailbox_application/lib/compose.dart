import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';

class ComposePage extends StatefulWidget {
  final MailClient client;

  ComposePage({Key? key, required this.client}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ComposePageState();
}

class _ComposePageState extends State<ComposePage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  final emailController = TextEditingController();
  final topicController = TextEditingController();
  final messageController = TextEditingController();
  bool isSending = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (isSending) {
      body = buildInfo(context, "Please wait while we send your message");
    } else {
      body = buildForm(context);
    }

    return Scaffold(
        appBar: AppBar(title: const Text("New message")), body: body);
  }

  Widget buildForm(BuildContext context) {
    final emailField = TextField(
      controller: emailController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final topicField = TextField(
      controller: topicController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Topic",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final messageField = TextField(
      controller: messageController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 80.0, 20.0, 80.0),
          hintText: "Message",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final submitButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          send(context);
        },
        child: Text("Submit",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return SingleChildScrollView(
      child: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 55.0),
                emailField,
                SizedBox(height: 35.0),
                topicField,
                SizedBox(height: 45.0),
                messageField,
                SizedBox(height: 25.0),
                submitButon,
                SizedBox(height: 25.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfo(BuildContext context, String message) {
    return Center(child: Text(message));
  }

  void send(BuildContext context) {
    sendAsync().then((error) {
      if (error != null) {
        // TODO: Show error
      } else {
        Navigator.pop(context);
      }
    });
  }

  Future<String?> sendAsync() async {
    setState(() {
      isSending = true;
    });

    try {
      final client = widget.client;
      final from = client.account.fromAddress;
      final to = MailAddress(null, emailController.text);
      final subject = topicController.text;
      final body = messageController.text;

      // TODO: Validate 'to' and 'body' are not empty
      final message = MessageBuilder.buildSimpleTextMessage(from, [to], body,
          subject: subject);

      await client.sendMessage(message);

      return null;
    } on MailException {
      return "There was an error sending the message";
    }
  }
}