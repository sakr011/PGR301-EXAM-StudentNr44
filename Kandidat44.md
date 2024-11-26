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

Container image + SQS URL: sakr011/java-sqs-client

Oppgave 5:

1. Automatisering og Kontinuerlig Levering (CI/CD):

Serverløse arkitekturer har mange små, uavhengige funksjoner, som innebærer at
flere komponenter må utrulles. Dette krever flere utrullinger oftere og 
mer detaljert CI/CD-styring. Heldigvis har vi verktøy som AWS SAM og 
Serverless Framework noe som forenkler automatiseringen, men etterhvert som 
antallet funksjoner øker så kan versjonhåndtering og testing bli utfordrende.
Mikrotjenester involverer ofte færre tjenester å administrere og utrulle.
CI/CD-prosessen innenfor mikrotjenester følger ofte en mer tradisjonell 
tilnærming, men kan fortsatt være utfordrende å holde på med, spesielt når det
er behov for kommunikasjon og koordinering mellom flere ulike tjenester.
Kubernetes og Docker, som ble brukt i oppgave 3, er verktøy som er veldig
populære valg for automatisering av utrulling og håndtering av infrastruktur,
som bidrar til forenkling av drift innenfor mikrotjenester.

2. Overvåkning:

Overvåkning kan være mer krevende i serverløse-arkitekturer, ettersom
funksjonene er tilstandsløse og kortvarige. Det er nødvendig med verktøy som 
AWS CloudWatch for å overvåke logger, målinger og spor, men korrelering av data
på tvers av mange kortvarige funksjoner kan være problematisk. 
Mikrotjenester tilbyr overvåkning og logging som er mer strukturert igjennom 
bruk av verktøy som Prometheus og Grafana, noe som bidrar til lettere sporing 
av logger og utføring av feilsøking.

3. Skalerbarhet og Kostnadskontroll:

Skalerbarhet innenfor serverløs er automatisk basert på etterspørsel.
En av hovedselgepunktene til serverløs er at du kun betaler for det du bruker,
noe som gjør det ekstremt konstnadseffektivt for variabel arbeidsbelastning.
En nedside med dette er at kostnadene kan imidlertidig øke uventet om antall 
funksjonskall øker. Mikrotjenester derimot skalerer igjennom manuell instats 
ved å adminstrere infrastruktur igjennom Kubernetes eller EC2-instanser, 
noe som fører til høyere kostnader grunnet behovet for klargjøring og 
vedlikehold av servere.

4. Eierskap og Ansvar:

I serverløs håndterer skyleverandøren infrastrukturen, slik at DevOps-teamet
i større grad kan fokusere på applikasjonslogikk og overvåkning. Det betyr at 
teamet får mindre ansvar for infrastruktur, men de har fortsatt ansvaret for
kostnadskontroll og ytelse. Når det kommer til mikrotjenester så har
DevOps-teamet fullstendig ansvar over både infrastrukturen og applikasjonen.
Dette innebærer et betydelig høyere krav til administrasjon og vedlikehold av
infrastruktur, men gir økt kontroll over pålitelighet og ytelse blandt teamet.

