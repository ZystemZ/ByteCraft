# Integração do Cube World Kit — 23/10/2026

- Os 58 GLBs do kit recebido foram adicionados em `assets/userpack/cubeworld/`. Os blocos voxel antigos continuam intactos.
- Cogumelo, bambu e flores (IDs 34–36) podem surgir no terreno, quebram em 0,20 s e dropam o próprio item na proporção 1:1.
- Doze blocos Cube World (IDs 37–48) são colocáveis e quebráveis. Na grade 3×3, quatro materiais iguais em um padrão 2×2 viram quatro blocos 3D correspondentes; ao quebrar, cada bloco retorna o próprio item 1:1.
- Espadas e picaretas por tier agora usam modelos do kit; o machado de ferro aparece equipado e mantém sua vantagem ao quebrar madeira/props. Foram adicionadas pás craftáveis (madeira, pedra e ferro), com modelos do kit e velocidade maior para terra/grama/areia.
- Cama comum usa `Bed Single`; a cama portátil usa `Bedroll`, define o mesmo ponto de renascimento e pode ser usada para dormir. Receita exata na grade: `Lã ×3` na linha superior e `Couro ×3` logo abaixo.
- Drops de cama/cama portátil exibem seus modelos. Baú e caixote também usam os modelos 3D do kit. Os demais assets do pacote permanecem disponíveis no diretório para expansões posteriores; não foram todos adicionados como itens de gameplay nesta revisão.

## Créditos fornecidos

- Bed Single by Kenney: https://poly.pizza/m/sn8az3odMR
- Bedroll by Kenney: https://poly.pizza/m/efwd5fjuMU
- Cube World Kit by Quaternius via Poly Pizza (pacote GLB fornecido pelo proprietário).

Os créditos também estão em `assets/bitmal/credits.txt`. As licenças individuais devem ser verificadas antes de redistribuir o projeto, conforme o aviso principal no `README.md`.

## Validação

Importação headless do editor sem erros; suíte Godot aprovada em **300 verificações**, incluindo novas regressões para flora rápida, drops 1:1, blocos colocáveis e receita de cama portátil.
