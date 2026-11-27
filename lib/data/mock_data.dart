import '../models/activity.dart';
import '../models/user_profile.dart';

/// Dados simulados de um evento fictício. O projeto não usa servidor.
const eventName = 'Semana Acadêmica de Tecnologia';
const eventPlace = 'Campus Central (local fictício)';

DateTime _at(int day, int hour, [int minute = 0]) =>
    DateTime(2026, 12, day, hour, minute);

final List<Activity> activities = [
  Activity(
    id: 'a01',
    title: 'Abertura: tecnologia e pessoas',
    speaker: 'Profa. Helena Duarte',
    room: 'Auditório A',
    theme: 'UX',
    type: 'Palestra',
    start: _at(9, 8, 30),
    end: _at(9, 10),
    description:
        'Conversa de abertura sobre como decisões de projeto afetam quem usa.',
  ),
  Activity(
    id: 'a02',
    title: 'Primeiros passos com Flutter',
    speaker: 'Rafael Nunes',
    room: 'Laboratório 2',
    theme: 'Mobile',
    type: 'Minicurso',
    start: _at(9, 14),
    end: _at(9, 17),
    description: 'Widgets, layout e navegação em um aplicativo de exemplo.',
  ),
  Activity(
    id: 'a03',
    title: 'Carreira em tecnologia',
    speaker: 'Camila Prado',
    room: 'Auditório B',
    theme: 'Carreira',
    type: 'Mesa-redonda',
    start: _at(9, 19),
    end: _at(9, 21),
    description: 'Portfólio, primeiro emprego e trabalho em equipe.',
  ),
  Activity(
    id: 'a04',
    title: 'Pesquisa com usuários na prática',
    speaker: 'Juliana Matos',
    room: 'Sala 104',
    theme: 'UX',
    type: 'Oficina',
    start: _at(10, 8, 30),
    end: _at(10, 11, 30),
    description: 'Roteiro de entrevista, observação e organização dos achados.',
  ),
  Activity(
    id: 'a05',
    title: 'Visualização de dados',
    speaker: 'Prof. André Sales',
    room: 'Laboratório 1',
    theme: 'Dados',
    type: 'Minicurso',
    start: _at(10, 14),
    end: _at(10, 16),
    description: 'Como escolher gráficos e evitar leituras erradas.',
  ),
  Activity(
    id: 'a06',
    title: 'Acessibilidade em aplicativos',
    speaker: 'Marina Cordeiro',
    room: 'Auditório A',
    theme: 'UX',
    type: 'Palestra',
    start: _at(10, 16, 30),
    end: _at(10, 18),
    description: 'Contraste, tamanho de toque e leitores de tela.',
  ),
  Activity(
    id: 'a07',
    title: 'Publicando seu primeiro app',
    speaker: 'Rafael Nunes',
    room: 'Laboratório 2',
    theme: 'Mobile',
    type: 'Oficina',
    start: _at(10, 19),
    end: _at(10, 21),
    description: 'Preparação de versão, testes e publicação.',
  ),
  Activity(
    id: 'a08',
    title: 'Introdução à análise de dados',
    speaker: 'Prof. André Sales',
    room: 'Laboratório 1',
    theme: 'Dados',
    type: 'Minicurso',
    start: _at(11, 9),
    end: _at(11, 11),
    description: 'Limpeza, exploração e perguntas sobre um conjunto de dados.',
  ),
  Activity(
    id: 'a09',
    title: 'Pitch: como apresentar um produto',
    speaker: 'Camila Prado',
    room: 'Auditório B',
    theme: 'Carreira',
    type: 'Oficina',
    start: _at(11, 14),
    end: _at(11, 16),
    description: 'Estrutura da fala, demonstração e controle do tempo.',
  ),
  Activity(
    id: 'a10',
    title: 'Encerramento e networking',
    speaker: 'Comissão organizadora',
    room: 'Pátio central',
    theme: 'Carreira',
    type: 'Encontro',
    start: _at(11, 18),
    end: _at(11, 20),
    description: 'Troca de contatos entre participantes e convidados.',
  ),
];

/// Contato fictício para demonstrar a troca de cartões.
const sampleContact = UserProfile(
  name: 'Marina Cordeiro',
  email: 'marina.cordeiro@exemplo.com',
  course: 'Design de Interação',
  institution: 'Instituição fictícia',
);
