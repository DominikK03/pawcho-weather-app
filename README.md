# 🚀 Weather App - CI/CD Pipeline

![Docker](https://img.shields.io/badge/Docker-2CA5E0?style=for-the-badge&logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)

Projekt demonstrujący kompleksowy pipeline CI/CD dla aplikacji weather-app, wykorzystujący GitHub Actions i Docker Buildx do budowy wieloarchitektonicznych obrazów kontenerów.




## 🔧 Pipeline CI/CD

### 🔄 Automatyczne wyzwalanie

Workflow uruchamia się automatycznie przy:
- Pushu na branch `master`
- Utworzeniu tagu `v*` (np. `v1.0.0`)

### 🏗 Etapy workflow

1. **Przygotowanie środowiska**
    - Konfiguracja QEMU dla wieloarchitekturowości
    - Konfiguracja Docker Buildx
    - Logowanie do Docker Hub

2. **Budowanie obrazu**
    - Budowanie dla architektur: `linux/amd64` i `linux/arm64`
    - Wykorzystanie cache'u dla przyspieszenia
    - Tymczasowe tagowanie jako `pawcho-weather-app:test`

3. **Testy bezpieczeństwa**
    - Skanowanie obrazu pod kątem podatności przy pomocy Trivy (CVE)
    - Blokowanie deployu przy wykryciu HIGH/CRITICAL

4. **Deploy**
    - Tagowanie wersji (semver, sha, latest)
    - Wypchnięcie obrazu na Docker Hub

### 📝 Uzasadnienia
1. **Wersje obrazu**
    - `sha` - tagowanie obrazu na bazie hasha commita, pozwala na zidentyfikowanie kolejnych wersji obrazu
    - `semver` - tagowanie obrazu na bazie semantycznego numeru wersji umożliwia prostsze śledzenie i korzystanie z wersji produkcyjnych
2. **Skanowanie obrazu**
    - `Trivy` - wybrałem Trivy z powodu szybszego i łatwiejszego skanowania obrazu (niż Docker Scout) oraz lepsza integrację z GitHub Actions

## 🐋 Docker Image

### Etapy budowania obrazu

- Etap `build`: 

Używa pełnego obrazu `node:20-alpine` z narzędziami do instalacji zależności (npm install), ale nie trafiają one do finalnego obrazu.
- Etap `run`:

Bazuje na minimalistycznym `alpine:latest` z samym Node.js oraz npm (bez narzędzi developerskich), co redukuje rozmiar i powierzchnię ataku.

### Opis

Dzięki temu rozwizaniu udało się zredukować rozmiar obrazu z 450 MB (z pełnym środowiskiem Node.js) do ~120 MB 

Dodatkowo przy instalacji npm zostały wykorzystane tagi: 
   - --production (do czyszczenia ewentualnych devDependencies) 
   - --ignore-scripts (do wykluczenia potencjalnie niebezpiecznych skryptów npm)

oraz wymuszone czyszczene cache'a, co również przyczyniło się do redukcji rozmiaru obrazu.

`RUN apk --no-cache add nodejs &&\
    rm -rf /var/cache/apk/*`:
- `--no-cache` - Pomija zapisywanie pakietów w cache APK (domyślnie Alpine Linux przechowuje pobrane pakiety w /var/cache/apk/)
- Usuwa ewentualne pozostałości cache (nadmiarowe w przypadku `--no-cache`, ale stanowi dodatkowe zabezpieczenie)

**Efekt:** Instaluje tylko ściśle wymagany pakiet nodejs bez zbędnych danych  

### Usprawnienia, które można jeszcze dodać

- Dodanie Non-root usera w celu ograniczenia uprawnień
- Dodanie pośredniego etapu testowego (npm test), aby sprawdzić, czy aplikacja działa poprawnie
- rozbicie kopiowania na pliki konfiguracyjne i pliki z kodem, w celu optymalizacji cache'owania warstw

### Set up
Aby pobrać i uruchomić kontener należy wykonać następujące kroki:

- docker pull dominikk03/pawcho-weather-app:latest
- docker run -p 3000:3000 dominikk03/pawcho-weather-app:latest
