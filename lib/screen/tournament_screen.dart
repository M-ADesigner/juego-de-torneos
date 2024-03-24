import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:test_v1/model/Team.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importar SharedPreferences

class TournamentScreen extends StatefulWidget {
  final List<Team> teams;
  final VoidCallback refreshCallback;
  const TournamentScreen({
    super.key,
    required this.teams,
    required this.refreshCallback,
  });

  @override
  _TournamentScreenState createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  late List<List<Team>> matches;
  late SharedPreferences prefs; // SharedPreferences
  int totalPlays2 = 0;
  int totalPlays1 = 0;

  @override
  void initState() {
    super.initState();
    generateMatches();
    initSharedPreferences(); // Inicializar SharedPreferences
  }

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  void generateMatches() {
    List<Team> shuffledTeams = List.from(widget.teams)..shuffle();
    matches = [];

    for (int i = 0; i < shuffledTeams.length; i += 2) {
      matches.add([shuffledTeams[i], shuffledTeams[i + 1]]);
    }
  }

  void updateMatchResult(int matchIndex, int teamIndex) async {
    setState(() {
      widget.refreshCallback(); // Actualizar la lista de equipos

      // Incrementar jugadas totales del equipo 1 y equipo 2
      matches[matchIndex][0].incrementTotalPlays();
      matches[matchIndex][1].incrementTotalPlays();
      Logger logger = Logger();

      // Imprimir mensajes de depuración para verificar el valor de totalPlays
      logger.i(
          'Equipo 1 - Jugadas totales: ${matches[matchIndex][0].totalPlays}');
      logger.d(
          'Equipo 2 - Jugadas totales: ${matches[matchIndex][1].totalPlays}');

      if (teamIndex == 0) {
        matches[matchIndex][0].updateScore(matches[matchIndex][0].score + 1);
      } else {
        matches[matchIndex][1].updateScore(matches[matchIndex][1].score + 1);
      }

      // Guardar puntuaciones y jugadas totales al actualizar
      saveScores();
    });
  }

  Future<void> saveScores() async {
    List<String> scores = [];
    matches.forEach((match) {
      match.forEach((team) {
        scores.add(
            '${team.name}:${team.score}'); // Guardar nombre del equipo y su puntaje
      });
    });
    await prefs.setStringList(
        'scores', scores); // Guardar lista de puntuaciones en SharedPreferences

    // Guardar jugadas totales después de actualizar todos los equipos
    matches.forEach((match) {
      match.forEach((team) {
        team.saveTotalPlays(); // Guardar jugadas totales de cada equipo
      });
    });

    // Actualizar la UI con las puntuaciones y jugadas totales
    setState(() {
      totalPlays1 = matches[0][0].totalPlays;
      totalPlays2 = matches[0][1].totalPlays;
    });
  }

  Future<void> loadScores() async {
    List<String>? scores = prefs.getStringList('scores');
    if (scores != null) {
      matches = [];
      for (int i = 0; i < scores.length; i += 2) {
        List<String> teamData1 = scores[i].split(':');
        List<String> teamData2 = scores[i + 1].split(':');
        Team team1 = Team(teamData1[0], int.parse(teamData1[1]));
        Team team2 = Team(teamData2[0], int.parse(teamData2[1]));
        matches.add([team1, team2]);
      }
      setState(() {}); // Actualizar la UI con las puntuaciones cargadas
    }
  }

  @override
  Widget build(BuildContext context) {
    loadScores(); // Cargar puntuaciones al construir la UI

    return Scaffold(
      appBar: AppBar(title: const Text('Llave de Torneo')),
      body: matches.isEmpty
          ? const Center(child: Text('No hay enfrentamientos generados.'))
          : ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text('Partido ${index + 1}'),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '${matches[index][0].name} ($totalPlays1)', // Nombre del equipo y jugadas totales
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text('${matches[index][0].score}'),
                            const Text('-'),
                            Text('${matches[index][1].score}'),
                            Flexible(
                              child: Text(
                                '${matches[index][1].name} ($totalPlays2)', // Nombre del equipo y jugadas totales
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Resultado del Partido'),
                                  content: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          updateMatchResult(index, 0);
                                          matches[index][0].updateScore(matches[
                                                  index][0]
                                              .score++); // Incrementa el puntaje y las jugadas totales
                                          Navigator.pop(context);
                                        },
                                        child: Text(matches[index][0].name),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          updateMatchResult(index, 1);
                                          matches[index][1].updateScore(matches[
                                                  index][1]
                                              .score++); // Incrementa el puntaje y las jugadas totales
                                          Navigator.pop(context);
                                        },
                                        child: Text(matches[index][1].name),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: const Text('Registrar Resultado'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
