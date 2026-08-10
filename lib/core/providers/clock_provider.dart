import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/domain/services/clock.dart';

final clockProvider = Provider<Clock>((ref) => const SystemClock());
