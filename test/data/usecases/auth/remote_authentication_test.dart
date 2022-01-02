import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';


import 'package:practice/domain/helpers/helpers.dart';
import 'package:practice/domain/usecases/auth/authentication.dart';

import 'package:practice/data/usecases/auth/remote_authentication.dart';
import 'package:practice/data/http/http.dart';

import '../../../domain/mocks/mocks.dart';
import '../../../infra/mocks/mocks.dart';


class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  late HttpClient httpClient;
  late String url;
  late RemoteAuthentication sut;
  late AuthenticationParams params;
  late Map apiResult;

  When mockRequest() => when(() => (httpClient.request(url: any(named: 'url'), method: any(named: 'method'), body: any(named: 'body'))));
  

  void mockHttpError(HttpError error) {
    mockRequest().thenThrow(error);
  }

  void mockHttpData(Map data) {
    apiResult = data;
    mockRequest().thenAnswer((_) async => data);
  }

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);

    params = ParamsFactory.makeAuthenticationParams();

    mockHttpData((ApiFactory.makeAccountJson()));
  });

  test('Should call httpClient with correct values', () async {

    await sut.auth(params: params);

    final body = {
      'email': params.email,
      'password': params.password,
    };

    verify(() => (httpClient.request(
      url: url,
      method: 'post',
      body: body,
    )));
  });

  test('Should throw UnexpectedError if HttpClient returns 400', () async {

    mockHttpError(HttpError.badRequest);

    final future = sut.auth(params: params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw UnexpectedError if HttpClient returns 404', () {

    mockHttpError(HttpError.notFound);

    final future = sut.auth(params: params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw UnexpectedError if HttpClient returns 500', () async {

    mockHttpError(HttpError.serverError);

    final future = sut.auth(params: params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw InvalidCredentialsError if HttpClient returns 401', () async {

    mockHttpError(HttpError.unauthorized);

    final future = sut.auth(params: params);

    expect(future, throwsA(DomainError.invalidCredentials));

  });

  test('Should return an Account if HttpClient returns 200', () async {

    final account  = await sut.auth(params: params);

    expect(account.token, apiResult['accessToken']);

  });

   test('Should return an UnexpectedError if HttpClient returns 200 with invalid data', () async {

    mockHttpData({'invalid_key': 'invalid_value'});

    final future  = sut.auth(params: params);

    expect(future, throwsA(DomainError.unexpected));
  });
 
}
