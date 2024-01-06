import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';

class ReadPage extends StatefulWidget {
  final MimeMessage message;
  const ReadPage({Key? key, required this.message}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage> {
  TextStyle style = const TextStyle(fontFamily: 'Montserrat', fontSize: 16.0);

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    var subject = message.decodeSubject();
    if (subject?.isEmpty ?? true) {
      subject = "<no subject>";
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Message"),
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text('${message.from}', style: style),
                  const Divider(
                    thickness: 1,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 10.0),
                  Text(subject!, style: style),
                  const Divider(
                    thickness: 1,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 10.0),
                  Text(message.decodeTextPlainPart() ?? "<empty>", style: style)
                ],
              ),
            ),
          ),
        ));
  }
}