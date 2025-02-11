enum Constants {
  firebaseBaseUrl,
  firebaseJsonToUse,
}

extension ConstantExtension on Constants {
  String get constValue {
    return switch (this) {
      Constants.firebaseBaseUrl =>
        'shopping-list-flutter-c4675-default-rtdb.asia-southeast1.firebasedatabase.app',
      Constants.firebaseJsonToUse => 'shopping-list.json',
    };
  }
}
