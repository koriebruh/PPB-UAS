import 'package:flutter/material.dart';

void navigateTo(BuildContext context, String route, {Object? arguments}) {
  Navigator.pushNamed(context, route, arguments: arguments);
}
