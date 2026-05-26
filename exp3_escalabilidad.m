% =========================================================================
% exp3_escalabilidad.m
% Experimento 3: escalabilidad del metodo de la potencia
%
% PROPOSITO:
%   Analizar como varia el tiempo de computo y el numero de iteraciones
%   al aumentar el tamanio de la red (n = 20, 42, 61, 100, 135 nodos).
%   Verificar la ventaja O(k*n) del metodo iterativo vs O(n^3) directo.
%
% GENERACION DE REDES:
%   Redes sinteticas con estructura de infraestructura jerarquica:
%   nivel 1 (pocos nodos criticos) -> nivel 2 -> nivel 3 (muchos nodos)
%   Densidad de conexion controlada para simular redes reales.
%
% REFERENCIA:
%   Moler (2004), pp. 75-76 (argumento de escalabilidad)
%   Ponzellini (2025), L4 Errores, L8 Metodos iterativos
% =========================================================================

clear; clc;
fprintf('=====================================================\n');
fprintf('EXPERIMENTO 3: Escalabilidad del metodo de potencia \n');
fprintf('=====================================================\n\n');

% --- Tamanios de red a evaluar ---
tamanios = [20, 42, 61, 100, 135];
n_casos  = length(tamanios);

% --- Almacenamiento de resultados ---
tiempos_pot  = zeros(n_casos, 1);
tiempos_dir  = zeros(n_casos, 1);
iteraciones  = zeros(n_casos, 1);
residuales   = zeros(n_casos, 1);
n_aristas    = zeros(n_casos, 1);

fprintf('%6s  %8s  %10s  %10s  %8s  %10s\n', ...
        'n', 'aristas', 't_pot(s)', 't_dir(s)', 'iter', 'residual');
fprintf('%s\n', repmat('-', 1, 60));

for k = 1:n_casos
  n = tamanios(k);

  % --- Generar red sintetica jerarquica ---
  % Estructura: nodos criticos (10%) -> intermedios (30%) -> terminales (60%)
  G = generar_red_jerarquica(n);
  n_aristas(k) = nnz(G);

  p   = 0.85;
  tol = 1e-8;
  c   = full(sum(G));
  c(c == 0) = 1;
  D   = spdiags(1./c', 0, n, n);
  I   = speye(n);
  e   = ones(n, 1);
  delta = (1 - p) / n;

  % --- Metodo de la potencia ---
  t = tic;
  [~, it, hist] = pagerank(G, p, tol, 200);
  tiempos_pot(k) = toc(t);
  iteraciones(k) = it;
  residuales(k)  = hist(end);

  % --- Sistema directo (solo para n chico, ilustrativo) ---
  if n <= 135
    t = tic;
    M = speye(n) - p * G * D;
    b = delta * e;
    x = M \ b;
    x = x / norm(x, 1);
    tiempos_dir(k) = toc(t);
  else
    tiempos_dir(k) = NaN;
  end

  fprintf('%6d  %8d  %10.6f  %10.6f  %8d  %10.2e\n', ...
          n, n_aristas(k), tiempos_pot(k), tiempos_dir(k), ...
          iteraciones(k), residuales(k));
end

% --- Analisis de crecimiento ---
fprintf('\nAnalisis de crecimiento:\n');
for k = 2:n_casos
  ratio_n   = tamanios(k) / tamanios(k-1);
  ratio_t   = tiempos_pot(k) / tiempos_pot(k-1);
  fprintf('  n: %d->%d (x%.1f) | tiempo_pot: x%.2f\n', ...
          tamanios(k-1), tamanios(k), ratio_n, ratio_t);
end

% --- Graficos ---
figure(1);
subplot(1,2,1);
plot(tamanios, tiempos_pot, 'b-o', 'LineWidth', 2, 'MarkerSize', 6);
hold on;
plot(tamanios, tiempos_dir, 'r-s', 'LineWidth', 2, 'MarkerSize', 6);
xlabel('Numero de nodos n');
ylabel('Tiempo CPU (s)');
title('Tiempo de computo vs tamanio de red');
legend('Metodo potencia O(k*n)', 'Sistema directo O(n^3)');
grid on;

subplot(1,2,2);
plot(tamanios, iteraciones, 'g-^', 'LineWidth', 2, 'MarkerSize', 6);
xlabel('Numero de nodos n');
ylabel('Iteraciones hasta convergencia');
title('Iteraciones del metodo de potencia');
grid on;

fprintf('\nFin Experimento 3.\n');
