# PageRank sobre Redes de Infraestructura

**Identificación de nodos críticos mediante PageRank y Cadenas de Markov**

Proyecto integrador — Métodos y Cómputo Numéricos · UCA Rosario 2025  
Equipo: Formenti Agustín  · Ortiz Victoria · Chocobares Juan Cruz  
Software: GNU Octave 10.3.0 (compatible MATLAB)

---

## Pregunta central

> ¿Qué nodo no puede fallar?

Dada una red de infraestructura modelada como grafo dirigido, identificamos los nodos cuya falla produce el mayor daño en cascada. El score de PageRank π_i representa la **probabilidad de impacto sistémico** del nodo i — no predice qué nodo va a fallar, sino cuánto daño causaría si fallara.

---

## Fundamento matemático

El algoritmo resuelve la iteración de punto fijo:

```
π^(k+1) = p · G · D · π^(k) + δ · e
```

donde `G` es la matriz de adyacencia sparse, `D` normaliza por grado de salida, `p = 0.85` es el factor de amortiguamiento (Brin & Page, 1998) y `δ = (1−p)/n` es la probabilidad de teleportación que maneja dangling nodes.

El algoritmo es una **iteración de punto fijo** en el sentido de L8/L9 (Ponzellini, 2025). La convergencia está garantizada por el Teorema de Perron-Frobenius: el término de teleportación hace que el operador sea una contracción en norma 1 sobre el espacio de distribuciones de probabilidad, lo que garantiza un único punto fijo positivo.

Criterio de parada: `‖π^(k+1) − π^(k)‖₁ < tol`

La norma 1 es natural para distribuciones de probabilidad porque mide la variación total entre iteraciones sucesivas (L8 Ponzellini, p.5).

---

## Estructura del proyecto

```
pagerank.m                 Algoritmo principal — método de la potencia
construir_red.m            Construye la matriz sparse de adyacencia
generar_red_jerarquica.m   Genera redes sintéticas de infraestructura

exp1_seis_nodos.m          Verificación contra Moler pp.78-79
exp2_comparar_metodos.m    Compara los 3 métodos de solución
exp3_escalabilidad.m       Análisis de escalabilidad O(k·n)
exp4_infraestructura.m     Aplicación a red eléctrica sintética (42 nodos)
exp5_case118.m             IEEE 118 Bus Test Case — datos reales

cargar_case118.m           Parser del formato MATPOWER
INSTRUCCIONES_CASE118.txt  Cómo descargar y correr exp5
```

---

## Orden de ejecución

```matlab
>> exp1_seis_nodos        % verificar implementación contra Moler
>> exp2_comparar_metodos  % comparar los 3 métodos de solución
>> exp3_escalabilidad     % análisis de escalabilidad
>> exp4_infraestructura   % aplicación a red sintética
>> exp5_case118           % IEEE 118 bus (requiere case118.m, ver instrucciones)
```

Para exp5 es necesario descargar `case118.m` desde:  
https://github.com/MATPOWER/matpower/blob/master/data/case118.m

---

## Resultados

### Experimento 1 — Red de 6 nodos (Moler pp.78-79)

| Nodo | π calculado | π Moler | Estado |
|------|-------------|---------|--------|
| alpha | 0.2675 | 0.2675 | ✓ |
| beta | 0.2524 | 0.2524 | ✓ |
| delta | 0.1697 | 0.1662 | ~ |
| gamma | 0.1323 | 0.2046 | ✗ |
| sigma | 0.1156 | 0.0625 | ✗ |
| rho | 0.0625 | 0.0625 | ✓ |

Las diferencias en gamma y sigma se explican porque los valores impresos en Moler **no suman 1** (suman 1.0157). Son valores truncados de una versión del algoritmo sin renormalización. Nuestra solución satisface el criterio de punto fijo con residual `‖π − Aπ‖₁ = 4.91e-9`. La segunda impresión de Moler (2008) documenta corrección de errores tipográficos en la sección 2.11.

### Experimento 2 — Comparación de métodos

