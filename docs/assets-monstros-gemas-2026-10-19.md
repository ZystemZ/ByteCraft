# Assets de monstros e gemas — 19/10/2026

## Fontes

- Acervo enviado nesta conversa: `/home/ubuntu/upload/assets.zip` (176 MB).
- Ultimate Monsters Bundle by Quaternius, via Poly Pizza (conforme identificação fornecida pelo proprietário).
- Bonfire by Quaternius: https://poly.pizza/m/Azj9hJwwwG
- Gem Green by Quaternius: https://poly.pizza/m/kbgiCMzdxg

## Decisões de integração

- A fogueira já usa o modelo Bonfire em `bytecrafter.gd`; o GLB do ZIP é checksum-idêntico, portanto não foi substituído nem duplicado.
- Zumbi, ET, slime e slime corredor já têm modelos ativos no runtime; eles permanecem intactos.
- Foram importados para `assets/monsters/` os 37 modelos hostis únicos do diretório `monstros/`. Oito modelos de fauna passiva (Birb, Bunny, Cat, Chicken, Fish, Fish-ypEYhCImAB, Frog e Pigeon) ficaram fora do roster hostil.
- A Gema Verde foi importada como asset novo para representar um recurso de inventário/drop obtido dos monstros.


Os esqueletos do bundle variam e não correspondem ao rig Mixamo do retarget atual; por isso os 37 modelos novos não recebem aquele retarget, evitando trilhas de osso inválidas. Eles reutilizam o controlador de movimento, combate, escala e colisão do jogo, com movimento visual leve, enquanto ET e zumbi mantêm seus rigs e animações atuais.
