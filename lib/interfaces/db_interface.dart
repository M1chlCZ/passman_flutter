import '../model/password_item.dart';

//Just in case some dependency injection in the future

abstract class DatabaseInterface{
  Future<bool> addPasswordEntry({required String url, required String username, required String password});
  Future<List<PasswordItem>> getPasswords();
  Future<bool> updatePassword({required int id, required String url, required String username,required String password});
  Future<PasswordItem> getPassword(int id);
  Future<void> deletePass({required int id});
  Future<List<PasswordItem>> searchPassword(String searchQuery);
}