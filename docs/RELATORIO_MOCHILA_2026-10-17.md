# Mochila e hotbar — 17/10/2026

## Implementado

- A antiga lista de catálogo foi transformada em uma mochila real com 36 slots.
- A hotbar possui 9 slots editáveis.
- Slots da mochila e da hotbar aceitam arrastar e soltar.
- Arrastar entre slots troca os itens; as quantidades continuam compartilhadas pelo inventário lógico.
- Slots vazios aparecem claramente e podem receber itens.
- A hotbar continua selecionável pelas teclas 1–9 e pela roda do mouse.
- Clique direito em um item da mochila continua enviando uma unidade para a grade de crafting.
- A grade de crafting continua aceitando arrastar itens da mochila e devolver ingredientes.
- Itens coletados ou fabricados são vinculados automaticamente a um slot livre quando necessário.
- Organização da mochila, hotbar e grade de crafting passou a ser salva no perfil.
- Saves antigos continuam compatíveis; quando não têm a nova organização, recebem uma distribuição inicial segura.

## Visual e uso

A interface agora usa o título **MOCHILA**, grade de 6 colunas, slots vazios visíveis, quantidade por pilha, nome do item, tooltip e destaque do slot selecionado. A hotbar inferior usa os mesmos componentes de slot, permitindo reorganização direta durante o inventário aberto.

## Validação

A suíte Godot foi executada depois da mudança e passou em 198 verificações, incluindo nove teclas da hotbar, 36 slots da mochila, ícones, nome do item selecionado, crafting, persistência e gameplay.
