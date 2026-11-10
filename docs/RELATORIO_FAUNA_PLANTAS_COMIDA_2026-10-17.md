# Fauna, cultivos e comida — 17/10/2026

- Bosses são os inimigos gigantes: o Chefe Lunar agora usa altura-alvo de 4,8 m (cerca de 2,7× o personagem) e continua sujeito ao teto visual absoluto de 5,4 m. Slime comum e demais inimigos não-boss mantêm dimensões normais.
- Cada animal recebe variação de escala de 80% a 120% em relação ao tamanho-base de sua espécie. Colisor, modelo e plaqueta acompanham a escala. A quantidade de cada drop é ajustada proporcionalmente com arredondamento aleatório, podendo render menos aos menores e mais aos maiores.
- Drops animais ajustados: galinha solta carne e ovo; cavalo, carne e couro; ovelha, lã e carne; cão, carne e banha. Modelos de carne, ovo e frutas usam assets compatíveis; legumes não são mais exibidos como se fossem banha.
- Cada mundo novo recebe pequenos canteiros de trigo, cenouras, tomates e frutas usando modelos existentes. As plantas estão maduras e podem ser colhidas com **P**; a colheita atualiza inventário e XP, e a ausência de plantas selvagens colhidas é gravada para não reaparecer ao continuar o mesmo mundo.
- Pressionar **P** consome o alimento selecionado; frutas, trigo, carne, banha, cenoura, gelatina, carne cozida e ovos têm valores de fome. Ao mirar uma planta, P prioriza a colheita em vez de comer o item selecionado.
- Itens de ovo foram adicionados ao inventário e ao save; fruta e carne usam modelos corretos de pickup.

## Correção de escala e desempenho — 17/10/2026

O modelo de cada pickup agora tem seu AABB medido e é normalizado para uma dimensão máxima de 0,30 m; o ovo não depende mais das unidades de escala inconsistentes do arquivo GLB. A escala do ET e do atirador foi igualada à escala configurada para o zumbi normal. O boss lunar continua sendo a única exceção de tamanho.

O agendador foi refeito: removi o spawn de dentro do loop que enumerava os inimigos e adicionei um limite central rígido de **cinco inimigos ativos**. Em noites lunares o boss usa uma vaga reservada; o atirador não é adicionado junto dele, e na transição para boss night um inimigo comum é removido se necessário.

## Validação

A importação headless do Godot 4.7.2 concluiu sem erros de compilação. A suíte registrou **206/211 verificações aprovadas**. As cinco falhas restantes são as mesmas anteriores: animação das pernas de `boy2`/`girl2`, ícones/nome na hotbar e visualização da picareta em primeira/terceira pessoa. Os testes novos confirmaram que o pickup do ovo fica abaixo de um terço de bloco, ET e zumbi compartilham a escala configurada e o limite de cinco inimigos é respeitado. Os avisos de índice de osso inválido estão associados aos testes antigos de animação.
