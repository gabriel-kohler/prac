import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:practice/domain/entities/account_entity.dart';
import 'package:practice/domain/usecases/add_current_account.dart';
import 'package:test/test.dart';
import 'package:meta/meta.dart';

abstract class SaveSecureCurrentAccount {
  void saveSecure({@required String key, @required String value});
}

class SaveSecureCurrentAccountSpy extends Mock implements SaveSecureCurrentAccount {}

class SaveCurrentAccount implements AddCurrentAccount {

  final SaveSecureCurrentAccount saveSecureCurrentAccount;

  SaveCurrentAccount({@required this.saveSecureCurrentAccount});

  @override
  Future<void> save({@required AccountEntity account}) async {
    saveSecureCurrentAccount.saveSecure(key: 'token', value: account.token);
  }

}

void main() {

  test('ensure SaveCurrentAccount call SaveSecureCurrentAccount with correct values', () async {
    final saveSecureCurrentAccountSpy = SaveSecureCurrentAccountSpy();
    final sut = SaveCurrentAccount(saveSecureCurrentAccount: saveSecureCurrentAccountSpy);

    final account = AccountEntity(faker.guid.guid());

    await sut.save(account: account);

    verify(saveSecureCurrentAccountSpy.saveSecure(key: 'token', value: account.token)).called(1);
  });
}