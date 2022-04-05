import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_password_strength/flutter_password_strength.dart';
import 'package:local_auth/local_auth.dart';
import 'package:passman/database/app_database.dart';
import 'package:passman/interfaces/db_interface.dart';
import 'package:passman/model/password_item.dart';

class PassDetailScreen extends StatefulWidget {
  static const String route = "/home/detail";
  final PasswordItem? passwordItem;

  const PassDetailScreen({Key? key, this.passwordItem}) : super(key: key);

  @override
  State<PassDetailScreen> createState() => _PassDetailScreenState();
}

class _PassDetailScreenState extends State<PassDetailScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final _storage = const FlutterSecureStorage();

  final _formKey = GlobalKey<FormState>();

  final _urlCtl = TextEditingController();
  final _usernameCtl = TextEditingController();
  final _passCtl = TextEditingController();

  double _passStrengthValue = 0.0;

  DatabaseInterface dbProvider = AppDatabase();

  PasswordItem? _localItem;

  bool newPass = true;
  bool editPass = false;
  String? _password;
  String? _passStrength;


  @override
  void initState() {
    newPass = widget.passwordItem == null ? true : false;
    _localItem = widget.passwordItem;
    _passCtl.addListener(() {
      _passStrength = _passCtl.text;
      setState(() {});
    });
    super.initState();
  }

  String? _fieldValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field can\'t be empty';
    }
    return null;
  }

  void _handlePass() async {
    var succ = await dbProvider.addPasswordEntry(
        url: _urlCtl.text,
        username: _usernameCtl.text,
        password: _passCtl.text);

    if (succ) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Can't save right now",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.fixed,
        elevation: 5.0,
      ));
    }
  }

  void _editPass() async {
    var id = _localItem!.id!;
    var passKey = _localItem!.password!;
    var succ = await dbProvider.updatePassword(
        id: id,
        url: _urlCtl.text,
        username: _usernameCtl.text,
        password: _passCtl.text);
    if (succ) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Password successfully edited",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.fixed,
        elevation: 5.0,
      ));
      await _storage.delete(key: passKey);
      _localItem = null;
      _localItem = await dbProvider.getPassword(id);
      _password = _passCtl.text;
      editPass = false;
      newPass = false;
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Password edit problem",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.fixed,
        elevation: 5.0,
      ));
    }
  }

  void _uncoverPassword() async {
    String? password = await _storage.read(key: _localItem!.password!);
    bool hasbiometrics = await auth.canCheckBiometrics;
    if (hasbiometrics) {
      bool pass = await auth.authenticate(
          localizedReason: 'Authenticate with biometrics', biometricOnly: true);
      if (pass) {
        setState(() {
          _password = password!;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Biometrics has issues, fix it",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.fixed,
        elevation: 5.0,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(newPass ? editPass ? "Edit Password" : " New Password" : "Password Detail"),
        ),
        body: newPass
            ? Padding(
                padding: const EdgeInsets.all(15.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('URL'),
                      TextFormField(
                        controller: _urlCtl,
                        validator: _fieldValidator,
                      ),
                      const SizedBox(height: 24.0),
                      const Text('Username'),
                      TextFormField(
                        controller: _usernameCtl,
                        validator: _fieldValidator,
                      ),
                      const SizedBox(height: 24.0),
                      const Text('Password'),
                      TextFormField(
                        obscureText: editPass ? false : true,
                        controller: _passCtl,
                        validator: _fieldValidator,
                      ),
                      const SizedBox(height: 10.0),
                      FlutterPasswordStrength(
                          password: _passStrength,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          strengthCallback: (strength){
                            _passStrengthValue = strength;
                          }
                      ),
                      const SizedBox(height: 10.0),
                      _getStrength(_passStrengthValue),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 24.0),
                        child: SizedBox(
                          width: double.maxFinite,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                if (editPass) {
                                  _editPass();
                                } else {
                                  _handlePass();
                                }
                              }
                            },
                            child: Text(editPass ? 'Save edit' : 'Add'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('URL'),
                    Container(
                      height: 0.5,
                      width: double.infinity,
                      color: Colors.white10,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        Text(_localItem!.url!,
                            style: const TextStyle(fontSize: 24.0)),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: _localItem!.url!));
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                      content: Text(
                                        "URL has been copied to clipboard",
                                        textAlign: TextAlign.center,
                                      ),
                                      backgroundColor: Colors.blue,
                                      behavior: SnackBarBehavior.fixed,
                                      elevation: 5.0,
                                    ));
                                  }, child: const Icon(Icons.copy)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),
                    const Text('Username'),
                    Container(
                      height: 0.5,
                      width: double.infinity,
                      color: Colors.white10,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        Text(_localItem!.username!,
                            style: const TextStyle(fontSize: 24.0)),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: _localItem!.username!));
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                      content: Text(
                                        "Username has been copied to clipboard",
                                        textAlign: TextAlign.center,
                                      ),
                                      backgroundColor: Colors.blue,
                                      behavior: SnackBarBehavior.fixed,
                                      elevation: 5.0,
                                    ));
                                  }, child: const Icon(Icons.copy)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),
                    const Text('Password'),
                    Container(
                      height: 0.5,
                      width: double.infinity,
                      color: Colors.white10,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    _password == null
                        ? Align(
                            alignment: Alignment.center,
                            child: GestureDetector(
                                onTap: () {
                                  _uncoverPassword();
                                },
                                child: const Icon(
                                  Icons.visibility_off,
                                  size: 40.0,
                                )),
                          )
                        : Row(
                            children: [
                              Text(_password!,
                                  style: const TextStyle(fontSize: 24.0)),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: GestureDetector(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(text: _password!));
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                            content: Text(
                                              "Password has been copied to clipboard",
                                              textAlign: TextAlign.center,
                                            ),
                                            backgroundColor: Colors.blue,
                                            behavior: SnackBarBehavior.fixed,
                                            elevation: 5.0,
                                          ));
                                        }, child: const Icon(Icons.copy)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                    const Spacer(),
                    _password == null
                        ? Container()
                        : Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 24.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right:8.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _usernameCtl.text = _localItem!.username!;
                                          _urlCtl.text = _localItem!.url!;
                                          _passCtl.text = _password!;
                                          newPass = true;
                                          editPass = true;
                                          setState(() {});
                                        },
                                        child: const Text('Edit'),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: ElevatedButton(
                                        style:  ElevatedButton.styleFrom(
                                          primary: Colors.red,
                                        ),
                                        onPressed: () async {
                                          await dbProvider.deletePass(id: _localItem!.id!);
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ));
  }

  Widget _getStrength(double s) {
    if(s < 0.25) {
      return const Text("Weak", style: TextStyle(color: Colors.red),);
    }else  if(s>0.25 && s <0.5) {
      return const Text("Moderate", style: TextStyle(color: Colors.amber),);
    }else  if(s>0.50 && s <0.75) {
      return const Text("Pretty good", style: TextStyle(color: Colors.blueAccent),);
    }else  if(s>0.75) {
      return const Text("Strong", style: TextStyle(color: Colors.lightGreenAccent),);
    }else{
      return const Text('');
    }
  }
}
