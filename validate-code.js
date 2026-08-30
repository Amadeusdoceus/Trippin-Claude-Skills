#!/usr/bin/env node
// H15.3 / decisão de tecnologia #10 (00-F §10) — primeira metade da suíte de
// qualidade rodada por `npm run review` antes de qualquer push. O app é um
// único arquivo HTML sem build (decisão #1): o maior risco é um erro de
// sintaxe (chave/parêntese desbalanceado) só ser descoberto em produção,
// como "tela branca". Este script extrai o JSX embutido em
// web/index.html e tenta transpilá-lo com o mesmo Babel que o navegador usa
// em tempo de execução — se falhar aqui, falharia do mesmo jeito no
// navegador de um usuário real.
const fs = require('fs');
const path = require('path');
const babel = require('@babel/core');

const INDEX_PATH = path.join(__dirname, 'web', 'index.html');

function fail(message) {
  console.error(`\n✗ validate-code.js: ${message}\n`);
  process.exit(1);
}

if (!fs.existsSync(INDEX_PATH)) {
  fail(`arquivo não encontrado: ${INDEX_PATH}`);
}

const html = fs.readFileSync(INDEX_PATH, 'utf8');

const sourceMatch = html.match(/<script type="text\/plain" id="app-source">([\s\S]*?)<\/script>/);
if (!sourceMatch) {
  fail('não encontrei o bloco <script type="text/plain" id="app-source"> em web/index.html — o app não vai montar.');
}
const jsxSource = sourceMatch[1];

try {
  babel.transformSync(jsxSource, {
    presets: [require.resolve('@babel/preset-react')],
    filename: 'app-source.jsx',
  });
} catch (error) {
  fail(`o JSX de web/index.html não compila — isso viraria uma tela branca em produção.\n\n${error.message}`);
}

// Checagem adicional, além do que o Babel já garante: o script de bootstrap
// que transpila app-source e injeta o resultado precisa existir — sem ele, o
// JSX válido nunca chega a rodar (mesmo risco de "tela branca", só que por
// um motivo diferente de erro de sintaxe). Não faz sentido contar
// abertura/fechamento de <script> no HTML inteiro: o próprio código-fonte
// menciona a string "<script" dentro de comentários (ver linha sobre o CDN
// do Babel), o que gera falso positivo sem checar contexto de string/comentário.
if (!html.includes('Babel.transform(') || !html.includes('id="app-source"')) {
  fail('não encontrei o bootstrap que transpila app-source via Babel.transform e injeta o resultado — o JSX válido nunca chegaria a rodar.');
}

console.log('✓ validate-code.js: web/index.html compila sem erro de sintaxe.');
