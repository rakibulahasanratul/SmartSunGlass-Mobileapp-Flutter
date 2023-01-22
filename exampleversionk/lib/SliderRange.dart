/*
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class SliderRange extends StatefulWidget {
  SliderRange(this.rangeSetter);
  final Function(RangeValues values) rangeSetter;

  @override
  State<SliderRange> createState() => _RangeSliderState(rangeSetter);
}
class _RangeSliderState extends State<SliderRange> {
  RangeValues _currentRangeValues = const RangeValues(40, 80);
  _RangeSliderState(this.rangeSetter);
  final Function(RangeValues values) rangeSetter;
  @override
  Widget build(BuildContext context) {

    return RangeSlider(
      values: _currentRangeValues,
      max: 100,
      divisions: 5,
      labels: RangeLabels(
        _currentRangeValues.start.round().toString(),
        _currentRangeValues.end.round().toString(),
      ),
    onChanged: (RangeValues values) {
      setState(() {
        print(_currentRangeValues);
        _currentRangeValues = values;
        print(_currentRangeValues);
        rangeSetter(values);
      });
    }
    );
  }
}

SliderRange((RangeValues values) {
          print("hell0");
        print(values);
        print(services[3].characteristics[0]);
        services[3].characteristics[0].write([
          values.start.toInt(),
          values.end.toInt()
        ]);})
*/