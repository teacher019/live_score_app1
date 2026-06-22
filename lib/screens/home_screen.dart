import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';


import '../models/football_match.dart';
import 'add_match_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  @override
  void initState() {
    super.initState();
    // FirebaseCrashlytics.instance.log('Opened home screen');
    // FirebaseAnalytics.instance.logEvent(name: 'Home screen');
    FirebaseAnalytics.instance.setUserId(
        id: FirebaseAuth.instance.currentUser?.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(onPressed: _onTapLogoutButton, icon: Icon(Icons.logout)),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('football').snapshots(),
        builder: (context, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshots.hasError) {
            return Center(child: Text(snapshots.error.toString()));
          }

          List<FootballMatch> footballMatchList = [];

          for (DocumentSnapshot doc in snapshots.data!.docs) {
            footballMatchList.add(
              FootballMatch.fromJson(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ),
            );
          }

          return ListView.separated(
            itemCount: footballMatchList.length,
            itemBuilder: (context, index) {
              final FootballMatch match = footballMatchList[index];

              return Dismissible(
                key: Key(match.id),
                onDismissed: (_) {
                  _onDismissed(match.id);
                },
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddMatchScreen(
                          footballMatch: match,
                        ),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    radius: 8,
                    backgroundColor:
                    match.isRunning ? Colors.green : Colors.grey,
                  ),
                  title: Text('${match.team1Name} vs ${match.team2Name}'),
                  subtitle: Text('Winner Team: ${match.winnerTeam}'),
                  trailing: Text(
                    '${match.team1Score}-${match.team2Score}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => SizedBox(height: 8),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddMatchScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _onTapAddNewMatch() {
    FootballMatch footballMatch = FootballMatch(
      id: 'portvsmor',
      team1Name: 'Brazil',
      team2Name: 'Morocco',
      team1Score: 1,
      team2Score: 1,
      winnerTeam: 'Brazil',
      isRunning: false,
    );

    // ADD
    // FirebaseFirestore.instance
    //     .collection('football')
    //     .doc(footballMatch.id)
    //     .set(footballMatch.toJson());
    // FirebaseFirestore.instance
    //     .collection('football')
    //     .add(footballMatch.toJson());

    // UPDATE
    FirebaseFirestore.instance
        .collection('football')
        .doc(footballMatch.id)
        .update(footballMatch.toJson());
  }

  void _onDismissed(String docId) {
    FirebaseAnalytics.instance.logEvent(name: 'Deleted match!');
    FirebaseFirestore.instance
        .collection('football')
        .doc(docId)
        .delete();
  }

  Future<void> _onTapLogoutButton() async {
    FirebaseCrashlytics.instance.log('User logout');
    await FirebaseAuth.instance.signOut();
  }
}

