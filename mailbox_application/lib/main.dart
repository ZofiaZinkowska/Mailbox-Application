import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mailbox_application/controllers/user_controller.dart';
import 'firebase_options.dart';

import 'messages.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mail App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Login'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    initStateAsync();
  }

  Future<void> initStateAsync() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = isLoggingIn
        ? buildInfo(context, "Please wait while we sign you in")
        : buildLoginForm(context);

    return Scaffold(
        appBar: AppBar(title: const Text("Mail App")), body: content);
  }

  Widget buildLoginForm(BuildContext context) {
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

    final passwordField = TextField(
      controller: passwordController,
      obscureText: true,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          logIn(context);
        },
        child: Text("Login",
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
                SizedBox(height: 145.0),
                emailField,
                SizedBox(height: 25.0),
                passwordField,
                SizedBox(height: 35.0),
                loginButon,
                SizedBox(height: 15.0),
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

  void logIn(BuildContext context) {
    setState(() {
      isLoggingIn = true;
    });

    connect().then((client) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MessagesPage(client: client))).then((_) {
        setState(() {
          isLoggingIn = false;
        });
      });
    }, onError: (_) {
      setState(() {
        isLoggingIn = false;
      });
    });
  }

  Future<MailClient> connect() async {
    final user = await UserController.loginWithGoogle();
    final email = user!.email!;
    final token = await user.getIdTokenResult();
    try {
      //final oAuthToken = OauthToken.fromJson(tokenJson);
      final oAuthToken = OauthToken(
        accessToken: token.token!,
        expiresIn: 3600,
        created: DateTime.now(),
        refreshToken: '',
        scope: '',
        tokenType: '',
        provider: ''
      );
      final auth = OauthAuthentication(email, oAuthToken);

      // TODO: Show error when login or password is null

      final config = await Discover.discover(email);

      // TODO: Show error when config is null (could not be detected)
      final account = MailAccount.fromDiscoveredSettingsWithAuth(
        name: 'Gmail account',
        email: email,
        auth: auth,
        userName: email, // This is the additional parameter needed
        config: config!,
      );

      final client = MailClient(account, isLogEnabled: true);

      // TODO: try-catch to handle authorization fail
      await client.connect();
      return client;
    } catch (error) {
      debugPrint(error.toString());
      throw error;
    }
  }
}
