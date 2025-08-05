import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/bluetooth_provider.dart';
import 'providers/controller_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const GhostWaveBTApp());
}

class GhostWaveBTApp extends StatelessWidget {
  const GhostWaveBTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),
        ChangeNotifierProvider(create: (_) => ControllerProvider()),
      ],
      child: MaterialApp(
        title: 'GhostWaveBT',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}