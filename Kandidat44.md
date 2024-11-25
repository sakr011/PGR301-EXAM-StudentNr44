Oppgave 1 leveransekrav:
A. https://tlzd0igtu7.execute-api.eu-west-1.amazonaws.com/Prod/generate-image/
B. https://github.com/sakr011/PGR301-EXAM-StudentNr44/actions/runs/11961971281

Oppgave 2:
Terraform Apply - https://github.com/sakr011/PGR301-EXAM-StudentNr44/actions/runs/12017565496
Terraform Plan  - https://github.com/sakr011/PGR301-EXAM-StudentNr44/actions/runs/12017503557/job/33499953541
SQS-Kø URL      - https://sqs.eu-west-1.amazonaws.com/244530008913/44-image-generation-queue

Oppgave 3:
Beskrivelse av taggestrategi:
Jeg valgte latest-tag og Commit SHA-tag, latest-tag for gjør det lettere for brukere å alltid få tilgang til 
den nyeste versjonen av applikasjonen uten å måtte spesifisere en versjon,
og Commit SHA-tag fordi den gir en unik identifikator for hver spesifikke versjon
basert på aktuell kode i main-branchen. Den gir også fra seg sporbarhet og mulighet
til å rulle tilbake en spesifikk versjon av applikasjonen om det skulle ønskes.

sakr011/java-sqs-client