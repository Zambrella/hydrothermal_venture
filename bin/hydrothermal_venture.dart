import 'package:equatable/equatable.dart';
import 'package:hydrothermal_venture/hydrothermal_venture.dart' as hydrothermal_venture;
import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';

class Point extends Equatable {
  const Point(this.x, this.y);

  final int x;
  final int y;

  @override
  String toString() {
    return '$x,$y';
  }

  @override
  List<Object?> get props => [x, y];
}

class Line {
  const Line(this.p1, this.p2);

  final Point p1;
  final Point p2;

  Point get smallestX => p1.x < p2.x ? p1 : p2;
  Point get biggestX => p1.x > p2.x ? p1 : p2;
  Point get smallestY => p1.y < p2.y ? p1 : p2;
  Point get biggestY => p1.y > p2.y ? p1 : p2;

  List<Point>? straightPath() {
    final List<Point> path = [];
    if (p1.x == p2.x) {
      // Get the difference between the y values
      final difference = (biggestY.y - smallestY.y);
      // Create a set of points between the two points
      //? What if it is negative?
      for (int i = 0; i <= difference; i++) {
        path.add(Point(smallestY.x, smallestY.y + i));
      }
      return path;
    }

    if (p1.y == p2.y) {
      // Get the difference between the x values
      final difference = (biggestX.x - smallestX.x);
      // Create a set of points between the two points
      //? What if it is negative?
      for (int i = 0; i <= difference; i++) {
        path.add(Point(smallestX.x + i, smallestX.y));
      }
      return path;
    }

    return null;
  }

  @override
  String toString() {
    return '{$p1 -> $p2}';
  }
}

void main(List<String> arguments) async {
  ArgParser parser = ArgParser()..addOption('fileLocation', abbr: 'f');
  ArgResults argResults = parser.parse(arguments);
  final path = argResults['fileLocation'];
  final file = await File(path).readAsString();
  final List<String> list = LineSplitter().convert(file);
  final lines = parseLines(list);
  print(calculateOverlaps(lines));
}

int? calculateOverlaps(List<Line> lines) {
  final allPoints = <Point>[];

  for (final line in lines) {
    final points = line.straightPath();
    if (points != null) {
      allPoints.addAll(points);
    }
  }

  final pointOccurences = <Point, int>{};

  for (final point in allPoints) {
    if (pointOccurences.containsKey(point)) {
      pointOccurences[point] = pointOccurences[point]! + 1;
    } else {
      pointOccurences[point] = 1;
    }
  }

  var countOfTwoOrMore = 0;

  pointOccurences.forEach((key, value) {
    if (value >= 2) {
      countOfTwoOrMore++;
    }
  });

  return countOfTwoOrMore;
}

List<Line> parseLines(List<String> list) {
  final List<Line> lines = [];

  for (final line in list) {
    final twoCoords = line.split('->');
    final firstNumbers = twoCoords[0].split(',');
    final firstPoint = Point(int.parse(firstNumbers[0]), int.parse(firstNumbers[1]));
    final secondNumbers = twoCoords[1].split(',');
    final secondPoint = Point(int.parse(secondNumbers[0]), int.parse(secondNumbers[1]));
    lines.add(Line(firstPoint, secondPoint));
  }

  return lines;
}
