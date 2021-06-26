import 'package:algorand_dart/algorand_dart.dart';
import 'package:formz/formz.dart';

enum AssetInputError { empty }

class AssetInput extends FormzInput<Asset?, AssetInputError> {
  const AssetInput.pure() : super.pure(null);
  const AssetInput.dirty([Asset? value]) : super.dirty(value);

  @override
  AssetInputError? validator(Asset? value) {
    return value?.index != null ? null : AssetInputError.empty;
  }
}
