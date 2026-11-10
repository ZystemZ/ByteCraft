# Streaming de chunks e autosave sem bloqueio

## Chunks

O streaming mantém **um worker por mundo**. A thread principal prepara um snapshot compacto dos voxels usando os caches e overrides vivos; somente esse `PackedByteArray` imutável e coordenadas/versões são enviados ao worker. O worker calcula buffers planos de vértices, normais, cores, UVs e células de troncos/plantas. Ele não acessa SceneTree, física, nós, recursos mutáveis ou os caches do mundo.

Quando o cálculo termina, o fio principal recolhe o resultado, confere a versão do mundo e a época do streaming, cria `ArrayMesh`, colisões e nós e só então instala o chunk. Resultado antigo é descartado e reenfileirado quando ainda está na área ativa. Há no máximo um cálculo em andamento. O chunk central e reconstruções causadas por edição continuam síncronos para preservar suporte imediato ao jogador e a consistência das bordas. Isso reduz o maior loop CPU da malha, mas criação de snapshot, criação da malha/colisão e instalação ainda podem causar trabalho no fio principal.

Ao destruir o mundo, a thread é juntada antes do objeto deixar de existir. Se não for possível iniciar a thread, o chunk usa o construtor síncrono existente como fallback. As APIs de meshes, colisão e SceneTree continuam exclusivamente no fio principal.

## Autosave

O mapa mantém overrides agrupados por chunk em `PackedInt32Array` imutáveis. Quando um bloco muda, somente o buffer daquele chunk é substituído. Criar um snapshot custa uma cópia rasa do dicionário de buffers; o worker expande os tuplos e escreve o JSON sem montar uma lista gigante de arrays no fio principal. O perfil novo também é entregue por cópia rasa do dicionário de topo, pois suas listas são construídas novamente em cada pedido. O gravador executa serialização, gravação temporária, flush e substituição com backup numa única thread dedicada. Os pedidos são serializados; se novos saves forem solicitados durante uma gravação, apenas o snapshot mais recente aguarda na fila. Isso evita acessos simultâneos aos mesmos arquivos e uma fila de saves obsoletos.

Ao encerrar, o jogo aguarda o worker e qualquer pedido pendente para não abandonar o último save. A tela de jogo não espera pela conclusão normal do autosave. Os arquivos mantêm os mesmos nomes, versões, dados e semântica de backup existentes.

## Limites e verificação

A thread não elimina todo custo: o snapshot de blocos por chunk e a preparação de caches procedurais ainda ocorrem no fio principal; tampouco saem da thread principal a criação/instalação de meshes e colisões ou reconstruções após edição. Se medições no PC mostrarem picos, o próximo passo é orçar o trabalho de cache e instalação por frame; não compartilhar caches mutáveis com os workers.

Validação atual: Godot 4.7.2, build/editor headless e suíte de jogo aprovados em 272 verificações. A suíte verifica construção exata de faces/colisões, pelo menos uma instalação via worker e leitura dos saves depois de aguardar explicitamente o gravador. Isso valida regressões lógicas, não substitui profiling prolongado na máquina-alvo.
