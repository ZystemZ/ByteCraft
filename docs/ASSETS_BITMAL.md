# Assets Bitmal incorporados

O pacote fornecido pelo usuário foi incorporado em `assets/bitmal/` com **29 modelos GLB** e o arquivo `credits.txt` preservado.

Os modelos incluem animais, inimigos, blocos, ferramentas, props, uma cabana, porta, fogueira e outros elementos. Os animais e inimigos listados abaixo já foram substituídos; os demais modelos ficam disponíveis no projeto para as próximas etapas de integração de gameplay.

## Substituições aplicadas

- Animais: `chicken` usa Chicken, `horse` usa Horse, `sheep` usa Sheep e `dog` usa Dog.
- Inimigos: somente o Slime usa Simple Green Slime. O ET e o zumbi continuam usando os modelos FBX originais, com seus rigs e animações preservados.
- O zumbi original usa o retarget/rig de caminhada existente e a base visual é alinhada ao chão para as patas não atravessarem os blocos.
- Os colliders, vida, dano, drops, IA e regras de spawn continuam no código do jogo; os modelos de animais Bitmal são visuais e usam colliders de gameplay existentes.

Os créditos fornecidos aparecem em três locais:

1. `assets/bitmal/credits.txt`, junto dos arquivos originais;
2. a janela nativa **Open Source Licenses / Licenças de código aberto** do jogo;
3. `site/THIRD_PARTY_NOTICES.txt` e `site/open-source-licenses.html` na exportação Web.

As atribuições e links foram preservados conforme entregues no pacote. A lista não foi reinterpretada nem complementada com licenças que não constavam no arquivo original.
