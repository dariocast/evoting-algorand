import 'package:formz/formz.dart';

enum DateInputError { empty, past }

class DateInput extends FormzInput<DateTime?, DateInputError> {
  const DateInput.pure() : super.pure(null);
  const DateInput.dirty([DateTime? value = null]) : super.dirty(value);

  @override
  DateInputError? validator(DateTime? value) {
    return value?.isAfter(DateTime.now()) == true ? null : DateInputError.past;
  }
}
