# ByteCrafter

Protótipo de sandbox voxel 3D, aventura, construção e sobrevivência feito em Godot. Esta entrega inclui uma rodada de correções de estabilidade, persistência e desempenho. O alvo de longo prazo continua sendo uma experiência muito rica, próxima do escopo de Minecraft 1.18; esta versão é somente a primeira base jogável, não uma implementação completa desse conteúdo.

**Integração Cube World — 23/10/2026:** novos blocos 3D, cogumelos/bambus/flores com drop próprio, modelos equipáveis de ferramentas e espadas, cama portátil craftável, baú e caixote. Consulte [`docs/INTEGRACAO_CUBE_WORLD_2026-10-23.md`](docs/INTEGRACAO_CUBE_WORLD_2026-10-23.md) e os créditos em `assets/bitmal/credits.txt`.

## Abrir no Godot

- Recomendado: Godot **4.7.2 standard** (GDScript; o projeto não requer Godot .NET nem SDK C#).
- Na tela Project Manager, escolha **Import** e selecione este `project.godot`; depois abra o projeto e pressione **F5** para executar a cena principal.
- Para a prévia gerenciada/Web, o projeto usa o contrato padrão `true` → `site/`; use o fluxo Webdev do projeto. A versão Web é de jogador único: partidas LAN exigem o build nativo do Godot.


## Atualização de fontes — 16/10/2026 (revisão de inventário/crafting)

- Corrigido o ciclo principal de `_process`: a simulação não fica mais presa à condição de remoção da tela inicial depois dos primeiros três segundos. Dia/noite, interação, mineração, sobrevivência e atualização da HUD voltam a ser processados durante a partida.
- Adicionado cache temporário de alturas do terreno, limpo quando o centro do streaming muda, para evitar chamadas repetidas de ruído ao montar os chunks próximos.
- O carregamento de alterações do mundo valida formato, coordenadas, altura e IDs de blocos, com limite de registros aceitos.
- Os saves de mundo e perfil passam a usar arquivo temporário e backup durante a substituição, reduzindo o risco de perder o save anterior se a gravação falhar.
- O perfil valida o tipo dos dados de inventário/posição e limita a quantidade de drops restaurados.
- Crafting informa sucesso ou falta de recursos e limita pilhas de itens coletados.
- A grade 3×3 armazena ingredientes reais: clique direito em um item para mover uma unidade à primeira célula livre; clique numa célula ocupada para devolver o ingrediente.
- A grade reconhece receitas de tronco para tábuas, duas tábuas verticais para gravetos e o padrão de picareta de madeira. Clique no slot de resultado para concluir a receita.
- O conteúdo da grade de crafting é salvo no perfil e restaurado ao carregar.
- Esc fecha o inventário pelo mesmo fluxo do botão de fechar, devolvendo os ingredientes da grade ao inventário.
- As três receitas existentes agora usam o catálogo central `scripts/game/crafting_recipe_book.gd`, com ingredientes, saída, limite de pilha, estação declarada e regra espacial.
- O crafting rápido e pela grade verificam o espaço da saída antes de consumir ingredientes; o limite da picareta também é aplicado.
- Os rigs CC de ET, zumbi e boss usam `scripts/game/rig_animation_controller.gd`: os clips padrão de caminhada, ataque e morte são retargetados do esqueleto Mixamo-fonte para o esqueleto CC. O slime permanece com o visual procedural existente.
- O mundo agora popula coelhos, vacas, ovelhas e porcos caçáveis. Coelhos fornecem carne; vacas, carne e couro; ovelhas, lã e carne; porcos, carne e banha. A tecla F/clique esquerdo usa o mesmo golpe do combate, com fuga e drops persistentes.
- A tecla T coloca uma mesa de craft física consumindo `mesa_craft`; a tecla E abre a interface de crafting. Foram adicionados receitas de mesa, tochas e preparação de carne com banha. Pedra exige picareta; blocos leves continuam mineráveis manualmente.
- A progressão da mesa inclui lingote de ferro, picareta, machado e espada de ferro. O ferro é obtido combinando pedra e banha na grade, e as ferramentas têm efeitos distintos: picareta acelera pedra, machado acelera madeira e espada aumenta o dano.
- Couro pode virar capacete, peitoral, calças e botas. As peças são reconhecidas automaticamente como proteção, com redução acumulável de 15% por peça até 60%, e a proteção é aplicada ao dano recebido antes do respawn.
- A exploração procedural agora classifica o terreno em planícies, campos de musgo, regiões congeladas, zonas vulcânicas e biomas de cristal. Cada um altera o bloco de superfície: musgo, gelo, basalto ou cristal. Ruínas/torres antigas aparecem de forma determinística pela seed fora do spawn, usando pedra antiga e minério brilhante.
- Blocos de cristal geram `Cristal` ao serem minerados; cristal + banha produzem a `Lanterna de cristal`, criando uma recompensa de exploração além dos recursos comuns.
- O tile de folhas do atlas foi corrigido para manter preenchimento opaco dentro do próprio bloco. A transparência vazada que permitia enxergar o terreno inteiro através de uma única camada de folhas foi removida, sem alterar os demais blocos.
- A correção posterior preserva a transparência visual lateral das folhas; somente as faces superior/inferior usam uma tampa opaca para não revelar o terreno abaixo. Troncos e folhas continuam quebráveis sem ferramenta.
- O zumbi foi reorientado para o eixo vertical correto, normalizado para 1,80 unidade (tamanho do jogador), teve o alcance reduzido e só causa dano com linha de visão desobstruída.

**Marco anterior de validação de modelos e animação (Godot 4.7.2):** suíte de gameplay aprovada em **147 verificações**, incluindo clips de pulo/morte dos avatares, retarget de movimento/ataque/morte dos inimigos não-slime, barras de vida e alinhamento de escala/collider. Os detalhes são históricos; a validação atual das opções está registrada na revisão de sobrevivência abaixo.

## Controles
| Ação | Teclado/mouse | Controle |
| --- | --- | --- |
| Andar | W, A, S, D | Analógico esquerdo |
| Pular / correr | Espaço / Shift | A / clique no analógico esquerdo (L3) |
| Minerar/atacar | G ou botão esquerdo | Gatilho direito ou botão esquerdo |
| Usar/posicionar item | R ou botão direito | B |
| Interagir com aldeão/estrutura | F | X |
| Inventário e crafting | E; clique direito coloca item na grade; clique esquerdo devolve; clique no resultado fabrica | Y |
| Trocar câmera / pausar | V / Esc | R3 / Start |
| Atalhos 1–9 | Teclas 1–9 ou roda do mouse | Direcional (atalhos 1–4 por padrão) |
| Mesa de craft / plantar / salvar | T / P / F5 | Configuráveis na tela de controles |
| Olhar | Mouse (cursor capturado durante o jogo) | Analógico direito |

Os campos de teclado e controle podem ser remapeados no menu **Configurações → Controles**. O mouse continua disponível como entrada independente.

## Configurações e dificuldade

O menu **Configurações** está disponível antes da partida e durante a pausa. Ele reúne remapeamento de teclado/controle, volumes separados de música e efeitos e opções de vídeo (resolução, tela cheia, qualidade, VSync e filtros **Normal**, **Retrobit** e **Cel shading**). Em jogabilidade, permite desligar monstros hostis, ajustar a distância de chunks e o campo de visão. As opções são aplicadas e salvas localmente.

Antes de **continuar** ou **criar** um mundo solo, o jogador escolhe **Fácil**, **Médio** ou **Difícil**. Fácil reduz encontros e dano recebido e desacelera a fome; difícil eleva o limite/frequência dos inimigos e acelera a fome. A escolha da sessão é salva no perfil.

## Partida em LAN

No menu inicial, um jogador escolhe **Hospedar LAN** e os demais escolhem **Entrar na LAN**, informando o IP local do anfitrião. Os dispositivos precisam estar na mesma rede e liberar UDP na porta **24567** no firewall. A conexão não usa servidor público. O smoke test com duas instâncias nativas do Godot confirmou entrada na mesma seed e sincronização de alteração/coleta de blocos; ainda falta a aceitação em dois dispositivos físicos.

## O que existe nesta base

- Terreno voxel procedural em chunks, com streaming, cavernas simples, árvores e superfícies texturizadas.

### Revisão de sobrevivência e vilas — 19/10/2026

- Inventário com **36 slots reais** (9 na barra rápida + 27 na mochila), pilhas independentes e operações de pegar, dividir, depositar, mesclar, shift-click e arrastar/trocar slots.
- Ciclo persistente de dia/noite com sol, lua, nuvens e estrelas; zumbis e ETs respeitam a exposição à luz, com limites de spawn e combate revisados.
- Crafting inclui fornalha com slots separados de entrada, combustível e saída; portas, alçapões, janelas, camas e barracas são props físicos. A barraca é craftável; portas/alçapões alternam estado e a cama define respawn.
- Vilas determinísticas com três casas, camas, mercado e três aldeões/aldeãs. Moradores caminham entre casa e pontos de trabalho durante o dia e procuram suas camas à noite; a comerciante abre uma loja com trocas validadas por recursos e espaço na mochila.
- O perfil versão 6 salva fase do dia, aldeões ativos ou descarregados por streaming, posição, rotina e alterações do mundo. Vilas/edificações estáticas são regeneradas pela seed e os snapshots dos NPCs são restaurados no retorno.
- Os rigs FBX dos aldeões medem cerca de 1,89 m no esqueleto; a escala visual de 0,86 alinha o modelo ao collider de 1,62 m e a rotação Y de 180° os orienta para a vila. O GLB `Shack by Quaternius` está importado, mas não é usado pela geração atual: seu tamanho importado (~0,91 × 0,77 × 1,17 m) é pequeno para uma casa sem escala adicional; as casas atuais são montadas proceduralmente.
- O bundle Ultimate Monsters acrescenta 37 inimigos hostis com arquétipos de combate, nomes, escala, drops, sensibilidade ao amanhecer e seleção gradual para spawns noturnos. Os inimigos existentes (slime, zumbi e ET) não foram substituídos; fauna passiva do pacote ficou fora do roster hostil.
- A Gema Verde de Quaternius é um item coletável representado pelo GLB recebido e pode ser trocado com aldeões por dois fragmentos lunares. A fogueira de Quaternius já estava ativa no jogo, então o modelo idêntico do pacote não foi copiado nem substituído.
- O menu Configurações funciona na tela inicial e na pausa, com remapeamento de teclado/gamepad, volumes independentes, resolução/qualidade/VSync, filtros Normal/Retrobit/cel shading, FOV, chunks e toggle de monstros. Criar e continuar mundo solo pedem uma escolha de dificuldade; a dificuldade fica no perfil.
- Otimização para sessões longas: no máximo 64 drops ativos; cada drop expira após 5 minutos, faz raycast de chão a cada 0,5 s e atualiza sua posição salva a cada 1 s. Autosave a cada 60 s, JSON compacto e limite de 60 FPS reduzem trabalho de CPU, disco e GPU.
- Streaming: o worker calcula buffers de geometria de um snapshot imutável, um chunk por vez; instalação de meshes, colisões e nós permanece na thread principal. Autosave agora serializa e grava cópias profundas numa thread dedicada, coalescendo pedidos e aguardando o último snapshot ao fechar. Detalhes e limites estão em [otimização de streaming e save](docs/otimizacao-streaming-e-save.md).

**Validação desta revisão (Godot 4.7.2):** compilação e execução headless sem erros e suíte automatizada aprovada em **272 verificações**, incluindo instalação de chunk por worker, faces/colisões, gravação assíncrona, expiração de drops, limite de FPS, clique e movimentação de pilhas pela GUI da mochila, configurações/rebinding, áudio, filtros, dificuldade ao criar/continuar, catálogo/spawn de monstros, drop/troca da Gema Verde, vilas e save/load.

### Outros recursos da base

- Quebrar/colocar blocos, recursos soltos coletáveis, barra rápida, crafting básico e picareta visível.
- Sobrevivência inicial (vida/fome), ciclo dia/noite, criaturas passivas e slime hostil.
- Dano letal entra em estado de morte, toca a animação `death`, bloqueia controles por 1,25 s e depois reaparece no spawn da seed.
- Câmeras em primeira e terceira pessoa, salvamento local e cooperação ENet para sessões LAN nativas.

A geração de mundo, combate, conteúdo, biomas, itens, criaturas, progressão e sistemas de aventura ainda precisam de muitas etapas para atingir a ambição completa do produto.

## Verificação

- `npm run check` executa a validação finita da cena, do spawn, do ciclo de blocos, dos controles e dos saves.
- `npm run check -- --pack` valida um checkpoint Godot já preparado.
- Os testes preservam e restauram os arquivos de save do usuário.

## Referências e licenças

As referências recebidas e as notas sobre o que foi adaptado estão em [`docs/referencias-tecnicas.md`](docs/referencias-tecnicas.md) e [`docs/assets-monstros-gemas-2026-10-19.md`](docs/assets-monstros-gemas-2026-10-19.md). O projeto usa referências/arquivos escolhidos pelo usuário, além de código GDScript próprio e trechos técnicos portados. As licenças de cada componente ainda precisam ser verificadas antes de redistribuição; o responsável pelo projeto cuidará de obter permissões adicionais ou substituir os itens que não puderem ser distribuídos. **Não distribua esta cópia antes de resolver essas obrigações.**

**Crédito solicitado pelo proprietário:** Zelipe — Zystem e ZConsole. Este registro de agradecimento não afirma que os projetos Zystem/ZConsole ou seus códigos estejam empacotados nesta cópia.

### Correção de cenário e colisões (16/10/2026)

O streaming agora gera imediatamente o chunk central ao mudar de região, valida a malha de colisão e adiciona colisões dedicadas aos troncos. A copa das árvores também foi engrossada. Consulte `docs/RELATORIO_AUDITORIA_E_ATUALIZACAO_2026-10-16.md`. Esta revisão ainda requer teste no editor Godot 4.7.
