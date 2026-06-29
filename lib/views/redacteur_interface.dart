import 'package:flutter/material.dart';
import '../modele/redacteur.dart';
import '../services/database_manager.dart';

class RedacteurInterface extends StatefulWidget {
  const RedacteurInterface({super.key});

  @override
  State<RedacteurInterface> createState() => _RedacteurInterfaceState();
}

class _RedacteurInterfaceState extends State<RedacteurInterface> {
  final DatabaseManager _db = DatabaseManager();
  List<Redacteur> _redacteurs = [];

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chargerRedacteurs();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _chargerRedacteurs() async {
    final liste = await _db.getAllRedacteurs();
    setState(() {
      _redacteurs = liste;
    });
  }

  Future<void> _ajouterRedacteur() async {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final email = _emailController.text.trim();

    if (nom.isEmpty || prenom.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    final redacteur = Redacteur(nom: nom, prenom: prenom, email: email);
    await _db.insertRedacteur(redacteur);
    await _chargerRedacteurs();

    _nomController.clear();
    _prenomController.clear();
    _emailController.clear();
  }

  Future<void> _modifierRedacteur(Redacteur redacteur) async {
    final nomCtrl = TextEditingController(text: redacteur.nom);
    final prenomCtrl = TextEditingController(text: redacteur.prenom);
    final emailCtrl = TextEditingController(text: redacteur.email);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier le rédacteur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomCtrl,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: prenomCtrl,
              decoration: const InputDecoration(labelText: 'Prénom'),
            ),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updated = Redacteur(
                id: redacteur.id,
                nom: nomCtrl.text.trim(),
                prenom: prenomCtrl.text.trim(),
                email: emailCtrl.text.trim(),
              );
              await _db.updateRedacteur(updated);
              if (ctx.mounted) Navigator.of(ctx).pop();
              await _chargerRedacteurs();
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _supprimerRedacteur(int id) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le rédacteur'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce rédacteur ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _db.deleteRedacteur(id);
              if (ctx.mounted) Navigator.of(ctx).pop();
              await _chargerRedacteurs();
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Rédacteurs'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomController,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: _prenomController,
              decoration: const InputDecoration(labelText: 'Prénom'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _ajouterRedacteur,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un Rédacteur'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _redacteurs.isEmpty
                  ? const Center(child: Text('Aucun rédacteur enregistré.'))
                  : ListView.builder(
                      itemCount: _redacteurs.length,
                      itemBuilder: (context, index) {
                        final r = _redacteurs[index];
                        return Card(
                          child: ListTile(
                            title: Text('${r.nom} ${r.prenom}'),
                            subtitle: Text(r.email),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _modifierRedacteur(r),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _supprimerRedacteur(r.id!),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
