# Refinos de desempenho, animação e loot — 23/10/2026

- **Travadas:** o retarget de esqueleto deixa de recalcular todos os ossos em cada frame quando o clip está parado; continua atualizando durante animações ativas e aplica novamente quando o estado muda. É uma otimização de código, sem benchmark de FPS comparativo.
- **NPC comerciante:** a ação de trabalho troca o clip “Martelo 2” por “Standing Melee Attack Downward”, evitando o movimento de chute alto.
- **Ferramentas:** picaretas, pás, machado e espadas passam a usar escala visual `0,25` da anterior (redução de 4×) nas vistas em primeira e terceira pessoa.
- **Subida de bloco:** quando `move_with_step` confirma o step-up, a locomoção do jogador usa a animação de salto por `0,32 s`, para tornar a elevação perceptível.
- **Shuriken:** item passa a usar a chave textual `shuriken`, evitando conflito com o bloco de ID `27`; ET e Atirador Lunar o dropam. Continua arremessável pelo ataque com o item selecionado, consome uma unidade e causa dano ao atingir inimigos. Saves antigos convertem contagem, slots e drops do ID `27` para o item novo.
- **Modelos de drop:** IDs `10` (fragmento lunar) e `11` (núcleo lunar) usam cristais; o modelo de shuriken fica associado apenas ao item `shuriken`.

## Validação

Importação headless do Godot sem erros e suíte aprovada em **305 verificações**. Nenhum benchmark gráfico foi executado; recomenda-se conferir em jogo a sensação do step-up e as escalas no campo de visão da câmera.
