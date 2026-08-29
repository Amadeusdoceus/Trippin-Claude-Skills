# Trippin — Briefing de Produto

**Documento:** Briefing de produto
**Versão:** v0.1 — rascunho
**Data:** 24 ago 2026
**Status:** Pré-MVP

> Um só lugar para a agenda, os gastos e os documentos de qualquer viagem — organizado como um itinerário vivo que todo o grupo acompanha junto.

---

## 1. Resumo executivo

Trippin é um aplicativo de viagem que substitui a bagunça de grupos de WhatsApp, planilhas de gastos e pastas de PDF por uma agenda única e compartilhada. A viagem inteira — cronograma, despesas e documentos — vive num só lugar, e se atualiza sozinha conforme os dias passam.

- **Problema:** informação de viagem fica espalhada entre chats, e-mails, prints e apps de banco. Ninguém sabe quem já pagou o quê, nem onde está o voucher do hotel.
- **Solução:** uma agenda de viagem colaborativa com quatro módulos centrais: usuários, cronograma, despesas e leitura inteligente de arquivos.
- **Diferencial:** o cronograma acompanha a data real da viagem dia a dia, e o app entende PDFs, prints e fotos sozinho — sem formulário manual.
- **Formato:** app mobile-first (iOS/Android) com companion web para planejamento e visualização em telas maiores.

## 2. Público-alvo

O produto nasce para grupos — famílias, casais, amigos ou colegas de trabalho — que organizam uma viagem junto e precisam de um ponto único de verdade.

- **Organizador (Admin)** — quem monta a viagem. Cria o cronograma, convida participantes, define permissões e centraliza os documentos. Quer visão de controle e facilidade para editar em cima da hora.
- **Participante (Convidado)** — quem viaja junto. Consulta a agenda do dia, sobe seus próprios comprovantes e acompanha o que deve ou tem a receber. Quer simplicidade e notificações no momento certo.

## 3. Arquitetura em módulos

O produto é dividido em quatro módulos independentes que conversam entre si através da viagem como entidade central — pensados como "subagentes" especializados, cada um responsável por uma fatia clara do problema.

### Módulo 01 — Gestão de usuários (Admin · Convidado)

Controla quem pode ver e editar o quê dentro de cada viagem. Cada viagem tem um ou mais administradores e uma lista de convidados, com convite por link ou código.

- Admin cria, edita e apaga eventos, despesas e documentos
- Convidado visualiza tudo e edita apenas suas próprias contribuições
- Convite por link, QR code ou código curto de viagem
- Promoção de convidado a coadministrador (coorganizadores)
- Perfil simples: nome, foto, telefone para contato de emergência
- Histórico de quem alterou o quê (auditoria leve)

### Módulo 02 — Cronograma e calendário (Diário · Semanal · Mensal)

O coração do app: uma agenda que se comporta como calendário e como roteiro ao mesmo tempo, sempre ancorada na data real da viagem.

- Visão diária estilo linha do tempo (voos, passeios, refeições)
- Visão semanal e mensal para enxergar a viagem inteira
- "Hoje na viagem" atualiza sozinho conforme a data avança
- Eventos com local, horário, link de mapa e notas
- Notificações antes de cada compromisso do dia
- Reordenar e mover eventos entre dias por arrastar e soltar

### Módulo 03 — Divisor de despesas (split entre participantes)

Toda despesa pode nascer direto de um evento do cronograma (o jantar de terça, o táxi do aeroporto) e ser dividida entre quem participou.

- Despesa vinculada a um evento específico da agenda
- Divisão igual, por partes customizadas ou por valor fixo
- Saldo por participante: quem deve e quem tem a receber
- Suporte a múltiplas moedas com conversão automática
- Quitação registrada manualmente (sem mover dinheiro de verdade)
- Resumo final da viagem com o extrato consolidado por pessoa

### Módulo 04 — Leitor de arquivos inteligente (PDF · Texto · Imagem · Print)

Em vez de digitar tudo à mão, o usuário sobe o comprovante e o app extrai a informação certa — adaptando a leitura ao tipo de arquivo recebido.

- Leitura de PDF: passagens, vouchers de hotel, reservas
- OCR em screenshots e fotos (.png, .jpeg) — recibos, comprovantes de Pix
- Extração adaptativa: identifica se é voo, hospedagem ou despesa
- Preenche automaticamente evento ou despesa com os dados lidos
- Arquivo original guardado como anexo, sempre consultável
- Revisão humana antes de confirmar o que foi extraído

## 4. Jornada de uso

Do planejamento ao dia a dia da viagem, em seis passos:

