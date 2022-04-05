import 'dart:async';

import 'package:passman/bloc/password_provider.dart';
import 'package:passman/model/password_item.dart';
import 'package:passman/support/bloc_wrapper.dart';

class PassStream {
  final PasswordBlocProvider _provider = PasswordBlocProvider();
  StreamController<BlocWrapper<List<PasswordItem>>>? _passListController;

  StreamSink<BlocWrapper<List<PasswordItem>>> get passListSink =>
      _passListController!.sink;

  Stream<BlocWrapper<List<PasswordItem>>> get passListStream =>
      _passListController!.stream;

  PassStream() {
    _passListController = StreamController<BlocWrapper<List<PasswordItem>>>();
    fetchPasswords(null);
  }

  fetchPasswords(String? filter) async {
    passListSink.add(BlocWrapper.loading('Fetching Passwords'));
    try {
      List<PasswordItem>? _passList = await _provider.fetchAllPasswords(filter: filter);
      passListSink.add(BlocWrapper.completed(_passList));
    } catch (e) {
      passListSink.add(BlocWrapper.error(e.toString()));
      // print(e);
    }
  }
}