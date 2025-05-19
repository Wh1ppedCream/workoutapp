import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'models.dart';
import 'definitions_by_bodypart_page.dart';

class MuscleFilterPage extends StatefulWidget {
  const MuscleFilterPage({Key? key}) : super(key: key);

  @override
  _MuscleFilterPageState createState() => _MuscleFilterPageState();
}

class _MuscleFilterPageState extends State<MuscleFilterPage> {
  late Future<List<BodyPart>> _bodyPartsFuture;

  @override
  void initState() {
    super.initState();
    _bodyPartsFuture = _loadBodyParts();
  }

  Future<List<BodyPart>> _loadBodyParts() async {
    final db = await DatabaseHelper().database;
    final rows = await db.query('bodypart');
    return rows.map((r) => BodyPart(r['id'] as int, r['name'] as String)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Muscle Filter')),
      body: FutureBuilder<List<BodyPart>>(
        future: _bodyPartsFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final parts = snap.data ?? [];
          return ListView.builder(
            itemCount: parts.length,
            itemBuilder: (context, i) {
              final part = parts[i];
              return ListTile(
                title: Text(part.name),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DefinitionsByBodyPartPage(bodyPart: part),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}