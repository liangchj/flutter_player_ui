import '../model/position_model.dart';

class PositionConstant {
  static PositionModel topPosition = PositionModel(left: 0, right: 0, top: 0);
  static PositionModel bottomPosition = PositionModel(
    left: 0,
    right: 0,
    bottom: 0,
  );
  static PositionModel leftPosition = PositionModel(
    left: 0,
    top: 0,
    bottom: 0,
  );
  static PositionModel rightPosition = PositionModel(
    top: 0,
    right: 0,
    bottom: 0,
  );
}
