# 01 — VN Revisada (Crivo Crítico) — Trippin

> Este documento é a **VN passada por um crivo crítico** (ver `00-visao-de-negocio.md` §13): não
> reescreve a visão original, complementa-a. `00` continua sendo o artefato de referência para
> problema/personas/proposta de valor; aqui ficam as lacunas encontradas na revisão e o desenho da
> primeira funcionalidade nova identificada desde então — integração com e-mail.

| Campo | Valor |
|---|---|
| **Produto** | Trippin — planejador de viagens em grupo |
| **Tipo de documento** | VN Revisada (crítica + adendo de escopo) |
| **Deriva de** | `00-visao-de-negocio.md` v1.0 (2026-06-26) |
| **Data desta revisão** | 2026-08-26 |
| **Status** | Rascunho — pendente de decisão do stakeholder de negócio para os itens da seção 4 |

---

## 1. Nota sobre a natureza do `00`

`00-visao-de-negocio.md` se declara **"versão didática"**: ao mesmo tempo uma VN real e um material
de estudo, escrita **como se** o app já estivesse entregue (v1.0.2, com Supabase, GitHub Pages,
app mobile via Expo/WebView, busca de hospedagem já em produção). O repositório do projeto, porém,
não contém código — apenas `briefing.md` e configuração do Claude Code. Ou seja: o "estado
entregue" descrito em `00` é **hipotético/pedagógico**, não um estado real do produto.

Isso não invalida `00` como exercício de VN — mas importa registrar aqui, porque toda recomendação
de escopo/prazo neste documento (`01`) assume que **nada foi construído ainda**, e trata as
"decisões de tecnologia" do `00 §9` como o ponto de partida assumido para quando a construção
começar, não como arquitetura já validada em produção.

---

## 2. Lacunas identificadas na VN original

| # | Lacuna | Por que importa | Recomendação |
|---|---|---|---|
| 2.1 | **Ausência de modelo de negócio.** `00` define problema, personas, proposta de valor e métricas de produto, mas nunca declara como o Trippin gera receita. A única pista é uma nota lateral em `00 §8` sobre receita de afiliados "quando houver chave de parceiro". | Uma Visão de Negócio sem modelo de negócio é uma visão de produto. Isso afeta prioridades reais (ex.: vale investir em preço-ao-vivo de hospedagem se essa for a única fonte de receita futura?). | Adicionar uma seção "Modelo de negócio" à VN — mesmo que a resposta na v1 seja explicitamente "nenhum, foco em validar uso; monetização é pergunta em aberto". |
| 2.2 | **North Star sem definição operacional.** "Viagens organizadas e **concluídas** por usuário ativo" — não há definição de quando uma viagem conta como concluída (data final atingida? organizador marca como encerrada? nenhuma ação = nunca conta?). | Uma métrica que não pode ser instrumentada hoje não é uma métrica, é uma intenção. Isso trava a seção 06 (rollout + métricas), que depende de instrumentação real. | Definir a regra de fechamento antes do rollout (sugestão: viagem é "concluída" automaticamente N dias após a data final, editável pelo organizador). |
| 2.3 | **Motor de crescimento não declarado como premissa.** As metas de 30 dias (1.000 MAU, 300 viagens, 35% de conversão de convite) dependem inteiramente de virilidade por convite — não há canal de aquisição, orçamento de marketing ou data de GA mencionados. | Meta sem mecanismo de aquisição por trás é aspiração, não plano. Se a premissa "aquisição é 100% orgânica via convite" for falsa, as metas de 30 dias são inatingíveis por motivo alheio ao produto. | Adicionar à `00 §10` (Premissas) a frase explícita: "assumimos aquisição orgânica via convite de organizador, sem orçamento de marketing pago." Se isso não for verdade, a meta de MAU precisa ser recalibrada. |
| 2.4 | **O "diferencial defensável" é mais frágil do que a redação sugere.** `00 §5` chama a inteligência de documentos de "difícil de copiar", mas `00 §9` decisão #7 escolhe deliberadamente um **parser estruturado por padrões conhecidos**, sem LLM, exatamente para evitar custo de infra de IA na v1. Um parser de padrões conhecidos é replicável por qualquer concorrente com um fim de semana e um regex. | Isso não invalida a decisão técnica (que é correta para v1) — mas a VN não pode alegar um fosso que a própria arquitetura da v1 não sustenta. Superestimar o fosso leva a subinvestir em outras formas de retenção (rede social do grupo, dados acumulados, hábito). | Reformular `00 §5` para: "a inteligência de documentos é o maior gerador de valor da v1; torna-se defensável quando evoluir para extração via LLM (fora do escopo v1) — até lá, a vantagem competitiva real é a velocidade de execução, não a técnica em si." |
| 2.5 | **Risco de manutenibilidade do frontend não capturado.** `00 §9` decisão #1 (arquivo único HTML/React via CDN, sem bundler) já reconhece risco de "tela branca" por erro de sintaxe — mas esse risco não aparece na tabela de riscos da `00 §10`, e a superfície de código só cresce a cada novo pilar (docs, hospedagem, e agora e-mail). | Um risco técnico conhecido e não rastreado na tabela formal de riscos tende a ser esquecido até virar incidente. | Adicionar linha à `00 §10`: "Manutenibilidade do frontend em arquivo único, à medida que features se acumulam — Médio — mitigado por `validate-code.js` + Playwright (decisão #10), reavaliar migração para bundler se o arquivo ultrapassar um limiar de tamanho." |
| 2.6 | **Privacidade de documentos sensíveis incompleta.** `00 §10` cobre CPF e localização (LGPD), mas não cobre os dados sensíveis já implícitos em "ler os documentos anexados" — números de passaporte, cartões de embarque, dados financeiros nas despesas. Não há política de retenção/exclusão declarada em lugar nenhum. | Documentos de viagem são dado sensível por natureza (identidade, financeiro). Ausência de política de retenção é lacuna de compliance, não só de produto — e fica mais grave com a integração de e-mail (seção 3). | Adicionar premissa de retenção à `00 §10`: por quanto tempo o conteúdo extraído de documentos fica armazenado, e como o usuário solicita exclusão. |
| 2.7 | **Nenhum concorrente direto mencionado.** `00 §3` lista apenas concorrentes indiretos (e-mail, Booking, Splitwise, WhatsApp, Maps). Apps de planejamento de viagem existem (TripIt, Wanderlog, etc.) e um stakeholder vai perguntar "por que não usar X?". | Não é um problema de escopo, mas de preparo para defesa da visão. | Adicionar 2-3 linhas em `00 §3` reconhecendo concorrentes diretos e por que a aposta em "inteligência de documentos + offline" ainda diferencia o Trippin deles. |

