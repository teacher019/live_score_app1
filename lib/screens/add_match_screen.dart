import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/football_match.dart';

class AddMatchScreen extends StatefulWidget {
  final FootballMatch? footballMatch;

  const AddMatchScreen({
    super.key,
    this.footballMatch,
  });

  @override
  State<AddMatchScreen> createState() => _AddMatchScreenState();
}

class _AddMatchScreenState extends State<AddMatchScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _team1Controller = TextEditingController();
  final TextEditingController _team2Controller = TextEditingController();
  final TextEditingController _team1ScoreController =
  TextEditingController();
  final TextEditingController _team2ScoreController =
  TextEditingController();
  final TextEditingController _winnerController = TextEditingController();

  bool _isRunning = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.footballMatch != null) {
      final match = widget.footballMatch!;

      _team1Controller.text = match.team1Name;
      _team2Controller.text = match.team2Name;
      _team1ScoreController.text = match.team1Score.toString();
      _team2ScoreController.text = match.team2Score.toString();
      _winnerController.text = match.winnerTeam;
      _isRunning = match.isRunning;
    }
  }

  @override
  void dispose() {
    _team1Controller.dispose();
    _team2Controller.dispose();
    _team1ScoreController.dispose();
    _team2ScoreController.dispose();
    _winnerController.dispose();
    super.dispose();
  }

  Future<void> _saveMatch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final match = FootballMatch(
      id: widget.footballMatch?.id ?? '',
      team1Name: _team1Controller.text.trim(),
      team2Name: _team2Controller.text.trim(),
      team1Score: int.parse(_team1ScoreController.text),
      team2Score: int.parse(_team2ScoreController.text),
      winnerTeam: _winnerController.text.trim(),
      isRunning: _isRunning,
    );

    try {
      if (widget.footballMatch == null) {
        await FirebaseFirestore.instance
            .collection('football')
            .add(match.toJson());
      } else {
        await FirebaseFirestore.instance
            .collection('football')
            .doc(widget.footballMatch!.id)
            .update(match.toJson());
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Required';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.footballMatch != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Update Match' : 'Add Match',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              _buildTextField(
                controller: _team1Controller,
                label: 'Team 1 Name',
              ),

              _buildTextField(
                controller: _team2Controller,
                label: 'Team 2 Name',
              ),

              _buildTextField(
                controller: _team1ScoreController,
                label: 'Team 1 Score',
                keyboardType: TextInputType.number,
              ),

              _buildTextField(
                controller: _team2ScoreController,
                label: 'Team 2 Score',
                keyboardType: TextInputType.number,
              ),

              _buildTextField(
                controller: _winnerController,
                label: 'Winner Team',
              ),

              SwitchListTile(
                title: const Text("Is Running"),
                value: _isRunning,
                onChanged: (value) {
                  setState(() {
                    _isRunning = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMatch,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                    isEdit
                        ? "Update Match"
                        : "Save Match",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}