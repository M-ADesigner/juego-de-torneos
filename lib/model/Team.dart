import 'package:shared_preferences/shared_preferences.dart';

class Team {
  String name;
  int score;
  int totalPlays; // Variable para llevar el registro de jugadas totales

  Team(this.name, this.score, {this.totalPlays = 0});

  void updateScore(int newScore) {
    score = newScore;
  }

  void incrementTotalPlays() {
    totalPlays++;
  }

  Future<void> saveTotalPlays() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$name-totalPlays', totalPlays);
  }

  Future<void> loadTotalPlays() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    totalPlays = prefs.getInt('$name-totalPlays') ?? 0;
  }
}
