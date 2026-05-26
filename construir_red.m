% =========================================================================
% construir_red.m
% Construccion de la matriz de adyacencia sparse para una red
%
% FUNDAMENTO:
%   Representa la red como un grafo dirigido G donde G(i,j) = 1
%   si existe una arista del nodo j hacia el nodo i (convencion
%   de columnas = nodo origen, filas = nodo destino).
%   Usa formato sparse para eficiencia en redes grandes.
%   Moler p.77: "G = sparse(i, j, 1, n, n)"
%
% ENTRADAS:
%   origen  : vector de indices de nodos origen (j)
%   destino : vector de indices de nodos destino (i)
%   n       : numero total de nodos
%   nombres : (opcional) cell array con nombres de los nodos
%
% SALIDAS:
%   G       : matriz sparse n x n de adyacencia
%   info    : struct con estadisticas de la red
%
% USO:
%   [G, info] = construir_red([1 2 2 3], [2 3 4 1], 4)
%   [G, info] = construir_red(origen, destino, n, {'alpha','beta',...})
%
% REFERENCIA:
%   Moler (2004), pp. 76-77
%   Ponzellini (2025), L7 SEL directos (matrices sparse)
% =========================================================================

function [G, info] = construir_red(origen, destino, n, nombres)

  if nargin < 4
    nombres = arrayfun(@(k) sprintf('nodo_%d', k), 1:n, ...
                       'UniformOutput', false);
  end

  % --- Validaciones ---
  if length(origen) ~= length(destino)
    error('construir_red: origen y destino deben tener la misma longitud.');
  end
  if any(origen < 1) || any(origen > n) || any(destino < 1) || any(destino > n)
    error('construir_red: indices fuera del rango [1, n].');
  end

  % --- Construccion de la matriz sparse ---
  % G(i,j) = 1 significa que el nodo j apunta al nodo i
  % En terminos de la red: j tiene un enlace de salida hacia i
  G = sparse(destino, origen, 1, n, n);

  % --- Estadisticas de la red ---
  c_out = full(sum(G));          % grado de salida de cada nodo
  c_in  = full(sum(G, 2))';      % grado de entrada de cada nodo

  info.n          = n;
  info.m          = nnz(G);      % numero de aristas
  info.nombres    = nombres;
  info.grado_out  = c_out;
  info.grado_in   = c_in;
  info.dangling   = find(c_out == 0);   % nodos sin outlinks
  info.densidad   = info.m / (n * (n-1));

  % --- Reporte ---
  fprintf('Red construida:\n');
  fprintf('  Nodos          : %d\n', n);
  fprintf('  Aristas        : %d\n', info.m);
  fprintf('  Densidad       : %.4f\n', info.densidad);
  fprintf('  Dangling nodes : %d', length(info.dangling));
  if ~isempty(info.dangling)
    fprintf(' (nodos: %s)', num2str(info.dangling));
  end
  fprintf('\n\n');

end
