# Projeto Semestral de UX — Bloco 3

> **Trabalho acadêmico** da disciplina **UX Design e Prototipação de Interfaces** (WallTech).
> Aplicativo front-end em **Flutter/Dart**, desenvolvido para fins de avaliação.

| Item | Situação |
| :--- | :--- |
| **Entrega** | **30/11/2026** — Apresentações Executivas (Pitch de UX) |
| Devolutiva | 07/12/2026 |
| Valor do Bloco 3 | 16 pontos (Pitch 8 + Documentação e Implementação 8) |
| Tema | **10 — Eventos Acadêmicos, Credenciamento e Networking** ([todos os temas](docs/TEMAS.md)) |
| Equipe | _a preencher_ |
| Código | ainda não iniciado |

O Bloco 3 integra a Unidade 2 (OAT2, 20 pontos): 16 do projeto e 4 de atividades gerais.

## Objetivo

Segundo o contrato pedagógico, o Bloco 3 consolida a capacidade de engenharia do estudante por meio de:

1. codificação funcional da solução;
2. validação por testes;
3. manual técnico de reprodução;
4. defesa executiva (pitch) do produto.

**Não é preciso desenvolver o backend completo.** O foco são telas, fluxos de navegação e componentes responsivos em Flutter/Dart. Dados simulados (mocks) atendem a esse objetivo.

## Tema 10 — Eventos Acadêmicos, Credenciamento e Networking

Solução para a gestão de eventos acadêmicos.

**Telas que o tema pede:**

- grade de programação interativa, com filtros de tempo e tema;
- leitor de QR Code para check-in;
- visualização de certificados gerados automaticamente;
- perfil de networking, com troca de contatos ou cartão virtual.

**Ligação com a disciplina:** hierarquia de informação no tempo e no espaço, muitos dados em telas pequenas e a "jornada do participante", para que o app ajude na circulação durante o evento.

### Proposta de telas por frente

A divisão abaixo é uma sugestão. As quatro telas do tema se somam às que o contrato pede para os subgrupos.

| Frente | Telas | Responsável |
| :--- | :--- | :--- |
| 1. Core & Onboarding | Login/cadastro, home com próximas atividades, configurações da conta | _a preencher_ |
| 2. Funcionalidade principal | Programação com filtros, detalhe da atividade, check-in por QR Code | _a preencher_ |
| 3. Relatórios, Histórico & Handoff | Histórico de presença, certificados, networking com cartão virtual | _a preencher_ |

O networking ficou na frente 3 para equilibrar a divisão.

### Fluxo principal da demonstração

Login → home → filtrar a programação → abrir uma atividade → fazer check-in → ver a presença no histórico → abrir o certificado → compartilhar o cartão virtual

### Decisões para o protótipo (sugestões)

- **Dados:** evento, atividades, presenças e contatos simulados, sem backend.
- **Certificado:** liberado na tela quando a presença é registrada no app.
- **QR Code:** testar a câmera em um celular real logo no começo e ter um código de teste. Prever um botão de simulação, identificado como tal, e uma mensagem para o caso de a câmera ser negada.
- **Estados a tratar:** filtro sem resultado, código inválido, check-in repetido e histórico vazio.

## Telas e divisão da equipe

O mínimo é **1 tela por membro do grupo**, com as telas divididas em 3 subgrupos:

| Subgrupo | Tamanho no contrato | Foco | Responsabilidade |
| :--- | :--- | :--- | :--- |
| 1. Core & Onboarding | 3 a 4 alunos | Login/cadastro, alternância de perfis (se houver), home e configurações da conta | Autenticação inicial, persistência básica e identidade visual central |
| 2. Transacional / Funcionalidade principal | 4 a 5 alunos | Tela central do negócio (ex.: PDV, comparador de preços, quiz) | Fluxos complexos, listagens dinâmicas, filtros avançados e interação principal |
| 3. Relatórios, Histórico & Handoff | 4 a 5 alunos | Histórico, gráficos, comprovantes/recibos ou exportação, documentação de testes | Telas de feedback, estados vazios e pacote de handoff |

> **Atenção:** esses tamanhos somam de 11 a 14 alunos. Se a equipe tiver só 3 pessoas, a proposta é cada uma assumir um subgrupo, mas isso **precisa ser confirmado com o professor**.

## Etapas

As datas abaixo são uma proposta para o prazo que resta, a partir de 26/11. O contrato define apenas a data de entrega.

### Etapa 1 — Definição e análise (26/11)

**Estudar e analisar:** a dor levantada no Bloco 1, o que foi definido no Bloco 2 e o texto do tema escolhido.

