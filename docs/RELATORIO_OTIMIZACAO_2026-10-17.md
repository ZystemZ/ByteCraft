# ByteCrafter — limpeza, otimização e revisão de código

**Data:** 17/10/2026  
**Engine verificada:** Godot 4.7.2

## Resultado de tamanho

A cópia recebida tinha aproximadamente **563 MB**, dos quais cerca de **331 MB eram `.godot/`**, cache gerado pelo editor, e cerca de **230 MB estavam em `assets/`**.

Nesta entrega:

- o cache `.godot/` foi removido; ele será recriado automaticamente ao abrir o projeto;
- o projeto fonte ficou com aproximadamente **75 MB**;
- `assets/` ficou com aproximadamente **72 MB**;
- não restaram sidecars `.import` apontando para arquivos removidos.

## Assets removidos

Foram removidos apenas recursos sem referência no jogo ativo ou variantes duplicadas:

- família `bichopapao` completa;
- aldeões `aldea` e `aldeao` completos, que ainda não são instanciados;
- `assets/models/player/model.glb` e `model_0.png`;
- variantes `ETE_RIGGED`, `ZUMBIRIGGED`, `PLAYER_BOY2_RIGGED` e `PLAYER_GIRL2_RIGGED`;
- texturas `model_Glow` não usadas pelos rigs ativos;
- imagens `_0.png` extraídas/duplicadas sem referência de runtime;
- `cobblestone.png`, `oak_log_top.png`, `assets/textures/enemies/slime.png` e o sidecar do backup antigo do atlas.

Os modelos efetivamente referenciados pelo código foram preservados: os dois avatares originais, `boy2`, `girl2`, slime 3D, ET e zumbi, além das animações e texturas ativas.

## Otimização dos modelos e texturas

As sete texturas de aparência usadas por personagens/inimigos foram reduzidas de **2048×2048 para 1024×1024**, mantendo PNG, nomes e referências do código. Isso reduz memória e tamanho do pacote sem alterar rigs, animações ou caminhos `res://`.

Os FBX ativos mantêm as opções de importação já configuradas pelo projeto, incluindo geração de LOD e compressão permitida. Não foi aplicada decimação geométrica destrutiva nos rigs, porque ela pode quebrar pesos, ossos e retargeting; a redução aplicada é a alternativa segura para este protótipo.

## Melhorias de código

- Plantações não recriam o `MeshInstance3D` a cada frame: o visual só é reconstruído quando o estágio muda.
- Plantações salvas agora são restauradas ao carregar o mundo/perfil.
- O agendamento de ET/boss não é recalculado em todos os frames; passou a ser verificado a cada 0,5 s.
- O retargeting de avatares CC passou a memorizar os pares de índices de ossos, evitando buscas por nome repetidas a cada frame.
- Colliders de tronco passaram a ter nomes únicos (`TreeTrunkCollision_N`), evitando renomeação automática pelo Godot e mantendo a contagem/inspeção confiável.
- O HUD de XP é atualizado também quando há ganho de XP sem mudança de nível.

## Validação

- Referências `res://` do código/cenas verificadas após a limpeza: **0 referências quebradas**.
- Importação limpa no Godot 4.7.2 concluída sem erros de script ou importação. Permanecem apenas os avisos conhecidos do importador FBX (`Non-node element connected to root`).
- Suíte automatizada executada: **`[bytecrafter-tests] PASS: 196 checks`**.

A ausência de `.godot/` é intencional: o primeiro carregamento no editor fará a reimportação dos assets ativos.
