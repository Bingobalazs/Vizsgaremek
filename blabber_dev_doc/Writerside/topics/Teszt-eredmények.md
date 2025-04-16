# Felhasználói Tesztelési Eredmények

## 1. Regisztráció

- **Teszt:** Új e-mail címmel történő regisztráció.  
  **Eredmény:** Sikeres regisztráció, a megerősítő kód 1 percen belül megérkezett e-mailben.

- **Teszt:** Már használt e-mail címmel történő regisztráció.  
  **Eredmény:** "Hiba történt" üzenet jelent meg, a regisztráció nem jött létre.  
  **Megjegyzés:** Teszt után visszajelzés alapján pontosították a hibaüzenet szövegét.

- **Teszt:** Csak e-mail cím megadása, jelszó nélkül.  
  **Eredmény:** "Hiba történt" üzenet.  
  **Megjegyzés:** A beviteli mezők validációja javítva lett, azóta nem engedi elküldeni az űrlapot hiányos adat esetén.

## 2. Bejelentkezés

- **Teszt:** Helyes e-mail és jelszó megadása.  
  **Eredmény:** Sikeres bejelentkezés.

- **Teszt:** Üres e-mail címmel történő bejelentkezés.  
  **Eredmény:** 500-as hiba jelent meg.  
  **Megjegyzés:** A teszt után bekerült egy kliensoldali ellenőrzés, azóta nem küldi el az űrlapot üres mezőkkel.

- **Teszt:** Hibás jelszóval történő próbálkozás.  
  **Eredmény:** "Hiba történt" hibaüzenet jelent meg.  
  **Megjegyzés:** A hibakezelés változatlan, de stabilan működik.

## 3. Kereső

- **Teszt:** Keresés létező felhasználóra.  
  **Eredmény:** Találatok megjelentek, név alapján helyesen listázva.

- **Teszt:** Keresés posztra tartalom alapján.  
  **Eredmény:** A kapcsolódó posztok megjelentek.

- **Teszt:** Keresés hosszú értelmetlen karakterlánccal.  
  **Eredmény:** Nem jelent meg találat.  
  **Megjegyzés:** Egyszer hibát dobott, ezt követően javítottuk a keresési lekérdezés hosszának kezelését.

## 4. Posztolás

- **Teszt:** Csak szöveges poszt létrehozása.  
  **Eredmény:** Megjelent a feedben, helyes időbélyeggel.

- **Teszt:** Szöveg + kép feltöltése.  
  **Eredmény:** Először CORS hiba volt, ez a szerverbeállításoktól függ dolgozunk rajta. 
Böngésző **pluginnal**, vagy **mobilon** a kép megjelent a posztban. A képfeltöltés mindig működött.

- **Teszt:** Üres poszt próbálása.  
  **Eredmény:** "Hiba történt" üzenet jelent meg.  
  **Megjegyzés:** Ezután bevezetésre került egy figyelmeztető üzenet, ami nem engedi üres poszt elküldését.

## 5. Chat funkció

- **Teszt:** Ismerősnek jelölt személlyel való beszélgetés indítása.  
  **Eredmény:** A chat működött, az üzenetek valós időben megjelentek.


- **Teszt:** Gyors egymás utáni üzenetküldés.  
  **Eredmény:** Egy alkalommal nem jelent meg azonnal az üzenet, de frissítés után láthatóvá vált.  
  **Megjegyzés:** A websocket kapcsolat stabilizálva lett.

## 6. Profil funkciók

- **Teszt:** Profilkép feltöltése (JPG, PNG, JPEG).  
  **Eredmény:** A kép sikeresen cserélődött.

- **Teszt:** Saját poszt szerkesztése és mentése.  
  **Eredmény:** A módosított poszt megjelent.

- **Teszt:** Poszt törlése.  
  **Eredmény:** A poszt azonnal eltűnt a feedből.

- **Teszt:** Másik profil megtekintése.  
  **Eredmény:** A nyilvános adatok és posztok láthatók voltak.

- **Teszt:** Ismerősnek jelölés és visszajelölés.  
  **Eredmény:** A jelölés és visszajelölés zökkenőmentes volt.

## 7. IdentiCard

- **Teszt:** Saját névjegykártya megosztása.  
  **Eredmény:** A link megnyitható, az adatok olvashatók.

- **Teszt:** Más felhasználó identicard linkjének megnyitása.  
  **Eredmény:** A kártya betöltődött, a profilinformációk jól láthatók.

- **Teszt:** IdentiCard megnyitása mobilról.  
  **Eredmény:** Mobilnézetben is jól működik, reszponzív kialakítás.

- **Teszt:** IdentiCard szerkesztése.  
  **Eredmény:** A módosított kártya megjelent.



### 🛠️ Teljesítménytesztelés

- **Teszt:** Feed posztok betöltési ideje (WiFi és mobilnet).  
  **Eredmény:** Átlagosan 1-1.5 másodpercen belül jelentek meg az új posztok.

- **Teszt:** Chat válaszidő (valós idejű üzenetküldés).  
  **Eredmény:** Az üzenetek 1.4–1.6 másodpercen belül jelentek meg a másik félnek.


### 🔐 Biztonsági Tesztelés

- **Teszt:** Privát profil megnyitása nem ismerős fiókkal.  
  **Eredmény:** Nem jelent meg semmilyen poszt.

- **Teszt:** Jogosulatlan hozzáférés, token nélkül.
  **Eredmény:** Nem engedik meg a hozzáféréset, a hibák megjelentek.

### 📱 Reszponzivitás és Keresztplatform Tesztelés

- **Teszt:** Mobil nézet (iPhone 15, Xiaomi Redmi Note 13 Pro).  
  **Eredmény:** Először mobil nézetben a saját posztok oldalon összecsúszott pár gomb. 
  Ezek kisebb, ikonokra lettek cserélve. Utána az UI minden méreten jól megjelent, minden funkció elérhető.

- **Teszt:** Asztali nézet (Chrome 1920x1080 és 2560x1440).  
  **Eredmény:** A dizájn arányosan töltötte ki a képernyőt, nem volt elcsúszás.

- **Teszt:** Böngészők – Chrome, Firefox, Edge, Safari.  
  **Eredmény:** Az oldal minden böngészőben stabilan és esztétikusan jelent meg.

