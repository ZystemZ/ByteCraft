# Animações extras e fogueira — 23/10/2026

## Animações

O pacote foi incluído em `assets/userpack/animations_extra/` e ligado às entidades do jogo:

- Jogador: nado e flutuação na água; dança automática após 5 minutos sem input; animação ao coletar item; pulo rápido.
- Cama: ao dormir à noite, o jogador escolhe aleatoriamente um dos três clips de sono. Aldeões também escolhem aleatoriamente um clip de sono ao irem para a cama.
- NPCs: mercadores usam `Picking Up` durante o trabalho. Um residente pode, ocasionalmente, dançar perto de uma fogueira; só um NPC dança por vez.
- Inimigos: zumbis usam idle/caminhada e golpe próprios; ETs usam a caminhada enviada.

Os clips extras são carregados por perfil: animações de zumbi/ET não são carregadas em toda criatura, evitando trabalho e memória desnecessários.

## Fogueira

A fogueira já era um prop colocável do jogo. Sua luz Omni agora alcança **10 blocos**; tochas e lanternas mantêm alcance menor. NPCs reconhecem a fogueira pelo grupo de props para a cena cômica.

## Validação

Importação do projeto Godot sem erros de parser e suíte headless: **320 checks aprovados**. Um teste anterior falhou apenas por spawn aleatório de inimigo fora do raio esperado; repetido sem mudanças de código, passou.