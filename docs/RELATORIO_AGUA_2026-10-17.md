# ByteCrafter — água estilo Minecraft

Foi adicionada uma camada de água procedural ao mundo voxel.

## Implementação

A água usa o bloco interno `14` e aparece em áreas cuja altura do terreno fica abaixo do nível do mar configurado em `WATER_LEVEL = 7`. Isso cria lagos e áreas alagadas sem alterar os blocos sólidos existentes.

A geometria transparente é construída em um `WaterMesh` separado da malha sólida de cada chunk. A água não recebe `ChunkCollision` próprio, portanto o jogador continua colidindo com o terreno abaixo, mas a superfície da água não funciona como uma parede invisível.

O material usa um shader espacial com transparência azul, variação de cor, brilho especular discreto e deslocamento vertical sutil nas bordas/superfície para simular ondas. A superfície fica ligeiramente abaixo do topo do bloco, como no visual de água do Minecraft.

A água não é minerável e não gera drops. Overrides com ID 14 também são aceitos pelo salvamento e pelo carregamento do mundo.

## Validação

- Suíte principal: **`[bytecrafter-tests] PASS: 196 checks`**.
- Smoke test de água: encontrou água procedural, confirmou `WaterMesh` com superfície e confirmou que não existe collider dentro do `WaterMesh`.
- O importador do Godot 4.7.2 não apresentou erro de script; os avisos restantes são os avisos conhecidos dos FBX ativos.

## Escopo atual

Esta etapa implementa a aparência, a presença procedural e a separação física da água. O fluxo dinâmico por gravidade, fontes de água colocáveis, natação e propagação célula a célula ficam como uma etapa posterior, caso sejam desejados.
