# ByteCrafter — handoff de estruturas quebráveis

## Pedido e escopo

Pedido do utilizador (22/10/2026): “as casas, e outras estruturas (ate itens como cama) devem ser quebraveis (com drop do proprio item quebrado (1:1)); as construções devem ser feitas com blocos de construção do mundo (casas blocos de tabos, ou de pedras, ou de tijolos, ou de madeira bruta, com telhado de taboas ou madeira bruta)”. Preservar o projeto Godot existente; não criar outro jogo. Manter as alterações enxutas por pedido explícito do utilizador.

## Fontes consultadas e como foram usadas

- `/home/ubuntu/skills/webdev/references/game-workflow.md`, linhas 7 e 92–95: “Keep game logic, code changes, integration and gameplay verification in the main agent to preserve shared context.”; “Extend the initialized project and keep its working simulation, controls, saves and delivery.” Aplicado mantendo a lógica no projeto ByteCrafter original e evitando reinitialização.
- `/home/ubuntu/skills/webdev/references/game-runtime.md`, linhas 56–58: “Destroyed rubble and fragments render below actors in effective world z while keeping footprint, collision release and reward position; reset restores the intact state.” Cautela: a implementação atual remove o prop e cria o drop 1:1, mas ainda não cria detritos visuais temporários; não afirmar que esse polimento foi implementado.
- `/home/ubuntu/skills/webdev/references/game-delivery.md`, linhas 104–117: “Reuse finite checks for changed gameplay/input/audio/saves/localization/tuning through existing entry points.”; “No tests if evidence suffices; otherwise only requested or minimal bounded checks for critical required behavior...” Aplicado acrescentando verificações limitadas à suíte existente, sem criar framework paralelo.
- `/home/ubuntu/skills/webdev/references/game-multiplayer.md`, linhas 82–90: “The server owns rooms, seats, simulation, legal actions, scores and round transitions. Clients send bounded input and treat accepted snapshots as authority...” Usado como cautela para a quebra em LAN: o servidor valida distância e publica a remoção/drop; validação real com dois clientes ainda está pendente.
- MCP consultado anteriormente: `webdev-mcp.webdev.init_project`, recurso `manus-resource://manus-webdev/project/wdp_c95f7f0640872dc93facf26b`, projeto separado “ByteCrafter Web”, diretório `/home/ubuntu/byteweb`. Excerto retornado: “Workspace starts empty: no framework, template, package manifest, dependencies, or dev server are installed.” Este é apenas o host Web autorizado anteriormente; não é a pasta-fonte modificada nesta tarefa e não foi usado para alterar a jogabilidade.
- Não houve pesquisa web/fetch nesta etapa. ZIP fornecido anteriormente, `/home/ubuntu/upload/ZystemWorkSpace-OPEN.zip`, não foi alterado nem necessário para esta mudança.

## Alterações no código

- `scripts/game/bytecrafter_village_system.gd`: casas/mercado usam bloco voxel do mundo; estado de props de vila destruídos persiste; destruir a cama desativa a cama atribuída ao aldeão.
- `scripts/game/voxel_world.gd`: cache de voxels de estruturas e overrides; corrigida indentação que impedia a compilação.
- `scripts/game/bytecrafter_prop.gd` e `scripts/game/bytecrafter_villager.gd`: props integram grupo de interação; cama opcional; corrigida indentação.
- `scripts/game/bytecrafter.gd`: mineração encontra props e voxels; quebra de prop dá um drop do mesmo ID; remoção sincronizada por RPC autoritativo e salva via ausência do prop/registro de vila; drops textuais são aceitos, serializados, restaurados e coletados no inventário.
- `scripts/game/bytecrafter_drop.gd`: `item_id` textual pode ser mostrado como drop coletável.
- `test/test_suite.gd`: verificações para materiais de construção, drop 1:1 de voxel, cama, aldeão, persistência e coleta.

## Estado de validação

- Godot 4.7.2 headless. Import do projeto principal passou depois de corrigir os erros de indentação herdados.
- A última execução da suíte chegou a `PASS: 261 checks`, mas **não é validação limpa**: houve erro runtime no teste por comparação `int`/`String` ao procurar o drop da cama. A checagem foi ajustada para comparar `str(item_id)`; também foi normalizada comparação similar na persistência. Reexecutar a suíte e exigir ausência de `SCRIPT ERROR` e linha PASS completa antes de empacotar.
- A execução anterior terminou com exit code 0 apesar do erro runtime; não tratá-la como teste aprovado.
- A suíte pode reportar temporariamente menos que os 272 checks herdados porque o erro encerrou o restante de `_test_playable_loop`; conferir o número real após a nova execução.

## Próximos passos

1. Reexecutar `GODOT_SILENCE_ROOT_WARNING=1 godot --headless --path . res://test/test_suite.tscn`; inspecionar todo o log. Corrigir só falhas confirmadas e repetir após a correção.
2. Se estiver limpo, gerar ZIP atualizado do projeto Godot com shaders/documentação/assets existentes; validar integridade (`unzip -t`) e presença de `project.godot`, scripts e assets. Não substituir nem misturar o projeto host `/home/ubuntu/byteweb`.
3. Entregar ao utilizador link do ZIP atualizado, resumo curto e este handoff. Declarar que LAN não foi testada com dois clientes; não dizer que o artefato está validado até os testes limpos.
