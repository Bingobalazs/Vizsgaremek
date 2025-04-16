 
# Blabber – Social Media Fejlesztési terv

## 1. Projekt Áttekintés
Blabber egy modern közösségi média platform, amelyet elsősorban kis csoportok – például vállalatok, iskolai osztályok vagy baráti társaságok – számára terveztünk. A cél, hogy az ismerősök könnyedén kapcsolatban maradhassanak, tartalmakat osszanak meg, és gyorsan üzenhessenek egymásnak anélkül, hogy elvesznének egy óriási, kaotikus hírfolyamban.

**Valódi példa:** mi is a barátainkkal használjuk.

**A legjobb tulajdonsága? Egyszerű.**  
Nincsenek felesleges sallangok, nem akar mindent tudni rólad, és garantáltan nem próbálja eladni az adatokat valami titokzatos algoritmusnak. Pont annyit tud, amennyit kell – és annyit is fog.

## 2. Főbb Funkciók és Modulok
### 🔹 Felhasználói Profilok
- Regisztráció és bejelentkezés (email/jelszó)
- Saját profil szerkesztése (profilkép, email cím, elérhetőség(privát/nyilvános) )
- Mások profiljának megtekintése

### 📝 Posztolás és Feed
- Szöveges és képes posztok létrehozása
- Posztokhoz való hozzászólás, like és reakciók
- Hírfolyam (feed), amely a barátok és más felhasználók posztjait mutatja időrendi  sorrendben

### 👥 Ismerősök és Keresés
- Ismerősök hozzáadása és eltávolítása
- Ismerősök keresése név alapján
- Ismerősök listájának megtekintése

### 💬 Chat (Üzenetküldés)
- Privát üzenetküldés ismerősöknek
- Online státusz megjelenítése
- Média (képek, fájlok) küldése chatben
- Értesítések új üzenetekről

### 🆔 IdentiCard – Megosztható Profiloldal
- Egyedi link saját profiloldalhoz
- Kapcsolati adatok megosztása (pl. email, telefon, közösségi média)
- Profil testreszabása (pl. színtéma)

## 3. Technológiai Stack
### Backend
- Laravel – API fejlesztés
- MySQL  – adatbázis
- SSE – valós idejű üzenetküldés

### Frontend
- Flutter – mobil, web, desktop app fejlesztes

### Egyéb
- GitHub – verziókezelés
- JWT – autentikáció és jogosultságkezelés

## 4. Fejlesztési Ütemterv
### 1. Sprint – Alapok és beállítások (1-2 hét)
✅ Projekt alapjainak lerakása  
✅ Backend API és adatbázis szerkezet megtervezése  
✅ Alap frontend váz megépítése

### 2. Sprint – Felhasználói autentikáció és profilkezelés (2 hét)
✅ Bejelentkezés, regisztráció, jelszókezelés  
✅ Profil szerkesztés és megtekintés

### 3. Sprint – Posztolás és feed (2-3 hét)
✅ Poszt létrehozása, megjelenítése  
✅ Hírfolyam fejlesztése

### 4. Sprint – Ismerősök kezelése és keresés (2 hét)
✅ Ismerősök hozzáadása, eltávolítása  
✅ Keresési funkció fejlesztése

### 5. Sprint – Chat funkció (3 hét)
✅ Üzenetküldés alapok  
✅ Valós idejű kommunikáció integrálása

### 6. Sprint – Tesztelés, optimalizálás, végső simítások (3 hét)
✅ Hibajavítások  
✅ Teljesítmény optimalizálás  
✅ Biztonsági ellenőrzések

## 6. Összegzés
Blabber egy könnyen használható és modern közösségi média platform lesz, amely a felhasználók számára interaktív élményt nyújt. A fejlesztés során a felhasználói élmény, a teljesítmény és a biztonság kiemelt szerepet kap.

👥 **Fejlesztők:** Balázs & Csaba  
🚀 **Cél:** Egy letisztult, könnyen használható platform, ami nem akar világhódító techóriás lenni – csak egy hasznos eszköz a megfelelő embereknek.