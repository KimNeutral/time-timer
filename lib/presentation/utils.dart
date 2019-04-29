double secondsToAngle(double seconds) {
  return seconds * 0.1;
}

double angleToSeconds(double angle) {
  var seconds = angle * 10;

  return seconds <= 0 ? 0 : seconds;
}