---

## 3. Nova capacidade: Integração com e-mail (Gmail e Outlook)

Capacidade não presente em `00`, identificada nesta revisão. Decisões abaixo confirmadas com o
stakeholder de produto em 2026-08-26.

### 3.1 Impacto na proposta de valor

Hoje (`00 §5`) o pilar "inteligência de documentos" cobre apenas anexos que o usuário sobe
manualmente. A integração de e-mail estende esse pilar para **localizar** — não ler tudo, apenas
localizar — reservas e confirmações que já estão na caixa de entrada do usuário, reduzindo o
trabalho de "baixar o PDF e depois subir no app" para "apontar a pasta e confirmar".

Isso é uma extensão do mesmo diferencial (`00 §5`), não um novo pilar — deve ser tratado como tal
no roadmap e na comunicação, para não diluir a proposta de valor central em uma segunda promessa.

### 3.2 Escopo decidido

| Decisão | Escolha | Alternativa descartada | Por quê |
|---|---|---|---|
| **Momento** | v2 (roadmap), não MVP v1 | Incluir na v1 | O upload manual já é o must-have validado da v1 (`00 §7` item 6). A verificação de escopo restrito do Gmail (Google exige avaliação de segurança para apps que leem e-mail — processo de semanas, não dias) e o registro de app no Microsoft Graph (Outlook) são dependências de compliance que não devem travar o lançamento do MVP. |
| **Escopo de busca** | Usuário aponta uma **pasta/rótulo específico** (ex.: rótulo Gmail "Viagens" ou pasta Outlook dedicada) | Busca por palavra-chave/remetente em toda a caixa de entrada | Escopo de leitura muito menor (idealmente `gmail.readonly` restrito a um rótulo, ou `Mail.Read` do Graph restrito a uma pasta) — reduz superfície de dados sensíveis acessada, facilita a revisão de privacidade do Google/Microsoft, e é mais fácil de explicar ao usuário ("o app só olha o que você separou") do que "o app varre tudo". |
| **Gatilho** | **Sob demanda** — usuário toca em algo como "buscar no e-mail" ao montar a viagem | Sincronização automática em segundo plano | Sem infra de armazenamento de token persistente + jobs de background na v1 deste recurso; consentimento fica mais simples de justificar ("acesso pontual, quando você pede") do que acesso contínuo. |

