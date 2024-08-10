import 'package:flutter/material.dart';

BorderRadius get botBorderRadius {
  return const BorderRadius.only(
      topLeft: Radius.circular(18),
      topRight: Radius.circular(18),
      bottomLeft: Radius.circular(0),
      bottomRight: Radius.circular(18));
}

BorderRadius get userBorderRadius {
  return const BorderRadius.only(
      topLeft: Radius.circular(18),
      topRight: Radius.circular(18),
      bottomLeft: Radius.circular(18),
      bottomRight: Radius.circular(0));
}
