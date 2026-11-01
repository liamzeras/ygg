# Ideias para o Ygg

> Propostas do Sábio, nenhuma aprovada ou implementada. Dependem de sistemas que ainda estão fora
> do escopo (inimigos, inventário) quando indicado. Status: 💡 proposta · ✅ aprovada · ❌ descartada.

## 1. Teia como material 💡

**Origem:** Prisão na Teia. **Pilares:** Criatividade, Crível.

A teia deixa de ser um número e vira um `PropMaterial` novo: muito inflamável, pouca massa, gruda.

- Uma habilidade gasta 1 Teia para lançá-la. Ela prende o alvo enquanto aguentar a força dele.
- **Fogo não dá "x2" arbitrário.** A teia queima de uma vez, causa uma explosão de calor no preso e
  o solta. O bônus de dano nasce do sistema de calor que já existe.
- A teia prende props também: amarrar um barril à parede, travar uma porta, colar uma caixa no alvo
  antes de acender.
- Se o inimigo for forte, arrebenta. Se for pesado, arrasta a âncora junto.

**Como testar:** prender o boneco, acertar uma Bola de Fogo e comparar o dano com o do boneco sem
teia. O Liam define a diferença que deve ser perceptível.

**Depende de:** sistema de estados no alvo; inventário simples para o custo em item.

## 2. Tabela oficial de elementos × materiais 💡

**Origem:** Breath of the Wild, regras 1 a 3. **Pilar:** Legibilidade.

Escrever em um GDD quais elementos mudam quais materiais e quais se anulam, e mantê-la como a única
fonte de verdade. Inclui decidir conflitos que a pesquisa revelou:

- Ragnarok usa lama + barreira de fogo como combo. No Ygg, **a lama apaga o fogo**. Sugestão: manter
  a nossa regra, que é mais crível, e usar outra combinação de lentidão, como o Campo Lento.

**Custo:** baixo, é documento. É a melhor próxima peça porque organiza todas as outras.

**Rascunho:** [tabela-elementos-materiais.md](tabela-elementos-materiais.md).

## 3. Estados que mudam o material 💡

**Origem:** Congelado e Petrificado. **Pilares:** Criatividade, Quanto mais surreal, mais limitado.

| Estado | Como surge | O que muda |
|---|---|---|
| Molhado | Água, chuva | Demora a aquecer; passa a conduzir |
| Enlameado | Lamaçal | Apaga o fogo; pesa mais; anda devagar |
| Coberto de óleo | Barril de óleo | Inflamável, mesmo em metal ou pedra |
| Congelado | Gelo intenso | Frágil a impactos; chão escorrega |

Respeita a nota do GDD: gelo deixa o chão escorregadio, não congela coisas no ar. O campo `conductive`
reservado em materiais já prepara o "molhado conduz".

## 4. Drops como ingredientes 💡

**Origem:** o padrão geral de reagentes de Ragnarok. **Pilar:** Criatividade.

Regra de ouro: **todo drop comum tem pelo menos um uso criativo**. Glândula de veneno envenena uma
poça, gordura vira óleo, carapaça vira escudo improvisado. Isso dá economia à caça e evita lixo no
inventário.

**Depende de:** inimigos e inventário.

## 5. Terra Morta: a contramedida 💡

**Origem:** Terra Magnética. **Pilar:** Quanto mais surreal, mais limitado.

Uma área onde a magia não se sustenta. Regra simples: **magia some, objeto continua**. Armadilhas,
caixas e barris funcionam. Isso valoriza quem joga com física e cria arenas e chefes que mudam a
forma de jogar. Evita a lista de exceções de Ragnarok.

## 6. Autoria do dano 💡

**Origem:** Invocar Flora. **Pilar:** Criatividade.

Se eu chutar o barril e ele explodir, o dano e a culpa são meus. Os inimigos reagem a mim, e efeitos
"ao causar dano" são ativados. Sem isso, jogar com o ambiente é punido na hora de ganhar XP.

**Decisão de design:** até que ponto a autoria se mantém numa reação em cadeia? Sugestão: o último
jogador a influenciar o objeto.

## 7. Inimigos que usam o sistema 💡

**Origem:** Divinity: Original Sin 2. **Pilar:** Legibilidade.

Goblins que acendem barris e fogem, aranhas que fazem teias em corredores. O inimigo **ensina a
mecânica antes** de o jogador ter a habilidade.

**Depende de:** IA.
