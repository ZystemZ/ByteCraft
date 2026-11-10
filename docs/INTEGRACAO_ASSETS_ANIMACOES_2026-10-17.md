# Integração de assets, itens e animações

## Assets novos

- Os FBX foram preservados em `assets/userpack/characters` e `assets/userpack/animations`.
- ET e zumbi usam os novos rigs Mixamo enviados.
- O avatar usa clips Mixamo externos via retargeting.

## Animações conectadas

- `Walking (1).fbx`: caminhada.
- `Running.fbx`: corrida.
- `Jump.fbx`: salto.
- `Martelo 2.fbx`: mineração/uso de ferramenta.
- `Standing Melee Attack Horizontal.fbx`: ataque com arma.
- `Dying.fbx`: morte.

Também foram instaladas como clips disponíveis: abertura de porta, salto descendente, corrida rápida, caminhada/corrida para trás, socos, ataques verticais/combo, reação, atordoamento, bola de fogo e escalada.

## Itens e mundo

- Picaretas de madeira, pedra e ferro.
- Espadas de madeira, pedra e ferro.
- Tocha com madeira + banha ou madeira + carvão.
- Receita de baú usando oito tábuas.
- Baú e tocha 3D do pacote podem ser colocados com clique direito quando estão na hotbar.
- `F` próximo a um baú executa a animação de abrir/interagir.
- Blocos decorativos extras foram adicionados à paleta das ruínas procedurais: tijolos, tijolos cinzentos, carvão, cristal, diamante e pedra talhada. Eles podem ser minerados e retornam como blocos.

## Validação

O projeto foi carregado pelo Godot headless sem erros de parser. O smoke test confirmou os estados `walk`, `run`, `jump`, `mine`, `attack` e `door` nos avatares Mixamo e CC.
