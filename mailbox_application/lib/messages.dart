import 'package:mailbox_application/compose.dart';
import 'package:mailbox_application/read.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key, required this.client}) : super(key: key);

  final MailClient client;

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  bool isLoadingMessages = false;
  List<MimeMessage>? messages;

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    Widget? body;
    if (isLoadingMessages) {
      body = buildInfo(context, "Please wait while we load your messages");
    } else if (messages != null) {
      body = buildList(context);
    } else {
      // TODO: Show error that loading failed
    }

    Widget? actionButton;
    if (!isLoadingMessages) {
      actionButton = FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ComposePage(client: widget.client)));
        },
        tooltip: 'New message',
        child: const Icon(Icons.add),
      );
    }

    return Scaffold(
      appBar: buildAppBar(context),
      body: body,
      floatingActionButton: actionButton,
    );
  }

  AppBar buildAppBar(BuildContext context) {
    Widget title;

    if (widget.client.mailboxes != null) {
      title = DropdownButton<Mailbox>(
          items: widget.client.mailboxes!
              .where((m) => !m.isNotSelectable)
              .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
              .toList(),
          value: widget.client.selectedMailbox,
          underline: null,
          onChanged: (mailbox) {
            loadMessages(mailbox: mailbox);
          });
    } else {
      title = Text(widget.client.selectedMailbox?.name ?? "Messages");
    }

    return AppBar(title: title);
  }

  Widget buildList(BuildContext context) {
    return Center(
      child: ListView.builder(
        itemBuilder: _itemBuilder,
        itemCount: messages!.length,
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final message = messages![index];
    final isOutbox = widget.client.selectedMailbox?.isSent ?? false;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
              child: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute<ReadPage>(
                            builder: (context) => ReadPage(message: message)));
                  },
                  icon: const Icon(Icons.read_more))),
          Flexible(
            child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Date: ${message.decodeDate()}',
                        overflow: TextOverflow.ellipsis),
                    Text(
                        isOutbox
                            ? 'To: ${message.to}'
                            : 'From: ${message.from}',
                        overflow: TextOverflow.ellipsis),
                    Text('Subject: ${message.decodeSubject()}',
                        overflow: TextOverflow.ellipsis),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget buildInfo(BuildContext context, String message) {
    return Center(child: Text(message));
  }

  void loadMessages({Mailbox? mailbox}) {
    setState(() {
      isLoadingMessages = true;
      messages = null;
    });

    loadMessagesAsync(mailbox ?? widget.client.selectedMailbox).then(
        (messages) {
      setState(() {
        isLoadingMessages = false;
        this.messages = messages?.reversed.toList();
      });
    }, onError: (_) {
      setState(() {
        isLoadingMessages = false;
        messages = null;
      });
    });
  }

  Future<List<MimeMessage>?> loadMessagesAsync(Mailbox? mailbox) async {
    final client = widget.client;

    if (mailbox != null) {
      await client.selectMailbox(mailbox);
    } else if (client.selectedMailbox == null) {
      await client.selectInbox();
    }

    try {
      final messages =
          await client.fetchMessages(fetchPreference: FetchPreference.full);
      return messages;
    } on MailException {
      return null;
    }
  }
}