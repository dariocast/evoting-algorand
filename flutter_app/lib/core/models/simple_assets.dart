import 'package:equatable/equatable.dart';

class SimpleAsset extends Equatable {
  final String name;
  final int id;
  final int balance;
  final String unitName;
  final bool isCreator;

  const SimpleAsset({
    required this.name,
    required this.id,
    required this.balance,
    required this.unitName,
    required this.isCreator,
  });

  @override
  List<Object?> get props => [name, id, balance, isCreator, unitName];
}
