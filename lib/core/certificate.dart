/// Identificação e texto dos certificados de demonstração.
library;

import '../data/mock_data.dart';
import '../models/activity.dart';
import '../models/user_profile.dart';
import 'formatters.dart';

/// Código estável para o par participante e atividade.
/// Serve só para identificar o documento no protótipo, não para validá-lo.
String certificateCode(UserProfile profile, Activity activity) {
  var hash = 7;
  for (final unit in '${profile.email}|${activity.id}'.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  final digits = hash.toRadixString(36).toUpperCase().padLeft(6, '0');
  return '${activity.id.toUpperCase()}-$digits';
}

String certificateText(UserProfile profile, Activity activity) =>
    'Certificamos que ${profile.name} participou da atividade '
    '"${activity.title}" (${activity.type.toLowerCase()}), no evento '
    '$eventName, em ${formatDate(activity.start)}, com carga horária de '
    '${formatHours(activity.duration)}.';
