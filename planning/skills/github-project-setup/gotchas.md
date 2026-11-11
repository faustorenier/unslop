# Gotchas

- `gh project create` richiede `--owner` che può essere username o org
- Per aggiungere issue a un progetto serve lo scope `project` sul PAT:
  `gh auth refresh -s project`
- `gh project item-add` vuole l'URL completo della issue, non solo il numero
- Le label devono esistere prima di usarle in `gh issue create`
- Il flag `2>/dev/null || true` su label create evita errori se esistono già
- `gh project create` restituisce JSON — estrai il numero con `| jq .number`
- Non creare task per "setup boilerplate" banale
- Non separare frontend/backend in task diversi per la stessa feature se il team è unico
- Chiedi sempre conferma prima di creare qualsiasi cosa — le issue non si cancellano facilmente
