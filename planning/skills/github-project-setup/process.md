# Process

## Step 1 — Verifica scope project

Prima di tutto chiedi:
> "Come si chiama il progetto? (es. 'Nome progetto MVP')"
> "Il repo GitHub esiste già? Se sì, qual è il nome? (es. owner/repo)"

## Step 2 — Proponi struttura

**Se arriva un backlog da slice-backlog**, non ri-derivare nulla: usa le sue issue,
i suoi `Blocked by` e il suo ready set, e passa direttamente alla tabella di conferma.

Altrimenti, basandoti su SPEC.md/PRD e sui dati raccolti, proponi:
- Lista epiche (macro-aree)
- Lista task per feature (non per layer tecnico)

Mostra tutto in una tabella prima di creare qualsiasi cosa:

| Epic | Task | Tipo | Complessità |
|------|------|------|-------------|
| Frontend | Login screen | feat | M |
| Backend | Auth API | feat | M |
| ...

Chiedi conferma:
> "Confermo questa struttura e creo tutto su GitHub?"

## Step 3 — Crea le label (se non esistono)
```bash
gh label create "epic" --color "#0075ca" --description "Macro-area" --repo OWNER/REPO 2>/dev/null || true
gh label create "task" --color "#e4e669" --description "Single PR task" --repo OWNER/REPO 2>/dev/null || true
gh label create "frontend" --color "#d93f0b" --repo OWNER/REPO 2>/dev/null || true
gh label create "backend" --color "#0e8a16" --repo OWNER/REPO 2>/dev/null || true
gh label create "infra" --color "#5319e7" --repo OWNER/REPO 2>/dev/null || true
```

## Step 4 — Crea le epiche

Per ogni epic:
```bash
gh issue create \
  --title "Epic: NOME_EPIC" \
  --body "DESCRIZIONE" \
  --label "epic" \
  --repo OWNER/REPO
```
Salva i numeri delle issue epiche — servono per i task.

## Step 5 — Crea i task

Per ogni task:
```bash
gh issue create \
  --title "NOME_TASK" \
  --body "CORPO_TASK" \
  --label "task,frontend|backend|infra" \
  --repo OWNER/REPO
```
Usa il template in issue-template.md per il body.

Salva la corrispondenza titolo-slice → numero issue: serve per le dipendenze.

### Step 5b — Traduci le dipendenze `Blocked by`

Se le slice avevano relazioni `Blocked by`, dopo aver creato tutte le issue riportale
come riferimenti fra issue, così il DAG sopravvive su GitHub:
```bash
gh issue edit NUMERO \
  --body "$(gh issue view NUMERO --json body -q .body)

Blocked by: #N, #M" \
  --repo OWNER/REPO
```

## Step 6 — Crea il GitHub Project con kanban
```bash
# Crea il progetto
gh project create \
  --owner OWNER \
  --title "NOME_PROGETTO" \
  --format json
```

Salva il numero del progetto dall'output (campo `number`).
```bash
# Aggiungi ogni issue al progetto
gh project item-add NUMERO_PROGETTO \
  --owner OWNER \
  --url URL_ISSUE
```

Ripeti per ogni issue creata (epiche + task).

## Step 7 — Output finale

Produce una tabella riassuntiva:

| Issue | Tipo | Link |
|-------|------|------|
| Epic: Frontend | epic | #1 |
| Login screen | task | #2 |
| ...

> "GitHub Project creato: LINK_AL_PROGETTO"
> "Kanban board pronta con N issue."