### 3.3 Nova entrada na tabela de decisões de tecnologia (formato `00 §9`)

| # | Decisão | Alternativas consideradas | Por que escolhemos | Trade-off aceito |
|---|---|---|---|---|
| 12 | **Integração de e-mail via OAuth (Gmail API + Microsoft Graph), leitura restrita a pasta/rótulo indicado pelo usuário, disparada sob demanda** | Sincronização automática em background; acesso de caixa de entrada inteira; apenas upload manual (sem integração) | Menor escopo de OAuth possível reduz revisão de segurança e risco de privacidade; "sob demanda" evita infra de sync persistente na primeira versão do recurso | Usuário precisa organizar um rótulo/pasta manualmente antes de usar; sem esse passo, a busca não encontra nada — pior recall que uma busca ampla |

### 3.4 Novos riscos (formato `00 §10`)

| Risco | Impacto | Mitigação proposta |
|---|---|---|
| Verificação de escopo restrito do Gmail (Google) tem prazo incerto e pode exigir avaliação de segurança (CASA) | Alto — pode atrasar o v2 inteiro se subestimado | Iniciar o processo de verificação com Google assim que o escopo técnico for definido, independente da data de código pronto |
| Registro/aprovação de app no Microsoft Entra/Graph para `Mail.Read` | Médio | Registrar o app cedo; usar permissão delegada restrita a pasta, não `Mail.ReadWrite` nem acesso a toda a organização |
| Dado sensível de terceiros dentro dos e-mails do usuário (ex.: e-mail de confirmação com dados de outro passageiro) | Alto | Extrair apenas os campos necessários (datas, local, código de reserva) e descartar o corpo do e-mail após a extração; não armazenar o e-mail bruto |
| Revogação de acesso pelo usuário não propagando corretamente (token continua válido após o usuário revogar no provedor) | Médio | Verificar validade do token a cada uso sob demanda (natural, já que não há sync em background) |
| Custo/quota das APIs (Gmail API e Microsoft Graph têm limites de chamadas) | Baixo na v2 (uso sob demanda, baixo volume) | Monitorar quota; reavaliar se o recurso evoluir para sincronização automática |

### 3.5 Retenção e privacidade (ligado à lacuna 2.6)

Como a leitura de e-mail é estritamente mais sensível que o upload manual de um PDF (o usuário nem
sempre pensa em "quem mais aparece nesse e-mail"), a política de retenção da lacuna 2.6 passa a ser
**bloqueante** para este recurso, não apenas recomendada: definir, antes de escrever qualquer
código de integração, por quanto tempo o conteúdo extraído fica armazenado e como o usuário revoga
o acesso e solicita exclusão.

---

## 4. Novas perguntas em aberto (continuação de `00 §12`)

4. **Qual é o modelo de negócio do Trippin?** *Sem recomendação própria — decisão de negócio que
   precede a priorização de itens como preço-ao-vivo de hospedagem (`00 §8`). Dono: stakeholder de
   negócio.*
5. **Qual é o motor de aquisição assumido para as metas de 30 dias?** *Sugestão: declarar
   explicitamente "orgânico via convite, sem budget pago" como premissa (`00 §10`) até que isso
   mude.*
6. **A integração de e-mail deve, no futuro, oferecer sincronização automática (não só sob
   demanda)?** *Sugestão: não decidir agora — reavaliar após medir a taxa de uso e a taxa de sucesso
   do modo sob demanda na v2, exatamente como `00 §12` item 2 trata OCR/LLM.*

---

## 5. Próximos passos

1. Stakeholder de negócio decide as lacunas 2.1–2.3 (modelo de negócio, definição de North Star,
   premissa de aquisição) — sem essas respostas, `06-rollout-plan` não tem números confiáveis para
   medir contra.
2. Engenharia estima o prazo real de verificação de escopo restrito do Gmail antes de comprometer
   uma data de v2 para a integração de e-mail.
3. `00-visao-de-negocio.md` recebe apenas edições factuais pontuais conforme essas decisões forem
   tomadas (já feito: linha de roadmap em `00 §8` apontando para este documento); o racional
   completo continua vivendo aqui, para não inflar `00` como o próprio documento adverte em seu §1.
