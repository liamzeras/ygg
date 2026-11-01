# Roubo: fontes e processo

> Consultado em 2026-11-01. Nada foi baixado ainda. Regras de reuso: ver o semáforo em
> [README](../README.md).

## Fontes de Ragnarok

| Fonte | Serve para | Limites |
|---|---|---|
| [rAthena](https://github.com/rathena/rathena) | **Extração em massa.** Arquivos YAML de itens, monstros e habilidades, separados em pré-renovação (`db/pre-re/`) e renovação (`db/re/` `[memória, a confirmar]`) | Licença [GPL-3](https://raw.githubusercontent.com/rathena/rathena/master/LICENSE). Pode ser lido e analisado, mas os arquivos não entram no jogo |
| [Divine Pride API](https://divine-pride.net/tools/api-doc) | **Consulta pontual** por ID: monstro, item, habilidade, status | Exige chave. Proíbe espelhar o banco e enumerar IDs em massa, sob risco de revogação. Sem licença de reuso clara |
| [iRO Wiki](https://irowiki.org/) | **Entender mecânica**, com notas e casos especiais | Texto para leitura; reescrever sempre com as nossas palavras. Reflete o iRO atual |

**Consequência prática:** o `dp2rathena`, que converte dados do Divine Pride para o formato rAthena,
não é o caminho para uma extração em massa, porque esbarra nos termos da API.

**Versão:** recomendo a pré-renovação como padrão, por ser a base clássica e mais simples, e a renovação
só para pontos específicos. Isso é uma recomendação, e a decisão é do Liam.

## Processo

```text
1. Sistema base aprovado no Ygg (GDD)
2. Recorte: o que queremos e por quê
3. Baixar a fonte fora do jogo, com aprovação
4. Analisar: categorias, faixas, curvas, padrões
5. Traduzir para as regras do Ygg
6. Amostra de 10 a 20 itens para aprovação do Liam
7. Converter o restante em .tres
8. Teste de fumaça e playtest
```

Regras do processo:

- Os dados brutos ficam fora do projeto ou em uma pasta ignorada pelo git. Só o resultado adaptado
  entra em `assets/data/`.
- Todo lote gera um registro curto: fonte, versão, data e o que mudou.
- Nomes, descrições e visuais são criados do zero para o Ygg.

## Plano para equipamentos

**Pré-requisito:** GDD de equipamentos aprovado. Ainda não existe. A frente dona é `equipamentos`,
hoje em modo só design; os dados finais iriam para `assets/data/items/`.

Campos que o `item_db` do rAthena oferece
([formato](https://raw.githubusercontent.com/rathena/rathena/master/doc/yaml/db/item_db.yml)) e uma
primeira tradução possível:

| Campo no rAthena | O que é | Tradução para o Ygg |
|---|---|---|
| `Type`, `SubType` | Tipo e subtipo de arma | Categoria do equipamento |
| `Locations` | Onde encaixa no corpo | Slots do personagem |
| `Weight` | Peso (10 unidades = 1 de peso) | **Massa real em kg**, afetando carga e física |
| `Attack`, `MagicAttack` | Ataque | Massa e velocidade do golpe, não só um número |
| `Defense` | Defesa | Redução de dano, por material |
| `Range` | Alcance | Alcance físico em metros |
| `Slots` | Encaixes para cartas | Encaixes para reagentes ou runas |
| `Jobs`, `Classes` | Quem pode usar | Restrição por classe, a discutir |
| `EquipLevelMin` | Nível mínimo | Nível ou atributo mínimo |
| `Refineable` | Pode refinar | Sistema futuro de melhoria |
| `Script`, `EquipScript` | Efeito especial | **Parte mais rica e difícil** |

O ponto forte é o campo `Script`. Efeitos como "ao atacar, chance de conjurar" são o tipo de ligação
entre sistemas que procuramos. É um pequeno idioma de programação `[memória, a confirmar]`, então a
extração começa classificando os efeitos por tipo, em vez de converter tudo automaticamente.

**A diferença do Ygg:** em Ragnarok, uma espada pesada é só um número. Aqui ela tem massa, muda o
impulso do golpe e pode ser arremessada. Por isso, valores de ataque do RO só servem para **proporções
e faixas**, nunca como cópia direta.

## Próximas extrações possíveis

- Monstros: tamanho, raça e elemento como matriz de fraquezas.
- Tabelas de drop, para desenhar a economia de reagentes.
- Mapa completo de habilidades que consomem itens: é o caçador de ideias como a Prisão na Teia.
