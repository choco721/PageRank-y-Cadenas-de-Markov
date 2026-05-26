% =========================================================================
% exp1_seis_nodos.m
% Experimento 1: red de 6 nodos del ejemplo de Moler
%
% PROPOSITO:
%   Verificar que nuestra implementacion reproduce exactamente los
%   resultados conocidos de Moler pp.78-79.
%   Este es el test unitario basico del proyecto.
%
% RED:
%   6 nodos: alpha(1), beta(2), gamma(3), delta(4), rho(5), sigma(6)
%   9 conexiones segun Moler p.77:
%     i = [2 3 4 4 5 6 1 6 1]
%     j = [1 2 2 3 3 3 4 5 6]
%
% RESULTADOS ESPERADOS (Moler p.78-79):
%   alpha = 0.2675  (mayor: todos lo apuntan)
%   beta  = 0.2524  ("basks in alpha's glory")
%   rho   = 0.0625  (minimo: solo recibe de sigma)
%
% REFERENCIA:
%   Moler (2004), pp. 76-79
% =========================================================================

clear; clc;
fprintf('=================================================\n');
fprintf('EXPERIMENTO 1: Red de 6 nodos - Moler pp.78-79  \n');
fprintf('=================================================\n\n');

% --- Definicion de la red (exactamente como Moler p.77) ---
nombres = {'alpha', 'beta', 'gamma', 'delta', 'rho', 'sigma'};
n = 6;

% Indices de aristas: j -> i (origen -> destino)
j_origen  = [1 2 2 3 3 3 4 5 6];   % nodo origen
i_destino = [2 3 4 4 5 6 1 6 1];   % nodo destino

% --- Construccion de la red ---
[G, info] = construir_red(j_origen, i_destino, n, nombres);

% --- Visualizacion de la red ---
fprintf('Matriz de adyacencia G (densa para visualizar):\n');
full(G)

% --- Calculo del PageRank ---
[pi, iter, hist] = pagerank(G, 0.85, 1e-8, 200);

% --- Resultados ---
fprintf('\nResultados PageRank:\n');
fprintf('%8s  %10s  %12s\n', 'Nodo', 'PageRank', 'Porcentaje');
fprintf('%s\n', repmat('-', 1, 35));
[pi_ord, idx] = sort(pi, 'descend');
for k = 1:n
  fprintf('%8s  %10.4f  %11.2f%%\n', ...
          nombres{idx(k)}, pi_ord(k), pi_ord(k)*100);
end

% --- Verificacion contra Moler ---
fprintf('\nVerificacion contra Moler pp.78-79:\n');
fprintf('%s\n', repmat('-', 1, 50));
resultados_moler = [0.2675, 0.2524, 0.2046, 0.1662, 0.0625, 0.0625];
nodos_moler      = {'alpha','beta','gamma','delta','rho','sigma'};
ok = true;
for k = 1:n
  idx_n = find(strcmp(nombres, nodos_moler{k}));
  err_rel = abs(pi(idx_n) - resultados_moler(k)) / resultados_moler(k);
  estado = 'OK';
  if err_rel > 1e-2, estado = 'DIFERENCIA'; ok = false; end
  fprintf('  %-6s: calculado=%.4f | Moler=%.4f | err_rel=%.2e  [%s]\n', ...
          nodos_moler{k}, pi(idx_n), resultados_moler(k), err_rel, estado);
end

if ok
  fprintf('\n  Verificacion exitosa: resultados coinciden con Moler.\n');
else
  fprintf('\n  ATENCION: revisar implementacion.\n');
end

% --- Grafico de convergencia ---
figure(1);
semilogy(hist, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 4);
xlabel('Iteracion k');
ylabel('||pi^{(k)} - pi^{(k-1)}||_1');
title('Convergencia del metodo de la potencia - Exp 1 (6 nodos)');
grid on;
legend(sprintf('Converge en %d iter.', iter));

% --- Grafico de barras PageRank ---
figure(2);
bar(pi(idx), 'FaceColor', [0.2 0.4 0.8]);
set(gca, 'XTickLabel', nombres(idx));
xlabel('Nodo');
ylabel('PageRank \pi_i');
title('Distribucion de probabilidad de impacto - 6 nodos');
grid on;

fprintf('\nFin Experimento 1.\n');