- [ ] Confirmar a equipe e a divisão das frentes
- [x] Confirmar o tema (10)
- [ ] Perguntar ao professor o tempo limite do pitch e o formato de envio dos documentos
- [ ] Listar as telas e o responsável por cada uma
- [ ] Desenhar o fluxo de navegação

**Pronto quando:** cada pessoa sabe quais telas vai entregar.

### Etapa 2 — Base do projeto (26/11)

**Estudar:** organização de pastas, rotas, tema global e layouts responsivos (`LayoutBuilder`, `MediaQuery`).

- [ ] Criar o projeto com `flutter create`
- [ ] Definir a estrutura de pastas e o gerenciamento de estado
- [ ] Configurar cores, tipografia e rotas
- [ ] Criar os dados simulados
- [ ] Anotar as versões do Flutter e do Dart usadas

**Pronto quando:** todos clonam o repositório e executam o app.

### Etapa 3 — Telas e fluxos (27/11 e 28/11)

**Estudar:** formulários e validação, listas, filtros e atualização de estado.

- [ ] Frente 1: login/cadastro, home e configurações
- [ ] Frente 2: tela central, listagem, filtros e ação principal
- [ ] Frente 3: histórico, resumo ou gráficos, comprovante e feedback
- [ ] Tratar estados vazios e erros
- [ ] Integrar as três frentes

**Pronto quando:** o fluxo principal funciona do começo ao fim.

### Etapa 4 — Testes (28/11)

**Estudar:** testes de unidade e de widget no Flutter e critérios de usabilidade.

- [ ] Escrever os cenários de teste, incluindo os de erro
- [ ] Executar `flutter test`
- [ ] Testar em tamanhos de tela diferentes
- [ ] Registrar resultados reais, com capturas de tela
- [ ] Registrar cada falha encontrada e como foi tratada

**Pronto quando:** há evidência de cada teste executado.

### Etapa 5 — Pacote de Handoff (29/11)

Documento complementar ao Bloco 2, sobre a construção e a homologação do software.

- [ ] **Arquitetura de implementação:** como o código foi estruturado
- [ ] **Guia de reprodução:** como clonar, configurar o ambiente e executar do zero
- [ ] **Testes:** cenários, validação de funcionamento e evidências de mitigação de falhas
- [ ] **Referências e rastreabilidade:** fontes citadas corretamente e autoria própria
- [ ] Pedir a alguém que siga o guia em outro computador

**Pronto quando:** essa pessoa executa o app sem ajuda.

### Etapa 6 — Pitch e Product Demo Day (29/11 e 30/11)

A apresentação deve conter:

- [ ] Resgate da dor (Bloco 1)
- [ ] Justificativa da solução escolhida
- [ ] Demonstração prática do app
- [ ] Avaliação do grau de prontidão para uso real

Preparação:

- [ ] Montar os slides
- [ ] Dividir as falas e ensaiar cronometrando
- [ ] Gravar um vídeo do app como reserva, caso a demonstração falhe

## Critérios de avaliação

### Pitch — 8 pontos

| Critério | Pontos |
| :--- | ---: |
| Prontidão e maturidade do produto: funcional, útil e bem-acabado | 3,0 |
| Clareza, oratória e expressão verbal | 2,0 |
| Qualidade visual e demonstração prática | 2,0 |
| Gestão e controle do tempo | 1,0 |

### Documentação Técnica e Implementação — 8 pontos

| Critério | Pontos |
| :--- | ---: |
| Clareza, coesão e reprodutibilidade: texto correto e guia funcional | 3,0 |
| Qualidade da arquitetura e da implementação | 2,0 |
| Rigor e validação dos testes | 2,0 |
| Autoria humana e referências | 1,0 |

## Bibliografia básica

- STATI RICARDO, Cesar; FREITAS SARMENTO, Camila. *Experiência do Usuários (UX)*. 2021. Biblioteca Virtual.
- BELMIRO DO NASCIMENTO, João. *Usabilidade Interface Homem-Máquina*. 2017. Biblioteca Virtual.
- LEWRICK, Michael; LINK, Patrick; LEIFER, Larry. *A jornada do design thinking: transformação digital prática de equipes, produtos, serviços, negócios e ecossistemas*. Rio de Janeiro: Alta Books, 2019. Minha Biblioteca.

As entradas seguem o texto do contrato. Confiram os dados nas obras antes de formatar as referências finais.

## Fonte

Resumo feito a partir de capturas de **parte** do contrato pedagógico. Em caso de divergência, valem o documento completo, o professor e o Blackboard, que é o canal oficial da disciplina.