| Método | Tiempo (s) | Iteraciones | Residual ‖π − Aπ‖₁ |
|--------|-----------|-------------|----------------------|
| Potencia (iterativo) | 0.005221 | 40 | 4.91e-09 |
| Directo `(I−pGD)\δe` | 0.000712 | N/A | 1.11e-16 |
| Inverse iteration | 0.000110 | N/A | 4.86e-17 |

Los tres métodos producen resultados idénticos a 6 decimales. La inverse iteration resuelve `(I−A)x = e` con `(I−A)` teóricamente singular — funciona porque el error de redondeo IEEE 754 evita el cero exacto (Moler p.78, L5 Ponzellini).

### Experimento 3 — Escalabilidad

| n | Iteraciones | t potencia (s) | t directo (s) |
|---|-------------|----------------|----------------|
| 20 | 27 | ~0.0044 | ~0.0007 |
| 42 | 20 | 0.003110 | 0.000271 |
| 61 | 23 | 0.004641 | 0.000844 |
| 100 | 14 | 0.003037 | 0.000251 |
| 135 | 14 | 0.002924 | 0.001093 |

El número de iteraciones es aproximadamente constante (14–27) independientemente de n, lo que confirma que el costo es O(k·n) con k determinado por p=0.85, no por el tamaño de la red (Moler pp.75-76).

### Experimento 4 — Red eléctrica sintética (42 nodos)

Top 5 nodos críticos:

| Rank | Tipo | Nodo | π_i |
|------|------|------|-----|
| 1 | subestación | 2 | 0.0496 |
| 2 | subestación | 3 | 0.0382 |
| 3 | línea | 33 | 0.0351 |
| 4 | línea | 20 | 0.0339 |
| 5 | línea | 22 | 0.0322 |

El top 10% (5 nodos) concentra el 18.9% del impacto sistémico total. Reforzar esos nodos reduce el riesgo sistémico un **65.4%**.

### Experimento 5 — IEEE 118 Bus Test Case

| Métrica | Valor |
|---------|-------|
| Buses | 118 |
| Ramas | 186 |
| Iteraciones hasta convergencia | 64 |
| Error final | 9.76e-09 |
| Bus más crítico | Bus 49 (PV), π = 0.0214 |
| Slack bus (69) | Rank 10 de 118 — top 20% ✓ |
| Media generadores PV | 0.009602 |
| Media cargas PQ | 0.007452 |
| Top 10% concentra | 19.6% del impacto total |

Validación estructural: generadores PV tienen mayor impacto promedio que cargas PQ (0.0096 > 0.0075), y el slack bus está en el top 20% — ambos resultados esperados para una red de transmisión real.

---

## Trazabilidad

| Archivo / componente | Fuente |
|----------------------|--------|
| `pagerank.m` — método de la potencia | Moler (2004) pp.74-81 |
| `pagerank.m` — iteración de punto fijo | Ponzellini (2025) L8/L9 |
| `pagerank.m` — norma 1 como criterio de parada | Ponzellini (2025) L8 p.5 |
| `construir_red.m` — matrices sparse | Moler (2004) p.77 |
| `exp2` — sistema directo con backslash | Moler (2004) pp.76-77, L7 Ponzellini |
| `exp2` — inverse iteration sobre matriz singular | Moler (2004) pp.77-78, L5 Ponzellini |
| `exp3` — argumento O(k·n) | Moler (2004) pp.75-76 |
| Factor p = 0.85 | Brin & Page (1998) |
| IEEE 118 Bus Test Case | Zimmerman et al., IEEE Trans. Power Syst. 26(1), 2011 |

---

## Bibliografía

- Brin, S. & Page, L. (1998). *The anatomy of a large-scale hypertextual web search engine*. Computer Networks and ISDN Systems, 30(1-7), 107-117.
- Moler, C. (2004). *Numerical Computing with MATLAB*. SIAM. Cap. 2.11, pp. 74-81.
- Ponzellini, G. (2025). Lecturas L5, L7, L8, L9 — Métodos y Cómputo Numéricos. UCA Rosario.
- Zimmerman, R. et al. (2011). MATPOWER: Steady-State Operations, Planning, and Analysis Tools for Power Systems Research and Education. *IEEE Trans. Power Syst.*, 26(1):12-19.

