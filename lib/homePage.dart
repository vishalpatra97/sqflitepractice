import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflitepractice/provider/sqlProvider.dart';
import 'package:sqflitepractice/theme/theme_service.dart';

class MyHomePage extends StatefulWidget {
  final SqlProvider prov;
  const MyHomePage({super.key, required this.prov});

  static Widget create(BuildContext context) {
    //-- Provider
    // final provider = Provider.of<SqlProvider>(context, listen: false);
    return Consumer<SqlProvider>(
      builder: (context, value, child) => MyHomePage(prov: value),
    );
  }

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SqlProvider? provider;
  //
  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  //
  @override
  void initState() {
    provider = widget.prov;
    widget.prov.getItems();
    super.initState();
  }

//
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

//
  void _refreshJournal() async {
    // setState(() {
    //   _journals = data;
    //   _isLoading = false;
    // });
  }

  _addItem() =>
      provider?.createItem(_titleController.text, _descriptionController.text);

  _updateItem(int id) => provider?.updateItem(
      id, _titleController.text, _descriptionController.text);

  void _deleteItem(int id) {
    provider?.deleteItem(id);
    _refreshJournal();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Successfully deleted a journal!")));
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          provider?.dataList.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Title"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(hintText: "description"),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addItem();
                  }
                  if (id != null) {
                    await _updateItem(id);
                  }

                  _titleController.text = "";
                  _descriptionController.text = "";
                  if (mounted) {}
                  Navigator.pop(context);
                },
                child: Text(id == null ? 'Create New' : 'Update'))
          ],
        ),
      ),
    );
  }

  //
  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("SQL"),
          actions: [
            ThemeSwitcher(
              builder: (context) {
                bool isDarkMode =
                    ThemeModelInheritedNotifier.of(context).theme.brightness ==
                        Brightness.light;
                String themeName = isDarkMode ? 'dark' : 'light';

                return DayNightSwitcherIcon(
                    isDarkModeEnabled: isDarkMode,
                    onStateChanged: (bool darkMode) async {
                      var service = await ThemeService.instance
                        ..save(darkMode ? 'light' : 'dark');
                      var theme = service.getByName(themeName);
                      if (mounted) {}
                      ThemeSwitcher.of(context)
                          .changeTheme(theme: theme, isReversed: darkMode);
                    });
              },
            )
          ],
        ),
        body: ListView.builder(
          itemCount: widget.prov.dataList.length,
          itemBuilder: (context, index) => Card(
            color: Theme.of(context).primaryColor,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
            child: ListTile(
              title: Text(
                widget.prov.dataList[index]['title'],
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                widget.prov.dataList[index]['description'],
                style: const TextStyle(color: Colors.white),
              ),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () =>
                            _showForm(widget.prov.dataList[index]['id']),
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        )),
                    IconButton(
                        onPressed: () =>
                            _deleteItem(widget.prov.dataList[index]['id']),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ))
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showForm(null),
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
