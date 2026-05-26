% =========================================================================
% exp2_comparar_metodos.m
% Experimento 2: comparacion de los tres metodos de calculo del PageRank
%
% METODOS COMPARADOS:
%   1. Metodo de la potencia (iterativo)
%      x = ones(n,1)/n; repetir x = A*x hasta convergencia
%      Costo: O(k*n) por iteracion | Moler p.75-76
%      Justificacion: unico viable para n muy grande
%
%   2. Sistema directo no singular
%      (I - p*G*D) * x = delta * e
%      Costo: O(n^3) | No singular porque p < 1 | Moler p.76-77
%      Justificacion: exacto para n chico
%
%   3. Inverse iteration (sistema singular)
%      x = (I - A) \ e;  x = x / sum(x)
%      Sistema singular pero funciona por redondeo en punto flotante
%      Moler p.77-78: "blows up in exactly the right direction"
%
% METRICAS:
%   - Numero de iteraciones (solo metodo 1)
%   - Tiempo de CPU (tic/toc)
%   - Norma 1 del residual: ||pi - A*pi||_1
%   - Diferencia entre soluciones: ||pi_1 - pi_2||_1
%
% REFERENCIA:
%   Moler (2004), pp. 75-78
%   Ponzellini (2025), L7 SEL directos, L8 iterativos
% =========================================================================

clear; clc;
fprintf('=====================================================\n');
fprintf('EXPERIMENTO 2: Comparacion de los tres metodos      \n');
fprintf('=====================================================\n\n');

% --- Red de prueba: 6 nodos de Moler ---
nombres = {'alpha','beta','gamma','delta','rho','sigma'};
n = 6;
j_origen  = [1 2 2 3 3 3 4 5 6];
i_destino = [2 3 4 4 5 6 1 6 1];
[G, ~] = construir_red(j_origen, i_destino, n, nombres);

p     = 0.85;
tol   = 1e-8;
itmax = 200;
delta = (1 - p) / n;

% --- Preparacion de matrices ---
c = full(sum(G));
c(c == 0) = 1;
D     = spdiags(1./c', 0, n, n);
I     = speye(n, n);
e     = ones(n, 1);
A     = p * G * D + delta;           % Matriz de Google densa (n chico)

% =========================================================
% METODO 1: Metodo de la potencia
% =========================================================
fprintf('--- Metodo 1: Potencia (iteracion de punto fijo) ---\n');
t1 = tic;
[pi1, iter1, hist1] = pagerank(G, p, tol, itmax);
tiempo1 = toc(t1);
res1 = norm(pi1 - A*pi1, 1);
fprintf('  Tiempo CPU   : %.6f s\n', tiempo1);
fprintf('  Iteraciones  : %d\n', iter1);
fprintf('  Residual ||pi - A*pi||_1 : %.2e\n\n', res1);

% =========================================================
% METODO 2: Sistema directo no singular
% (I - p*G*D) * x = delta * e
% No singular porque p < 1 garantiza que (I - p*G*D) es invertible
% Moler p.76: "as long as p is strictly less than one..."
% Conecta con L7 - eliminacion Gaussiana (Ponzellini)
% =========================================================
fprintf('--- Metodo 2: Sistema directo (I - p*G*D)\\(delta*e) ---\n');
t2 = tic;
M  = I - p * G * D;                  % matriz del sistema (no singular)
b  = delta * e;                      % lado derecho
x2 = M \ b;                          % backslash = eliminacion Gaussiana
pi2 = x2 / norm(x2, 1);             % normalizar para que sume 1
tiempo2 = toc(t2);
res2 = norm(pi2 - A*pi2, 1);
fprintf('  Tiempo CPU   : %.6f s\n', tiempo2);
fprintf('  Residual ||pi - A*pi||_1 : %.2e\n\n', res2);

% =========================================================
% METODO 3: Inverse iteration (sistema singular)
% (I - A) * x = e  con (I - A) SINGULAR
% Funciona porque el error de redondeo en punto flotante evita
% el cero exacto. Al normalizar, el residual se vuelve minimo.
% Moler p.78: "blows up in exactly the right direction"
% Conecta con L5 - aritmetica de punto flotante (Ponzellini)
% =========================================================
fprintf('--- Metodo 3: Inverse iteration (sistema singular) ---\n');
t3 = tic;
warning('off', 'all');               % suprimir aviso de singularidad
x3 = (I - A) \ e;                   % sistema singular: funciona por roundoff
warning('on', 'all');
pi3 = x3 / sum(x3);                 % normalizar: x3/sum(x3)
tiempo3 = toc(t3);
res3 = norm(pi3 - A*pi3, 1);
fprintf('  Tiempo CPU   : %.6f s\n', tiempo3);
fprintf('  Residual ||pi - A*pi||_1 : %.2e\n\n', res3);

% =========================================================
% TABLA COMPARATIVA
% =========================================================
fprintf('=================================================\n');
fprintf('TABLA COMPARATIVA\n');
fprintf('=================================================\n');
fprintf('%-30s  %12s  %12s  %12s\n', 'Metrica', 'Potencia', 'Directo', 'Inv.Iter.');
fprintf('%s\n', repmat('-', 1, 72));
fprintf('%-30s  %12.6f  %12.6f  %12.6f\n', 'Tiempo CPU (s)', tiempo1, tiempo2, tiempo3);
fprintf('%-30s  %12d  %12s  %12s\n',        'Iteraciones', iter1, 'N/A', 'N/A');
fprintf('%-30s  %12.2e  %12.2e  %12.2e\n',  'Residual norma 1', res1, res2, res3);
fprintf('%-30s  %12.2e  %12.2e  %12s\n',    'Dif. con metodo 1', 0, norm(pi1-pi2,1), num2str(norm(pi1-pi3,1),'%.2e'));

% =========================================================
% RESULTADOS POR NODO
% =========================================================
fprintf('\nPageRank por nodo (comparacion):\n');
fprintf('%-8s  %10s  %10s  %10s\n', 'Nodo', 'Potencia', 'Directo', 'Inv.Iter.');
fprintf('%s\n', repmat('-', 1, 45));
for k = 1:n
  fprintf('%-8s  %10.6f  %10.6f  %10.6f\n', nombres{k}, pi1(k), pi2(k), pi3(k));
end

% =========================================================
% ANALISIS CRITICO
% =========================================================
fprintf('\nAnalisis:\n');
fprintf('  - Los tres metodos producen resultados practicamente identicos.\n');
fprintf('  - El metodo de la potencia es O(k*n): escala bien para n grande.\n');
fprintf('  - El sistema directo es O(n^3): impracticable para n grande.\n');
fprintf('  - Inverse iteration funciona por el comportamiento del redondeo\n');
fprintf('    en aritmetica de punto flotante IEEE 754 (L5 - Ponzellini).\n');

% =========================================================
% GRAFICOS
% =========================================================
figure(1);
semilogy(hist1, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 4);
xlabel('Iteracion k');
ylabel('||pi^{(k)} - pi^{(k-1)}||_1');
title('Convergencia metodo de la potencia - Exp 2');
grid on;

figure(2);
x_pos = 1:n;
bar(x_pos, [pi1, pi2, pi3]);
set(gca, 'XTickLabel', nombres);
legend('Potencia', 'Directo', 'Inv. Iter.', 'Location', 'northeast');
xlabel('Nodo');
ylabel('\pi_i');
title('Comparacion de los tres metodos - 6 nodos');
grid on;

fprintf('\nFin Experimento 2.\n');
