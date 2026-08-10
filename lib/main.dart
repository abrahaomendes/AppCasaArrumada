import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'core/theme/app_theme.dart';
import 'providers/pessoa_provider.dart';
import 'providers/tarefa_provider.dart';
import 'providers/execucao_provider.dart';
import 'providers/ranking_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/ranking/ranking_screen.dart';
import 'screens/historico/historico_screen.dart';
import 'screens/configuracoes/configuracoes_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Na web, usa SQLite na thread principal (sem necessidade de COOP/COEP headers)
    databaseFactory = databaseFactoryFfiWebNoWebWorker;
  }
  // No mobile (Android/iOS), o sqflite funciona nativamente sem config adicional.
  // No desktop, inicialização FFI pode ser adicionada aqui se necessário.

  runApp(const CasaEmOrdemApp());
}

class CasaEmOrdemApp extends StatelessWidget {
  const CasaEmOrdemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PessoaProvider()),
        ChangeNotifierProvider(create: (_) => TarefaProvider()),
        ChangeNotifierProvider(create: (_) => ExecucaoProvider()),
        ChangeNotifierProvider(create: (_) => RankingProvider()),
      ],
      child: MaterialApp(
        title: 'Casa em Ordem',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainNavigationScreen(),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    RankingScreen(),
    HistoricoScreen(),
    ConfiguracoesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            context.read<ExecucaoProvider>().inicializarECarregar();
          } else if (index == 1 || index == 2) {
            context.read<RankingProvider>().carregarRanking();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_box_outlined),
            selectedIcon: Icon(Icons.check_box),
            label: 'Tarefas',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Ranking',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history_sharp),
            label: 'Histórico',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
