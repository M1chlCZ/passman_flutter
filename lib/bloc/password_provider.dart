import 'package:passman/database/app_database.dart';
import 'package:passman/interfaces/db_interface.dart';
import 'package:passman/model/password_item.dart';

class PasswordBlocProvider {
  DatabaseInterface db = AppDatabase();

  Future<List<PasswordItem>?> fetchAllPasswords({String? filter}) async {
    if(filter == null || filter.isEmpty) {
      return db.getPasswords();
    }else if(filter.isNotEmpty){
      return db.searchPassword(filter);
    }else{
      return null;
    }
  }
}