import 'package:flutter/material.dart';
import 'package:passman/bloc/password_stream.dart';
import 'package:passman/model/password_item.dart';
import 'package:passman/screens/pass_detail_screen.dart';
import 'package:passman/settings/settings_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:passman/support/bloc_wrapper.dart';
import 'package:passman/support/route_fade.dart';
import 'package:passman/widgets/pass_tile.dart';

class HomePage extends StatefulWidget {
  static const String route = "/home";
  final SettingsController settingsController;

  const HomePage({Key? key, required this.settingsController})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PassStream _passStream = PassStream();
  final _textSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textSearchController.addListener(() {
      if (_textSearchController.text.isNotEmpty) {
        _passStream.fetchPasswords(_textSearchController.text);
      } else {
        _passStream.fetchPasswords(null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              "images/splash_icon.png",
              scale: 0.1,
            ),
          ),
          title: const Text("PassMan"),
          actions: [
            IconButton(
                onPressed: () {
                  widget.settingsController.updateThemeMode(
                      widget.settingsController.themeMode == ThemeMode.light
                          ? ThemeMode.dark
                          : ThemeMode.light);
                  setState(() {});
                },
                icon: Icon(
                  widget.settingsController.themeMode == ThemeMode.light
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                ))
          ],
        ),
        body: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              TextField(
                controller: _textSearchController,
                style: Theme.of(context).textTheme.bodyText1,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.search,
                  contentPadding: const EdgeInsets.all(10.0),
                ),
              ),
              const SizedBox(height: 5.0,),
              Expanded(
                  child: StreamBuilder<BlocWrapper<List<PasswordItem>>>(
                stream: _passStream.passListStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    switch (snapshot.data!.status) {
                      case Status.loading:
                        return const SizedBox(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      case Status.completed:
                        if (snapshot.data!.data!.isEmpty) {
                          return Center(child: Text(
                              AppLocalizations.of(context)!.no_pass,
                              style: const TextStyle(color: Colors.blue)));
                        } else {
                          return ListView.builder(
                              itemCount: snapshot.data!.data!.length,
                              itemBuilder: (context, index) {
                                return PasswordTile(
                                    passItem: snapshot.data!.data![index], itemDetail: (PasswordItem ps) {
                                      _gotoDetail(ps);
                                },);
                              });
                        }
                      case Status.error:
                        return Center(
                          child: Text(
                            AppLocalizations.of(context)!.error_pass,
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                    }
                  } else {
                    return Container();
                  }
                },
              ))
            ],
          ),
        ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          _gotoDetail(null);
        },
      ),
    );
  }

  void _gotoDetail(PasswordItem? pi) {
    Navigator.push(
      context,
      FadeInRoute(
        routeName: PassDetailScreen.route,
        page: PassDetailScreen(passwordItem: pi,),
      ),
    ).then((value) => _passStream.fetchPasswords(null));
  }
}
