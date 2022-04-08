import 'package:flutter/material.dart';
import 'contains/contains.dart';
import 'database/database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NOTES',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _Notes = [];

  bool _isLoading = true;

  void _notes() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _Notes = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _notes();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _Notes.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    cursorColor: primarycolor,
                    textCapitalization: TextCapitalization.words,
                    controller: _titleController,
                    decoration: const InputDecoration(
                        hintText: 'Title',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    cursorColor: primarycolor,
                    textCapitalization: TextCapitalization.words,
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Description',
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (id == null) {
                        await _addItem();
                      }

                      if (id != null) {
                        await _updateItem(id);
                      }

                      _titleController.text = '';
                      _descriptionController.text = '';

                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Create New' : 'Update'),
                  ),
                ],
              ),
            ));
  }

  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _titleController.text, _descriptionController.text);
    _notes();
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    _notes();
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Note succesfuly deleted'),
    ));
    _notes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Notes',
          style: TextStyle(wordSpacing: 10),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _Notes.length,
              itemBuilder: (context, index) => Card(
                color: primarycolor,
                margin: const EdgeInsets.all(15),
                child: GestureDetector(
                  onLongPress: () => _showForm(_Notes[index]['id']),
                  onDoubleTap: () => _deleteItem(_Notes[index]['id']),
                  child: ListTile(
                      title: Text(
                        _Notes[index]['title'].toString().length > 9
                            ? _Notes[index]['title']
                                    .toString()
                                    .substring(0, 8) +
                                ".."
                            : _Notes[index]['title'].toString(),
                        style: titletxt,
                      ),
                      subtitle: Text(
                        _Notes[index]['description'].toString().length > 10
                            ? _Notes[index]['description']
                                    .toString()
                                    .substring(0, 8) +
                                ".."
                            : _Notes[index]['description'].toString(),
                        style: descriptiontxt,
                      ),
                      trailing: SizedBox(
                        width: 180,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showForm(_Notes[index]['id']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteItem(_Notes[index]['id']),
                            ),
                            Text(
                              _Notes[index]["createdAt"]
                                  .toString()
                                  .substring(0, 10),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            ),
                          ],
                        ),
                      )),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
