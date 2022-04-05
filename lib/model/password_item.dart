class PasswordItem {
  PasswordItem({
      int? id, 
      String? url, 
      String? username, 
      String? password,}){
    _id = id;
    _url = url;
    _username = username;
    _password = password;
}

  PasswordItem.fromJson(dynamic json) {
    _id = json['id'];
    _url = json['url'];
    _username = json['username'];
    _password = json['password'];
  }
  int? _id;
  String? _url;
  String? _username;
  String? _password;
PasswordItem copyWith({  int? id,
  String? url,
  String? username,
  String? password,
}) => PasswordItem(  id: id ?? _id,
  url: url ?? _url,
  username: username ?? _username,
  password: password ?? _password,
);
  int? get id => _id;
  String? get url => _url;
  String? get username => _username;
  String? get password => _password;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['url'] = _url;
    map['username'] = _username;
    map['password'] = _password;
    return map;
  }

}