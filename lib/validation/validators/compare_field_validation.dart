import 'package:meta/meta.dart';

import 'package:practice/validation/dependencies/dependencies.dart';
import 'package:practice/presentation/dependencies/validation.dart';

class CompareFieldValidation implements FieldValidation {

  final String field;
  final String valueToCompare;

  CompareFieldValidation({@required this.field, @required this.valueToCompare});

  @override
  ValidationError validate({@required String value}) {
    if (value == valueToCompare) {
      return null;
    } else {
      return ValidationError.invalidField;
    }
  }

}