# Relatório de correções — 17/10/2026

## Correções aplicadas

- Corrigido erro de compilação em `scripts/game/bytecrafter_enemy.gd`: inimigos agora consultam com segurança a intensidade da luz solar no nó do jogo, com valor padrão seguro quando o método não estiver disponível.
- Corrigido erro de execução em `scripts/game/bytecrafter.gd`: a hotbar guarda IDs em formatos mistos; a detecção da shuriken agora compara o ID sem tentar comparar `String` e `int` diretamente.
- Corrigida a troca de avatar em `scripts/game/bytecrafter_player.gd`: ferramentas já anexadas são reparentadas, e itens ainda sem pai são adicionados corretamente. Isso elimina os erros de `add_child`/`reparent` ao alternar avatar.

## Verificações executadas

- Importação do projeto com Godot 4.7.2 em modo headless: concluída sem erro de parse/compilação.
- Suíte automatizada: 199 verificações executadas; 193 passaram e 6 falharam.

## Pendências detectadas pela suíte

As falhas remanescentes estão ligadas a: animação de pernas dos avatares `boy2` e `girl2`; apresentação de ícones/nome selecionado na hotbar; renderização da picareta em primeira e terceira pessoa; e persistência do recurso de slime. Também foram observados avisos do esqueleto sobre índice de osso inválido durante o teste dos avatares. Esses pontos não foram alterados sem diagnóstico suficiente para evitar mudanças especulativas em animações/assets e salvamentos.

`npm run check` não pôde ser usado porque depende do runtime de Game externo (`GAME_RUNTIME`), ausente neste ambiente. A importação e a suíte foram executadas diretamente com o Godot instalado.

## Ajuste de escala solicitado

- Definida altura de referência do personagem de 1,8 m e limite rígido de 3× (5,4 m) para a escala visual de qualquer inimigo, inclusive slime, slimes especiais e chefe. Os fatores de escala dos modelos são limitados pelo tamanho medido da malha antes de aplicar o fator final.
