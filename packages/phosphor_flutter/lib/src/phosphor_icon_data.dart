library phosphor_flutter;

import 'package:flutter/widgets.dart';

// Patched for Flutter 3.47+, where IconData is a final class and can no longer
// be extended. Icons are now plain IconData; duotone icons render their
// primary layer only.
typedef PhosphorIconData = IconData;
typedef PhosphorFlatIconData = IconData;
typedef PhosphorDuotoneIconData = IconData;
