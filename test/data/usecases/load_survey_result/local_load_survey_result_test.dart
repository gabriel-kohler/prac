import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:practice/domain/helpers/domain_error.dart';
import 'package:practice/domain/entities/entities.dart';

import 'package:practice/data/usecases/usecases.dart';
import 'package:practice/data/cache/cache.dart';

class CacheStorageSpy extends Mock implements CacheStorage {}

void main() {

  

  group('loadBySurvey', () {

    CacheStorage cacheStorageSpy;
    LocalLoadSurveyResult sut;

    Map listData;
    String surveyId;

    PostExpectation mockFetchCall() => when(cacheStorageSpy.fetch(key: anyNamed('key')));

    void mockFetchData(Map json) {
      listData = json;
      mockFetchCall().thenAnswer((_) async => listData);
    }

    void mockFetchError() => mockFetchCall().thenThrow(Exception());

    Map mockValidData() => {
          'surveyId': faker.guid.guid(),
          'question': faker.lorem.sentence(),
          'answers': [
            {
              'image': faker.internet.httpUrl(),
              'answer': faker.lorem.sentence(),
              'isCurrentAnswer': 'true',
              'percent': '40',
            },
            {
              'answer': faker.lorem.sentence(),
              'isCurrentAnswer': 'false',
              'percent': '60',
            },
          ],
        };


    setUp(() {
      cacheStorageSpy = CacheStorageSpy();
      sut = LocalLoadSurveyResult(cacheStorage: cacheStorageSpy);
      surveyId = faker.guid.guid();
    });
    test('Should call FetchCacheStorage with correct key', () async {
    
    mockFetchData(mockValidData());

    await sut.loadBySurvey(surveyId: surveyId);

    verify(cacheStorageSpy.fetch(key: 'survey_result/$surveyId')).called(1);

    });

    test('Should return a list of surveyResult on success', () async {
      
      mockFetchData(mockValidData());

      final surveys = await sut.loadBySurvey(surveyId: surveyId);

      final mockSurvers = SurveyResultEntity(
        surveyId: listData['surveyId'],
        question: listData['question'],
        answers: [
          SurveyAnswerEntity(
            image: listData['answers'][0]['image'],
            answer: listData['answers'][0]['answer'], 
            isCurrentAnswer: true, 
            percent: 40,
          ),
          SurveyAnswerEntity(
            image: listData['answers'][1]['image'],
            answer: listData['answers'][1]['answer'], 
            isCurrentAnswer: false, 
            percent: 60,
          ),
        ]
      );
      
      expect(surveys, mockSurvers);

    });

  test('Should throw UnexpectedError if cache is empty', () async {
    
      mockFetchData({});

      final future = sut.loadBySurvey(surveyId: surveyId);

      expect(future, throwsA(DomainError.unexpected));

    });

    test('Should throw UnexpectedError if cache is null', () async {
    
      mockFetchData(null);

      final future = sut.loadBySurvey(surveyId: surveyId);

      expect(future, throwsA(DomainError.unexpected));

    });

    test('Should throw UnexpectedError if cache is invalid', () async {
    
      mockFetchData({
        'surveyId': faker.guid.guid(),
        'question': faker.lorem.sentence(),
        'answers': [
          {
            'image': faker.internet.httpUrl(),
            'answer': faker.lorem.sentence(),
            'isCurrentAnswer': 'invalid bool',
            'percent': 'invalid int',
          },
        ],
      });

    final future = sut.loadBySurvey(surveyId: surveyId);

    expect(future, throwsA(DomainError.unexpected));

  });

    test('Should throw UnexpectedError if cache is incomplete', () async {
    
      mockFetchData({'surveyId': faker.guid.guid()});

      final future = sut.loadBySurvey(surveyId: surveyId);

      expect(future, throwsA(DomainError.unexpected));

    });

    test('Should throw UnexpectedError if cache throws', () async {
    
      mockFetchError();

      final future = sut.loadBySurvey(surveyId: surveyId);

      expect(future, throwsA(DomainError.unexpected));

    });
  });


}