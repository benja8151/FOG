import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:ssi_app/services/contracts_service.dart';
import 'package:ssi_app/services/ipfs_service.dart';
import 'package:ssi_app/services/keys_service.dart';
import 'package:ssi_app/views/credentials_screen.dart';
import 'package:ssi_app/views/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterSecureStorage _secureStorage;
  IpfsService _ipfsService;
  KeysService _keysService;

  @override
  void initState() { 
    super.initState();
    _secureStorage = FlutterSecureStorage();
    _keysService = KeysService(secureStorage: _secureStorage);
    _ipfsService = IpfsService();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<KeysService>(
          create: (_) => _keysService
        ),
        Provider<IpfsService>(
          create: (_) => _ipfsService,
        ),
        ChangeNotifierProvider<ContractsService>(
          create: (_) => ContractsService(
            keysService: _keysService,
            secureStorage: _secureStorage, 
            ipfsService: _ipfsService
          )
        )
      ],
      child: MaterialApp(
        title: "Hello World",
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.cyan[400],
          accentColor: Colors.deepOrange[200]
        ),
        initialRoute: "/",
        routes: {
          "/": (context) => HomeScreen(),
          "/credentials": (context) => CredentialsScreen()
        },
      ),
    );
  }
}