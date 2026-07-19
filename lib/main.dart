import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/bulb_repository.dart';
import 'data/services/bulb_store.dart';
import 'data/services/connectivity_service.dart';
import 'data/services/discovery.dart';
import 'data/services/wifi_band_service.dart';
import 'data/services/wiz_protocol.dart';
import 'data/services/wiz_protocol_impl.dart';
import 'ui/features/home/home_screen.dart';
import 'ui/features/home/home_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final proto = await WizProtocolImpl.create();
  final store = BulbStore();
  final connectivity = ConnectivityServiceImpl();
  final discovery = Discovery(proto);
  final wifiBandService = WifiBandServiceImpl();
  final repository = BulbRepository(
    proto: proto,
    discovery: discovery,
    store: store,
    connectivity: connectivity,
  );
  final viewModel = BulbViewModel(
    repository: repository,
    wifiBandService: wifiBandService,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<WizProtocol>.value(value: proto),
        Provider<BulbStore>.value(value: store),
        Provider<ConnectivityService>.value(value: connectivity),
        Provider<BulbRepository>.value(value: repository),
        Provider<WifiBandService>.value(value: wifiBandService),
        ChangeNotifierProvider<BulbViewModel>.value(value: viewModel),
      ],
      child: const LampoApp(),
    ),
  );
}

class LampoApp extends StatefulWidget {
  const LampoApp({super.key});

  @override
  State<LampoApp> createState() => _LampoAppState();
}

class _LampoAppState extends State<LampoApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final repository = context.read<BulbRepository>();
    switch (state) {
      case AppLifecycleState.paused:
        repository.onAppPaused();
      case AppLifecycleState.resumed:
        repository.onAppResumed();
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lampo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          surfaceTintColor: Colors.transparent,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          surfaceTintColor: Colors.transparent,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