1. **Criar a viagem** — Admin define nome, datas e destino; o calendário nasce automaticamente com o intervalo de dias correto.
2. **Convidar participantes** — compartilha um link; cada convidado entra como participante com acesso à agenda e às despesas.
3. **Montar o cronograma** — sobe passagens e reservas em PDF/print; o leitor de arquivos cria os eventos automaticamente, revisados antes de salvar.
4. **Viajar com a agenda ao vivo** — o app abre direto na visão "hoje", mostrando o próximo compromisso e lembretes no horário certo.
5. **Registrar despesas no momento** — cada gasto é lançado a partir do evento do dia e dividido entre quem participou daquele passeio ou refeição.
6. **Fechar as contas** — ao fim da viagem, o extrato consolidado mostra quem deve para quem, pronto para acertar.

## 5. Modelo de dados

Cinco entidades centrais sustentam os quatro módulos:

| Entidade | Atributos principais |
|---|---|
| **Viagem** | nome, destino, datas, lista de participantes, moeda base |
| **Usuário** | perfil e contato, papel (admin / convidado), viagens das quais participa |
| **Evento** | data, hora, local, tipo (voo, hospedagem, passeio), participantes vinculados |
| **Despesa** | valor, moeda, categoria, evento de origem, divisão entre participantes |
| **Documento** | arquivo original (PDF/imagem), dados extraídos (OCR/parser), vínculo a evento ou despesa |

## 6. Stack sugerida

Ponto de partida a validar contra a experiência prévia da equipe antes de travar.

| Camada | Escolha | Por quê |
|---|---|---|
| App mobile | React Native + Expo | Uma base de código para iOS e Android, com acesso nativo à câmera para digitalizar documentos |
| Backend | Node.js (NestJS) ou Supabase | APIs REST/GraphQL simples para viagem, evento, despesa e usuário; Supabase acelera auth e realtime no MVP |
| Banco de dados | PostgreSQL | Relações claras entre viagem → evento → despesa → participante; bom suporte a permissões por linha (RLS) |
| Leitura de arquivos | OCR (Google Vision / Tesseract) + LLM de extração | OCR converte imagem em texto; um LLM interpreta o texto e classifica em voo, hospedagem ou despesa |
| Armazenamento | S3 / Supabase Storage | Guarda o PDF ou imagem original vinculado ao documento extraído |
| Notificações | Push (FCM/APNs) + agendador | Lembretes do cronograma no horário certo, mesmo com o app fechado |

## 7. Roadmap

### Fase 1 — MVP: agenda compartilhada
- Criar viagem, convidar participantes, papéis admin/convidado
- Cronograma diário/semanal/mensal com entrada manual de eventos
- Divisor de despesas com divisão igual e por valor customizado

### Fase 2 — Leitura inteligente: documentos que se preenchem sozinhos
- Upload de PDF e imagem com OCR e extração automática
- Classificação adaptativa (voo, hotel, recibo) com revisão humana
- Vínculo automático entre documento, evento e despesa

### Fase 3 — Expansão: viagem colaborativa avançada
- Multi-moeda com conversão automática e taxas do dia
- Modo offline para regiões sem sinal durante a viagem
- Exportar itinerário e extrato final em PDF compartilhável

## 8. Riscos e considerações

- **Privacidade de documentos** — passagens e comprovantes contêm dados pessoais e financeiros sensíveis; exige criptografia em repouso e controle de acesso rígido por viagem.
- **Custo de OCR/LLM** — extração de arquivos tem custo por chamada; precisa de limite razoável por viagem no plano gratuito para não inviabilizar o produto.
- **Qualidade da extração** — prints de baixa resolução ou PDFs escaneados tortos podem gerar leituras erradas; a revisão humana antes de salvar é obrigatória, não opcional.
- **Uso sem internet** — viajantes frequentemente ficam sem dados móveis; o cronograma e as despesas já lançadas precisam funcionar offline.

## 9. Métricas de sucesso

- ≥70% das viagens com 2+ participantes ativos
- ≥50% dos eventos criados via leitura de arquivo
- ≥80% das despesas quitadas até o fim da viagem
- ≥40% de retenção para a viagem seguinte do mesmo grupo

## 10. Próximos passos

1. Validar a Fase 1 (MVP) com 2–3 grupos reais organizando uma viagem já planejada.
2. Prototipar a tela "hoje na viagem" — é o momento de uso mais frequente do app.
3. Testar a extração de arquivos com uma amostra real de passagens, vouchers e comprovantes.
4. Definir o modelo de monetização (gratuito com limite de viagens ou de extrações por mês, plano pago para grupos e viagens ilimitadas).
