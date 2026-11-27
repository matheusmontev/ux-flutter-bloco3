/// Identificação e texto dos certificados de demonstração.
library;

import '../models/activity.dart';
import '../models/event.dart';
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

const certificateDisclaimer =
    'Documento de demonstração, sem validade acadêmica.';

/// O que vai para a área de transferência.
String certificateShareText(
  UserProfile profile,
  Activity activity,
  Event event,
) =>
    '${certificateText(profile, activity, event)}\n'
    'Código: ${certificateCode(profile, activity)}\n'
    '$certificateDisclaimer';

String certificateText(UserProfile profile, Activity activity, Event event) =>
    'Certificamos que ${profile.name} participou da atividade '
    '"${activity.title}" (${activity.type.toLowerCase()}), no evento '
    '${event.name}, em ${formatDate(activity.start)}, com carga horária de '
    '${formatHours(activity.duration)}.';
