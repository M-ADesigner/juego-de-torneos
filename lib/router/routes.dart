import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_v1/router/route_name.dart';
import 'package:test_v1/screen/home.dart';

// Crear una instancia del enrutador
final GoRouter router = GoRouter(
  initialLocation: RouteNames.home, // Ruta inicial
  errorPageBuilder: (context, state) => MaterialPage(
    // Página de error personalizada
    child: Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Column(
        children: [
          Center(
            child: Text('Error: ${state.error}'),
          ),
          ElevatedButton(
            onPressed: () =>
                context.go('/home'), // Volver a la página de inicio
            child: const Text('Go back!'),
          ),
        ],
      ),
    ),
  ),
  routes: [
    GoRoute(
      path: '/home', // Ruta de inicio
      pageBuilder: (context, state) => MaterialPage(
        child: HomeScreen(),
      ),
      // routes: [
      //   GoRoute(
      //     name: RouteNames.equipos, // Nombre de la ruta
      //     path: 'equipos', // Ruta para mostrar la lista de equipos
      //     builder: (context, state) => EquiposPages(
      //       cantidadEquipos:
      //           (state.extra as Map<String, dynamic>)['cantidadEquipos']
      //               as int, // Cantidad de equipos
      //     ),
      //     routes: [
      //       GoRoute(
      //         name: RouteNames.equipo, // Nombre de la ruta
      //         path: 'equipo',
      //         builder: (context, state) => EquipoPage(
      //           id: (state.extra as Map<String, dynamic>)['id'] as int,
      //         ), // Mostrar la página de información del equipo con el ID especificado
      //       ),
      //     ],
      //   ),
      //   GoRoute(
      //     name: RouteNames.juego, // Nombre de la ruta
      //     path: 'juego', // Ruta para mostrar la página de juego
      //     builder: (context, state) => JuegoScreen(
      //       equipo1: (state.extra as Map<String, dynamic>)['equipo1']
      //           as Equipo, // Equipo 1
      //       equipo2: (state.extra as Map<String, dynamic>)['equipo2']
      //           as Equipo, // Equipo 2
      //       onGanadorSeleccionado: (p0, p1) => {},
      //     ),
      //   ),
      // ],
    ),
  ],
);
