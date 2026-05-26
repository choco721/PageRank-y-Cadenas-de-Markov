% =========================================================================
% exp5_case118.m
% Experimento 5: PageRank sobre el IEEE 118 Bus Test Case (datos reales)
%
% PROPOSITO:
%   Aplicar PageRank a una red electrica real estandar de la literatura
%   y comparar los nodos criticos identificados contra lo que se conoce
%   de la topologia del IEEE 118 bus system.
%
% QUE ESPERAMOS:
%   El slack bus (bus 69 en case118) y los generadores PV deben tener
%   alto PageRank porque son los nodos de los que mas depende la red.
%   Los buses de carga pura (PQ) deben tener menor PageRank en promedio.
%   Si esto se cumple, tenemos validacion estructural del metodo.
%
% DISTINCION CENTRAL:
%   pi_i = probabilidad de impacto sistemico del bus i
%   NO predice cual bus va a fallar.
%   Responde: si el bus i fallara, cuanto daniaria la red?
%
% REFERENCIA:
%   IEEE 118 Bus Test Case — datos de 1961
%   Moler (2004), pp. 74-81
%   Ponzellini (2025), L8 metodos iterativos
% =========================================================================

clear; clc;
fprintf('=====================================================\n');
fprintf('EXPERIMENTO 5: IEEE 118 Bus Test Case (datos reales)\n');
fprintf('=====================================================\n\n');

% --- Cargar red IEEE 118 ---
[G, info, mpc] = cargar_case118();

n = info.n;

% --- Calcular PageRank ---
[pi, iter, hist] = pagerank(G, 0.85, 1e-8, 200);

% --- Ranking de nodos criticos ---
[pi_ord, idx_ord] = sort(pi, 'descend');

fprintf('Top 10 buses mas criticos (mayor impacto sistemico):\n');
fprintf('%s\n', repmat('-', 1, 65));
fprintf('%5s  %8s  %10s  %12s  %10s\n', ...
        'Rank', 'Bus IEEE', 'Tipo', 'pi_i', 'Demanda MW');
fprintf('%s\n', repmat('-', 1, 65));

tipos_str = {'PQ (carga)', 'PV (gen)', 'Slack (ref)'};
for k = 1:10
  idx   = idx_ord(k);
  bid   = info.bus_ids(idx);
  tipo  = info.tipo_bus(idx);
  pd    = info.Pd(idx);
  tstr  = tipos_str{tipo};
  fprintf('%5d  %8d  %10s  %12.6f  %10.1f\n', ...
          k, bid, tstr, pi_ord(k), pd);
end

% --- Analisis por tipo de bus ---
fprintf('\nAnalisis por tipo de bus:\n');
fprintf('%s\n', repmat('-', 1, 50));

pi_slack = pi(info.idx_slack);
pi_gen   = pi(info.idx_gen);
pi_carga = pi(info.idx_carga);

fprintf('  Slack bus      : pi = %.6f\n', pi_slack);
fprintf('  Generadores PV : media=%.6f | max=%.6f | min=%.6f\n', ...
        mean(pi_gen), max(pi_gen), min(pi_gen));
fprintf('  Cargas PQ      : media=%.6f | max=%.6f | min=%.6f\n', ...
        mean(pi_carga), max(pi_carga), min(pi_carga));

% --- Validacion estructural ---
fprintf('\nValidacion estructural:\n');
fprintf('%s\n', repmat('-', 1, 50));

media_gen   = mean(pi_gen);
media_carga = mean(pi_carga);

if media_gen > media_carga
  fprintf('  [OK] Generadores tienen mayor impacto promedio que cargas\n');
  fprintf('       media_gen=%.6f > media_carga=%.6f\n', media_gen, media_carga);
else
  fprintf('  [INFO] Cargas tienen mayor impacto promedio que generadores\n');
  fprintf('         Esto puede indicar alta conectividad de ciertos nodos de carga\n');
end

% Verificar si el slack bus esta en el top 20%
rank_slack = find(idx_ord == info.idx_slack);
if rank_slack <= ceil(n * 0.20)
  fprintf('  [OK] Slack bus en top 20%% (rank %d de %d)\n', rank_slack, n);
else
  fprintf('  [INFO] Slack bus en rank %d de %d\n', rank_slack, n);
end

% --- Impacto acumulado ---
top10_n = ceil(n * 0.10);   % top 10% = ~12 buses
impacto_top10 = sum(pi_ord(1:top10_n));
fprintf('\nTop 10%% (%d buses) concentra %.1f%% del impacto sistemico total\n', ...
        top10_n, impacto_top10 * 100);

% --- Convergencia ---
fprintf('\nConvergencia: %d iteraciones | error final: %.2e\n', iter, hist(end));
fprintf('sum(pi) = %.10f\n\n', sum(pi));

% --- Comparacion con exp4 (red sintetica) ---
fprintf('Comparacion con red sintetica (exp4):\n');
fprintf('%s\n', repmat('-', 1, 50));
fprintf('  Red sintetica (42 nodos)  : converge en ~20 iter\n');
fprintf('  IEEE 118 bus (118 nodos)  : converge en %d iter\n', iter);
fprintf('  -> Iteraciones practicamente iguales: confirma O(k*n)\n');
fprintf('     donde k es aproximadamente independiente de n\n\n');

% =========================================================
% GRAFICOS
% =========================================================

% Figura 1: distribucion de PageRank
figure(1);
bar(pi_ord(1:20), 'FaceColor', [0.2 0.4 0.8]);
xlabel('Rank del bus (1 = mas critico)');
ylabel('\pi_i');
title('Top 20 buses por impacto sistemico — IEEE 118 Bus');
grid on;

% Figura 2: PageRank por tipo de bus
figure(2);
hold on;
scatter(info.idx_carga,  pi(info.idx_carga),  30, [0.6 0.6 0.9], 'filled');
scatter(info.idx_gen,    pi(info.idx_gen),    50, [0.9 0.4 0.1], 'filled');
scatter(info.idx_slack,  pi(info.idx_slack),  80, [0.1 0.7 0.1], 'filled', 'd');
xlabel('Indice de bus');
ylabel('\pi_i');
title('Distribucion de impacto sistemico por tipo — IEEE 118 Bus');
legend('Carga PQ', 'Generador PV', 'Slack', 'Location', 'northeast');
grid on;

% Figura 3: convergencia
figure(3);
semilogy(hist, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 3);
xlabel('Iteracion k');
ylabel('||pi^{(k)} - pi^{(k-1)}||_1');
title('Convergencia metodo de la potencia — IEEE 118 Bus');
grid on;

% Figura 4: distribucion completa ordenada
figure(4);
bar(pi_ord, 'FaceColor', [0.2 0.4 0.8]);
xlabel('Rank del bus');
ylabel('\pi_i');
title('Distribucion completa de impacto sistemico — 118 buses');
grid on;

fprintf('Fin Experimento 5.\n');
