import 'package:algorand_evoting/utils/services/rest_api_service.dart';

T tryCast<T>(dynamic x, {required T fallback}) {
  try {
    return (x as T);
  } on CastError catch (e) {
    print('CastError when trying to cast $x to $T!');
    return fallback;
  }
}

bool apiInputIsValid(Map data, RestApiOperation operation) {
  switch (operation) {
    case RestApiOperation.create:
      if (data.containsKey('assetId') &&
          data['assetId'] is String &&
          data.containsKey('description') &&
          data['description'] is String &&
          data.containsKey('title') &&
          data['title'] is String &&
          data.containsKey('options') &&
          data['option'] is List<String> &&
          (data['option'] as List).length > 1 &&
          data.containsKey('passphrase') &&
          data['passphrase'] is String &&
          data.containsKey('regBegin') &&
          data['regBegin'] is String &&
          data.containsKey('regEnd') &&
          data['regEnd'] is String &&
          data.containsKey('voteBegin') &&
          data['voteBegin'] is String &&
          data.containsKey('voteEnd') &&
          data['voteEnd'] is String) return true;
      return false;
    case RestApiOperation.register:
    case RestApiOperation.delete:
      if (data.containsKey('passphrase') && data['passphrase'] is String)
        return true;
      return false;
    case RestApiOperation.vote:
      if (data.containsKey('passphrase') &&
          data['passphrase'] is String &&
          data.containsKey('choice') &&
          data['choice'] is String) return true;
      return false;
    default:
      return false;
  }
}
