=========================================================================
PROYECTO: Identificacion de nodos criticos en redes de infraestructura
          mediante PageRank y Cadenas de Markov
MATERIA : Metodos y Computos Numericos - UCA Rosario 2025
EQUIPO  : Agu (teoria) | Vicky (codigo) | Choco (experimentos)
SOFTWARE: GNU Octave (compatible MATLAB)
=========================================================================

ARCHIVOS DEL PROYECTO:
-----------------------
pagerank.m               - Algoritmo principal: metodo de la potencia
                           Iteracion de punto fijo (L8/L9 Ponzellini)
                           Fuente: Moler pp.75-76

construir_red.m          - Construye la matriz sparse de adyacencia
                           Fuente: Moler p.77

generar_red_jerarquica.m - Genera redes sinteticas de infraestructura
                           Para experimentos 3 y 4

exp1_seis_nodos.m        - Verificacion contra ejemplo de Moler pp.78-79
                           Test unitario basico del proyecto

exp2_comparar_metodos.m  - Compara los 3 metodos de solucion:
                           Potencia | Directo | Inverse iteration
                           Fuente: Moler pp.75-78

exp3_escalabilidad.m     - Analisis de crecimiento temporal
                           n = 20, 42, 61, 100, 135 nodos

exp4_infraestructura.m   - Aplicacion a red electrica sintetica
                           Identificacion de nodos criticos
                           Simulacion de refuerzo del top 10%

ORDEN DE EJECUCION:
-------------------
1. exp1_seis_nodos       (verificar que el codigo funciona)
2. exp2_comparar_metodos (comparar los 3 metodos)
3. exp3_escalabilidad    (analisis de escalabilidad)
4. exp4_infraestructura  (aplicacion real)

CONCEPTOS CLAVE (para la defensa):
------------------------------------
- pi_i = probabilidad de impacto sistemico del nodo i
  NO predice cual nodo va a fallar.
  Responde: si el nodo i fallara, cuanto danio causaria?

- El metodo de la potencia es una ITERACION DE PUNTO FIJO
  (NO decir autovector dominante - no esta en el programa)
  Esquema: pi^(k+1) = A * pi^(k)
  Criterio de parada: norm(pi_nuevo - pi_viejo, 1) < tol

- Convergencia garantizada porque p < 1 contrae el operador
  (L9 Ponzellini: norma del jacobiano < 1)

- Norma 1 es natural para distribuciones de probabilidad

TRAZABILIDAD:
-------------
pagerank.m         -> Moler pp.74-81 | L8 L9 Ponzellini
construir_red.m    -> Moler pp.76-77 | L7 Ponzellini
exp1               -> Moler pp.78-79 (resultados conocidos)
exp2 metodo directo-> Moler pp.76-77 | L7 Ponzellini
exp2 inv.iteration -> Moler pp.77-78 | L5 Ponzellini
exp3 escalabilidad -> Moler pp.75-76 (argumento O(k*n))
exp4               -> Moler pp.74-81 | L4 L8 Ponzellini

USO DE IA:
----------
Claude AI (Anthropic) utilizado para redaccion de comentarios
y estructura del codigo. TODO el contenido matematico fue
verificado contra Moler 2004 y las lecturas del curso.
=========================================================================
