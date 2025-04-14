# Tesztelési Terv
**Last modified:** 27 március 2025

## 1. Cél
A tesztelés célja, hogy biztosítsuk a Blabber közösségi média platform stabilitását, hibamentességét és megfelelő felhasználói élményét. Elsődlegesen kis csoportok számára készült, így a tesztelés során ezt a szempontot is figyelembe vesszük.

## 2. Tesztelési Stratégiák
### ✅ Funkcionális Tesztelés
- Ellenőrizzük, hogy az alapfunkciók megfelelően működnek
- **Regisztráció és bejelentkezés** – Felhasználó tud fiókot létrehozni és belépni
- **Posztolás** – Poszt létrehozható, szerkeszthető, törölhető
- **Feed működése** – Barátok posztjai megfelelően jelennek meg
- **Ismerősök kezelése** – Kérés küldhető, fogadható, törölhető
- **Chat funkció** – Üzenetek elküldése, fogadása, értesítések

### 🛠️ Teljesítménytesztelés
- Posztok betöltési ideje – Hírfolyam gyorsaságának ellenőrzése
- Üzenetküldés válaszideje – Valós idejű chat késleltetés mérése

### 🔐 Biztonsági Tesztelés
- Adatvédelmi beállítások – Privát információk megfelelő kezelése
- Bejelentkezési rendszer – Jogosulatlan hozzáférés elleni védelem
- SQL Injection / XSS ellenőrzés

### 📱 Reszponzivitás és Keresztplatform Tesztelés
- Mobil és asztali nézet – UI megfelelően skálázódik
- Böngésző kompatibilitás – Chrome, Firefox, Edge, Safari

### 🛠️ Hibajavítás és Regressziós Tesztelés
- Korábban javított hibák ellenőrzése
- Frissítések után újraellenőrzés

## 3. Tesztelési Ütemezés
| Sprint | Tesztelési Terület | Időtartam |  
|--------|---------------------|-----------|  
| 1. Sprint | Alap funkciók (regisztráció, bejelentkezés) | 1 nap |  
| 2. Sprint | Profilkezelés, beállítások | 1 nap |  
| 3. Sprint | Posztolás és hírfolyam tesztelése | 2 nap |  
| 4. Sprint | Ismerősök és keresési funkciók | 1 nap |  
| 5. Sprint | Chat funkció tesztelése | 2 nap |  
| 6. Sprint | Teljes rendszer tesztelés, biztonsági ellenőrzések | 2 nap |  

## 4. Tesztelési Eszközök
- **Postman** – API teszteléshez
- **Flutter driver** – Automata UI tesztek
- **JMeter** – Teljesítménytesztelés
- **Burp Suite** – Biztonsági tesztelés

## 5. Tesztelési Jelentés
Minden sprint végén jelentés készül az észlelt hibákról és a javításokról.  