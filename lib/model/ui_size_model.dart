class UISizeModel {
  final double? width;
  final double? maxWidth;
  final double? height;
  final double? maxHeight;
  UISizeModel({this.width, this.maxWidth, this.height, this.maxHeight});

  UISizeModel copyWith({
    double? width,
    double? maxWidth,
    double? height,
    double? maxHeight,
  }) {
    return UISizeModel(
      width: width ?? this.width,
      maxWidth: maxWidth ?? this.maxWidth,
      height: height ?? this.height,
      maxHeight: maxHeight ?? this.maxHeight,
    );
  }
}
