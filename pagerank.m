% =========================================================================
% pagerank.m
% Calculo del PageRank mediante el metodo de la potencia
%
% FUNDAMENTO MATEMATICO:
%   Buscamos el vector pi que satisface pi = A*pi
%   donde A = p*G*D + delta es la Matriz de Google.
%   Esto es una iteracion de punto fijo: pi^(k+1) = A * pi^(k)
%   (L8 - Metodos iterativos, L9 - Punto fijo, Ponzellini 2025)
%   Fuente principal: Moler (2004), Cap. 2.11, pp. 75-76
%
% CONVERGENCIA:
%   La norma 1 es natural para distribuciones de probabilidad
%   ya que mide la variacion total entre iteraciones sucesivas.
%   Criterio de parada: norm(pi_nuevo - pi_viejo, 1) < tol
%   (L8 - Normas vectoriales, Ponzellini p.5)
%
% ENTRADAS:
%   G     : matriz de adyacencia sparse n x n (G(i,j)=1 si j->i)
%   p     : factor de amortiguacion (default: 0.85, Moler p.76)
%   tol   : tolerancia para criterio de parada (default: 1e-8)
%   itmax : numero maximo de iteraciones (default: 200)
%
% SALIDAS:
%   pi    : vector nx1 con distribucion de probabilidad de impacto
%           pi(i) indica cuanto daniaria la red si el nodo i fallara
%           IMPORTANTE: NO predice cual nodo va a fallar
%   iter  : numero de iteraciones realizadas
%   hist  : historial de norma 1 del error por iteracion
%
% USO:
%   [pi, iter, hist] = pagerank(G)
%   [pi, iter, hist] = pagerank(G, 0.85, 1e-8, 200)
%
% REFERENCIA:
%   Moler (2004), Numerical Computing with MATLAB, SIAM, pp. 74-81
%   Ponzellini (2025), L8 Metodos iterativos, L9 Punto fijo, UCA
% =========================================================================

function [pi, iter, hist] = pagerank(G, p, tol, itmax)

  % --- Valores por defecto ---
  if nargin < 2, p     = 0.85; end
  if nargin < 3, tol   = 1e-8; end
  if nargin < 4, itmax = 200;  end

  % --- Dimension del problema ---
  n = size(G, 1);

  % --- Verificacion basica ---
  if n ~= size(G, 2)
    error('pagerank: G debe ser una matriz cuadrada.');
  end

  % --- Normalizacion de columnas: construccion de D ---
  % c(j) = numero de enlaces salientes del nodo j
  % Si c(j) = 0, el nodo j es un "dangling node" (sin outlinks)
  % Moler p.76-77: D = spdiags(1./c', 0, n, n)
  c = full(sum(G));                    % suma de cada columna
  dangling = (c == 0);                 % deteccion de dangling nodes
  c(dangling) = 1;                     % evitar division por cero
  D = spdiags(1./c', 0, n, n);        % matriz diagonal sparse

  % --- Construccion de la Matriz de Google ---
  % A = p * G * D + delta
  % donde delta = (1-p)/n es la probabilidad de teleportacion
  % Cada columna de A suma 1 => A es estocastica por columnas
  % Moler p.76: "columns of A sum to 1"
  delta = (1 - p) / n;
  % Nota: no construimos A densa para ahorrar memoria en redes grandes
  % La multiplicacion A*x se expande como:
  %   A*x = p*(G*D*x) + delta*sum(x)*ones(n,1)
  % Como x es distribucion de probabilidad, sum(x) = 1 siempre

  % --- Inicializacion uniforme ---
  % Sin informacion previa, todos los nodos son equiprobables
  % Moler p.75: "start with x = ones(n,1)/n"
  pi = ones(n, 1) / n;

  % --- Historial de convergencia ---
  hist = zeros(itmax, 1);

  % --- Iteracion de punto fijo: pi^(k+1) = A * pi^(k) ---
  % Este es exactamente el esquema iterativo de L8/L9:
  %   x^(k+1) = G(x^(k))
  % donde G(x) = p*(G*D*x) + delta*e
  % (Ponzellini, L9 p.11 - metodo iterativo de Punto Fijo)

  fprintf('Metodo de la potencia - PageRank\n');
  fprintf('n = %d nodos | p = %.2f | tol = %.2e\n\n', n, p, tol);
  fprintf('%6s  %15s\n', 'Iter', 'Error (norma 1)');
  fprintf('%s\n', repmat('-', 1, 25));

  for iter = 1:itmax

    pi_viejo = pi;

    % Multiplicacion eficiente A*pi sin construir A densa:
    pi = p * (G * (D * pi)) + delta * ones(n, 1);

    % Manejo de dangling nodes: redistribuir su probabilidad
    % Los nodos sin outlinks transfieren peso uniformemente
    pi = pi + p * sum(pi_viejo(dangling)) / n * ones(n, 1);

    % Renormalizacion para mantener sum(pi) = 1
    % (pequeños errores de punto flotante pueden acumularse)
    % L5 - Aritmetica de punto flotante, Ponzellini 2025
    pi = pi / norm(pi, 1);

    % --- Criterio de parada: norma 1 del error ---
    % Norma 1 natural para distribuciones de probabilidad
    % mide la variacion total entre iteraciones
    % (L8 - Normas vectoriales, Ponzellini p.5)
    err = norm(pi - pi_viejo, 1);
    hist(iter) = err;

    if mod(iter, 10) == 0 || iter <= 5
      fprintf('%6d  %15.2e\n', iter, err);
    end

    if err < tol
      fprintf('%6d  %15.2e  <- convergio\n', iter, err);
      break
    end

  end

  % Recortar historial al numero real de iteraciones
  hist = hist(1:iter);

  if iter == itmax && hist(end) >= tol
    fprintf('\nADVERTENCIA: se alcanzo el maximo de iteraciones sin converger.\n');
    fprintf('Error final: %.2e | Tolerancia: %.2e\n', hist(end), tol);
  else
    fprintf('\nConvergencia alcanzada en %d iteraciones.\n', iter);
  end

  fprintf('Suma del vector pi: %.10f (debe ser 1)\n\n', sum(pi));

end
