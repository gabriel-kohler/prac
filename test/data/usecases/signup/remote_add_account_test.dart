import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:meta/meta.dart';

import 'package:practice/data/usecases/usecases.dart';
import 'package:practice/data/http/http.dart';

import 'package:practice/domain/entities/entities.dart';
import 'package:practice/domain/helpers/helpers.dart';
import 'package:practice/domain/usecases/signup/add_account.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {

  String url;
  HttpClient httpClient;
  RemoteAddAccount sut;
  AddAccountParams params;
  String token;

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAddAccount(httpClient: httpClient, url: url);
    token = faker.guid.guid();

    params = AddAccountParams(
      email: faker.internet.email(), 
      password: faker.internet.password(), 
      confirmPassowrd: faker.internet.password(), 
      name: faker.person.name(),
    );

  });

  PostExpectation mockHttpCall() => when(httpClient.request(url: anyNamed('url'), method: anyNamed('method'), body: anyNamed('body')));

  void mockHttpError(HttpError error) => mockHttpCall().thenThrow(error);

  void mockHttpRequest({@required Map responseBody}) => mockHttpCall().thenAnswer((_) async => responseBody);

  test('Should RemoteAddAccount calls HttpClient with correct params', () async {

    mockHttpRequest(responseBody: {'accessToken' : token});
    
    final body = {
      'name' : params.name,
      'email' : params.email,
      'password' : params.password,
      'confirmPassword' : params.confirmPassowrd,
    };

    await sut.add(params: params);

    verify(httpClient.request(url: url, method: 'post', body: body)).called(1);
  });

  test('Should throw UnexpetedError if HttpClient returns 400', () async {

    mockHttpError(HttpError.badRequest);

    final future = sut.add(params: params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw EmailInUseError if HttpClient returns 403', () async {

    mockHttpError(HttpError.forbidden);

    final future = sut.add(params: params);

    expect(future, throwsA(DomainError.emainInUse));
  });

  test('Should throw UnexpectedError if HttpClient returns 404', () {

    mockHttpError(HttpError.notFound);

    final future = sut.add(params: params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw UnexpectedError if HttpClient returns 500', () async {

    mockHttpError(HttpError.serverError);

    final future = sut.add(params: params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should return AccountEntity if HttpClient returns 200', () async {

    mockHttpRequest(responseBody: {'accessToken' : token});
    
    final account = await sut.add(params: params);

    expect(account, AccountEntity(token));
  });

  test('Should throw UnexpectedError if HttpClient returns 200 with invalid data', () async {

    mockHttpRequest(responseBody: {'invalid_key' : 'invalid_value'});

    final future = sut.add(params: params);

    expect(future, throwsA(DomainError.unexpected));
  });

}