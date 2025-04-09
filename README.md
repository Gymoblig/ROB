# 🚒 Vizualizácia Priamej Kinematickej Úlohohy – Hasičská Plošina

## 📘 Zadanie

Simulácia výsuvnej plošiny hasičského auta rieši priamu kinematickú úlohu pomocou transformačných matíc. Projekt je vytvorený v MATLABe (verzia 2025a) s dôrazom na vizualizáciu 3D pohybu a pracovného priestoru.

---

## ✅ Ciele

- Odvodiť transformačnú maticu medzi svetovým a koncovým súradnicovým systémom.
- Vypočítať pozíciu koncového bodu – miesto dotyku plošiny s objektom.
- Vizualizovať pracovný priestor v rovinách **X₀Z₀** a **X₀Y₀**.
- Zobraziť animáciu výsuvu plošiny v rôznych konfiguráciách.

---

## 🔧 Kinematický Model

Model pozostáva zo 4 pohyblivých častí:

- `φ1` – rotácia základne
- `φ2` – nakláňanie rebríka
- `L5` – vysúvanie rebríka
- `φ3` – nakláňanie plošiny

Transformačná matica:

```
T08 = Tx(-L1) * Tz(L3) * Rz(φ1) * Tx(-L2) * Tz(L4) * Ry(φ2) * Tz(L5) * Ry(φ3)
```

Bod P8:

```
P8 = [L6; 0; 0; 1]
```

Vzťah pre počítanie bodu P0:

```
P0 = T08 * P8
```

---

## 📊 Matice

### Matica A

```
A = Tx(-L1) * Tz(L3) * Rz(φ1)
```

```
A =
[ cos(φ1) -sin(φ1)   0   -L1
  sin(φ1)  cos(φ1)   0     0
       0         0     1    L3
       0         0     0     1 ]
```

### Matica B

```
B = Tx(-L2) * Tz(L4) * Ry(φ2)
```

```
B =
[ cos(φ2)   0  -sin(φ2)   -L2
      0       1       0          0
  sin(φ2)   0   cos(φ2)    L4
      0       0       0          1 ]
```

### Matica C

```
C = Tz(L5) * Ry(φ3)
```

```
C =
[ cos(φ3)   0  -sin(φ3)    0
      0       1       0         0
  sin(φ3)   0   cos(φ3)   L5
      0       0       0         1 ]
```

---

## 📝 MATLAB Kód (skratka)

```matlab
Tx_L1 = [1 0 0 -L1; 0 1 0 0; 0 0 1 0; 0 0 0 1];
Tz_L3 = [1 0 0 0; 0 1 0 0; 0 0 1 L3; 0 0 0 1];
Tz_L5 = [1 0 0 0; 0 1 0 0; 0 0 1 L5; 0 0 0 1];

Rz = [cosd(fi1) -sind(fi1) 0 0; sind(fi1) cosd(fi1) 0 0; 0 0 1 0; 0 0 0 1];
Ry2 = [cosd(fi2) 0 sind(fi2) 0; 0 1 0 0; -sind(fi2) 0 cosd(fi2) 0; 0 0 0 1];
Ry3 = [cosd(fi3) 0 sind(fi3) 0; 0 1 0 0; -sind(fi3) 0 cosd(fi3) 0; 0 0 0 1];
```

---

## 📹 Vizualizácia

Skript vypočíta XY a XZ pracovný priestor iteratívne pre:
- fi1 od 0 do 360 po 10°
- fi2 od 0 do 90 po 30°
- dĺžka od 0 po 50 jednotiek

Pracovný priestor sa uloží do `XYpoints.txt` a vizualizuje cez `fill3()`.

---

## 📄 Spustenie

- `Manipulator3D.m` zobrazuje statickú konfiguráciu.
- `PlosinaAPP.m` poskytuje GUI s možnosťou interaktívnej zmeny uhla/dĺžky.
- Kompatibilita: MATLAB 2025a a MATLAB Online.

---

## 📊 Záver

Projekt demonštruje praktické využitie transformačných matíc pri simulácii a vizualizácii komplexného pohybu. Získané poznatky majú uplatnenie v robotike a technickom modelovaní.

---

## 📞 Zdroje

- [MathWorks - plot3](https://www.mathworks.com/help/matlab/ref/plot3.html)
- [MathWorks - fill3](https://www.mathworks.com/help/matlab/ref/fill3.html)
- [MathWorks - quiver3](https://www.mathworks.com/help/matlab/ref/quiver3.html)
- [MathWorks - apps overview](https://www.mathworks.com/help/matlab/creating_guis/apps-overview.html)
- [YouTube vizualizácia](https://www.youtube.com/watch?v=TGK17fUA5Nw)

---

## 💪 ČeSTNÉ PREHLÁSENIE

Zadanie som vypracoval sám. ČeSTNE prehlasujem, že som ho neskopíroval a nikomu inému neposkytol.

_Nech mi je Isaac Asimov svedkom._
```
