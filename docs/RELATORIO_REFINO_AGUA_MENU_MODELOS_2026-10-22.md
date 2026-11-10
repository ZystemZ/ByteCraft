# ByteCrafter — refinamento de água, menus e modelos

**Data:** 22/10/2026  
**Engine:** Godot 4.7.2

## Movimento na água

- O movimento compartilhado dos atores agora tenta subir um degrau de um bloco quando o ator ainda está na água, mesmo que `CharacterBody3D.is_on_floor()` ainda não tenha reconhecido o piso da margem.
- A subida continua condicionada à verificação de colisão livre acima e à confirmação de uma superfície caminhável do outro lado; não permite atravessar paredes nem terreno.
- A mudança usa o utilitário comum `ByteCrafterMovement`, usado pelo jogador, monstros, criaturas e aldeões. Assim, a mesma regra de saída beneficia esses grupos sem duplicar lógica física.
- O comportamento existente de flutuação/natação permanece preservado, incluindo a impulsão para cima do jogador ao manter o comando de pulo e o movimento aquático próprio dos peixes.

## Interface e custo de renderização

- A inspeção do menu ativo em `scripts/game/bytecrafter.gd` confirmou um painel glass/holográfico sobre a arte de fundo, hierarquia clara para continuar/criar mundo, e destaque e marca de seleção para o avatar ativo. A direção visual existente é coerente com o tema e foi preservada; não alterei o menu de outra cena/protótipo que não é usado pelo ByteCrafter.
- Não encontrei gargalo evidente de redesenho contínuo no menu principal ativo. Recomenda-se decidir mudanças visuais adicionais a partir de uma captura no dispositivo/resolução-alvo, para evitar redesenhar sem referência de legibilidade.

## Modelos 3D e otimização

- Os arquivos de importação dos rigs ativos do jogador e do slime já ativam geração de LOD, malhas de sombra e compressão permitida. Os assets foram mantidos inalterados nesta etapa.
- Não foi aplicada decimação geométrica nos rigs: a alteração pode comprometer pesos, ossos, retargeting e animações. O histórico de otimização segura de texturas e limpeza de assets permanece em `docs/RELATORIO_OTIMIZACAO_2026-10-17.md`.
- Não foi feita medição comparativa de FPS ou memória em hardware-alvo; portanto, não se atribui ganho quantitativo de desempenho.

## Validação

- Importação/abertura headless do projeto Godot concluída.
- Suíte `res://test/test_suite.tscn`: **PASS — 285 verificações**, incluindo o teste que exige step-up de um bloco na situação de saída da água.
