import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:meta/meta.dart';

import 'package:localstorage/localstorage.dart';

class LocalStorageAdapter {

  final LocalStorage localStorage;

  LocalStorageAdapter({@required this.localStorage});

  Future<void> save({@required String key, @required dynamic value}) async {
    await localStorage.deleteItem(key);
    await localStorage.setItem(key, value);
  }
}

class LocalStorageSpy extends Mock implements LocalStorage {}

void main() {

  String key;
  dynamic value;

  LocalStorageAdapter sut;
  LocalStorage localStorageSpy;

  setUp(() {
    key = faker.randomGenerator.string(4);
    value = faker.randomGenerator.string(30);

    localStorageSpy = LocalStorageSpy();
    sut = LocalStorageAdapter(localStorage: localStorageSpy);
  });

  void mockDeleteItemError() => when(localStorageSpy.deleteItem(any)).thenThrow(Exception());

  void mockSaveItemError() => when(localStorageSpy.setItem(any, any)).thenThrow(Exception());

  test('Should LocalStorageAdapter calls save with correct values', () async {
    
    await sut.save(key: key, value: value);

    verify(localStorageSpy.deleteItem(key)).called(1);
    verify(localStorageSpy.setItem(key, value)).called(1);

  });

  test('Should throw if deleteItem throws', () async {

    mockDeleteItemError();
    
    final future = sut.save(key: key, value: value);

    expect(future, throwsA(TypeMatcher<Exception>()));

  });

  test('Should throw if save throws', () async {

    mockSaveItemError();
    
    final future = sut.save(key: key, value: value);

    expect(future, throwsA(TypeMatcher<Exception>()));

  });
}