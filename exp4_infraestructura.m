% =========================================================================
% exp4_infraestructura.m
% Experimento 4: aplicacion a red de infraestructura real
%
% PROPOSITO:
%   Aplicar PageRank a una red de infraestructura electrica sintetica
%   basada en topologia realista (subestaciones, transformadores, lineas).
%   Identificar nodos criticos y simular el impacto de reforzarlos.
%
% PREGUNTA CENTRAL:
%   pi_i = probabilidad de impacto sistemico del nodo i
%   NO predice cuál nodo va a fallar.
%   Responde: si el nodo i fallara, cuanto danio causaria en la red?
%
% REFERENCIA:
%   Moler (2004), pp. 74-81
%   Ponzellini (2025), L8 Metodos iterativos
% =========================================================================

clear; clc;
fprintf('=====================================================\n');
fprintf('EXPERIMENTO 4: Red de infraestructura electrica     \n');
fprintf('=====================================================\n\n');

% --- Definicion de la red electrica (42 nodos) ---
% Estructura jerarquica:
%   Nodos  1- 4: subestaciones principales (nivel critico)
%   Nodos  5-16: transformadores (nivel intermedio)
%   Nodos 17-42: lineas y puntos de consumo (nivel terminal)

n = 42;
G = generar_red_jerarquica(n, 42);

tipos = [repmat({'subestacion'}, 1, 4), ...
         repmat({'transformador'}, 1, 12), ...
         repmat({'linea'}, 1, 26)];

fprintf('Red electrica sintetica: %d nodos\n', n);
fprintf('  Subestaciones  : 4\n');
fprintf('  Transformadores: 12\n');
fprintf('  Lineas/consumo : 26\n\n');

% --- Calculo del PageRank ---
[pi, iter, hist] = pagerank(G, 0.85, 1e-8, 200);

% --- Identificacion de nodos criticos ---
[pi_ord, idx_ord] = sort(pi, 'descend');
top10_pct = ceil(n * 0.10);   % top 10% = 4-5 nodos

fprintf('Top %d%% nodos mas criticos (top %d de %d):\n', 10, top10_pct, n);
fprintf('%s\n', repmat('-', 1, 45));
fprintf('%5s  %15s  %10s  %12s\n', 'Rank', 'Tipo', 'Nodo', 'pi_i');
fprintf('%s\n', repmat('-', 1, 45));
for k = 1:top10_pct
  fprintf('%5d  %15s  %10d  %12.6f\n', k, tipos{idx_ord(k)}, idx_ord(k), pi_ord(k));
end

% --- Calculo del impacto acumulado ---
impacto_top10 = sum(pi_ord(1:top10_pct));
fprintf('\nImpacto acumulado del top 10%% de nodos: %.4f (%.1f%% del total)\n', ...
        impacto_top10, impacto_top10*100);

% --- Simulacion: que pasa si reforzamos el top 10%? ---
fprintf('\nSimulacion de refuerzo del top %d%% de nodos:\n', 10);
fprintf('(Reforzar = reducir la probabilidad de impacto en 70%%)\n\n');

pi_reforzado = pi;
pi_reforzado(idx_ord(1:top10_pct)) = pi_reforzado(idx_ord(1:top10_pct)) * 0.30;
pi_reforzado = pi_reforzado / norm(pi_reforzado, 1);

impacto_original   = sum(sort(pi, 'descend'));
impacto_post       = sum(sort(pi_reforzado, 'descend'));
reduccion = (1 - sum(pi_reforzado(idx_ord(1:top10_pct))) / impacto_top10) * 100;

fprintf('  Impacto top 10%% original  : %.4f\n', impacto_top10);
fprintf('  Impacto top 10%% reforzado : %.4f\n', sum(pi_reforzado(idx_ord(1:top10_pct))));
fprintf('  Reduccion del riesgo      : %.1f%%\n', reduccion);

% --- Graficos ---
figure(1);
subplot(2,1,1);
bar(pi_ord(1:min(15,n)), 'FaceColor', [0.2 0.4 0.8]);
xlabel('Rank del nodo (1 = mas critico)');
ylabel('\pi_i');
title('Top 15 nodos por probabilidad de impacto sistemico');
grid on;

subplot(2,1,2);
hold on;
bar(1:n, pi,           'FaceColor', [0.2 0.4 0.8], 'FaceAlpha', 0.6);
bar(1:n, pi_reforzado, 'FaceColor', [0.8 0.2 0.2], 'FaceAlpha', 0.6);
xlabel('Nodo');
ylabel('\pi_i');
title('Comparacion: original vs reforzado (top 10%)');
legend('Original', 'Reforzado', 'Location', 'northeast');
grid on;

figure(2);
semilogy(hist, 'b-', 'LineWidth', 1.5);
xlabel('Iteracion k');
ylabel('||pi^{(k)} - pi^{(k-1)}||_1');
title('Convergencia - Red electrica 42 nodos');
grid on;

fprintf('\nFin Experimento 4.\n');
