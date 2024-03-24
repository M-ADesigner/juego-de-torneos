import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_v1/model/Team.dart';
import 'package:test_v1/screen/tournament_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Team> teams = [];
  bool isTournamentStarted = false;
  TextEditingController teamNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadScores(); // Cargar puntajes al iniciar la pantalla
  }

  void refresh() {
    setState(() {});
  }

  Future<void> loadScores() async {
    var prefs = await SharedPreferences.getInstance();
    List<String>? scores = prefs.getStringList('scores');

    if (scores != null) {
      teams = scores.map((score) {
        List<String> data = score.split(':');
        return Team(
            data[0],
            int.parse(
              data[1],
            ));
      }).toList();
      setState(() {}); // Actualizar la UI con los puntajes cargados
    }
  }

  void clearData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs
        .remove('scores'); // Eliminar la clave 'scores' de SharedPreferences
    await prefs.clear(); // Limpiar todas las claves de SharedPreferences
    setState(() {
      teams.clear(); // Limpiar la lista de equipos
    });
  }

  void updateScoreAndPlays(int index, int newScore) {
    setState(() {
      teams[index].updateScore(newScore);
      teams[index]
          .incrementTotalPlays(); // Incrementa el contador de jugadas totales
      saveScores(); // Guarda los cambios en el puntaje y jugadas totales
    });
  }

  Future<void> saveScores() async {
    var prefs = await SharedPreferences.getInstance();
    List<String> scoreList =
        teams.map((team) => '${team.name}:${team.score}').toList();
    prefs.setStringList('scores', scoreList);
  }

  void removeTeam(int index) {
    setState(() {
      teams.removeAt(index);
      saveScores(); // Guardar puntajes al eliminar equipo
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Torneo de Ping Pong')),
      body: ListView.builder(
        itemCount: teams.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(teams[index].name),
            subtitle: Text(
                'Jugadas totales: ${teams[index].totalPlays}'), // Muestra el contador de jugadas totales
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(teams[index].score.toString()),
                IconButton(
                  // ignore: prefer_const_constructors
                  icon: Icon(Icons.delete),
                  onPressed: () => removeTeam(index),
                ),
              ],
            ),
            onTap: () async {
              final newScore = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  final TextEditingController controller =
                      TextEditingController();

                  return AlertDialog(
                    title: const Text('Actualizar Puntaje'),
                    content: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          String value = controller.text.trim();
                          int? newScore =
                              value.isNotEmpty ? int.tryParse(value) : null;

                          if (newScore != null) {
                            updateScoreAndPlays(index,
                                newScore); // Actualiza puntaje y jugadas totales
                            Navigator.pop(context); // Cerrar el AlertDialog
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Por favor, ingresa un número válido.',
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Actualizar'),
                      ),
                    ],
                  );
                },
              );

              if (newScore != null) {
                updateScoreAndPlays(
                    index, newScore); // Actualiza puntaje y jugadas totales
              }
            },
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              final newTeamName = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Agregar Equipo'),
                    content: TextField(
                      controller: teamNameController,
                      onChanged: (value) => setState(() {}),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {});
                          String teamName = teamNameController.text.trim();
                          if (teamName.isNotEmpty) {
                            teams.add(Team(teamName, 0));
                            saveScores(); // Guardar puntajes al agregar equipo
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Por favor, ingresa el nombre del equipo.'),
                              ),
                            );
                          }
                        },
                        child: const Text('Agregar'),
                      ),
                    ],
                  );
                },
              );

              if (newTeamName != null) {
                setState(() {
                  // teamNameController.clear();
                  teams.add(newTeamName);
                  saveScores(); // Guardar puntajes al agregar equipo
                });
              }
            },
            child: const Icon(Icons.add),
          ),
          IconButton(onPressed: clearData, icon: Icon(Icons.delete)),
        ],
      ),
      bottomNavigationBar: teams.length >= 2 && teams.length % 2 == 0
          ? BottomAppBar(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isTournamentStarted = true;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TournamentScreen(
                          teams: teams,
                          refreshCallback: refresh,
                        ),
                      ),
                    );
                  },
                  child: const Text('Iniciar Juego'),
                ),
              ),
            )
          : const BottomAppBar(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Debes tener un número par de equipos para iniciar el torneo.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    teamNameController.dispose();
    super.dispose();
  }
}
