% =========================================================================
% generar_red_jerarquica.m
% Genera una red sintetica con estructura jerarquica de infraestructura
%
% ESTRUCTURA:
%   Nivel 1: floor(n*0.10) nodos criticos (ej. subestaciones principales)
%   Nivel 2: floor(n*0.30) nodos intermedios (ej. transformadores)
%   Nivel 3: resto de nodos terminales (ej. puntos de consumo)
%
% ENTRADAS:
%   n    : numero total de nodos
%   seed : semilla aleatoria (default: 42, para reproducibilidad)
%
% SALIDAS:
%   G    : matriz sparse n x n de adyacencia
% =========================================================================

function G = generar_red_jerarquica(n, seed)

  if nargin < 2, seed = 42; end
  rand('state', seed);

  n1 = max(1, floor(n * 0.10));   % nivel 1: nodos criticos
  n2 = max(1, floor(n * 0.30));   % nivel 2: intermedios
  % nivel 3: el resto

  orig = [];
  dest = [];

  % Conexiones nivel 1 -> nivel 2
  for i = 1:n1
    targets = n1 + randperm(n2, min(3, n2));
    for t = targets
      orig(end+1) = i;
      dest(end+1) = t;
    end
  end

  % Conexiones nivel 2 -> nivel 3
  n3_inicio = n1 + n2 + 1;
  n3_fin    = n;
  if n3_inicio <= n3_fin
    for i = n1+1 : n1+n2
      n3_disponibles = n3_inicio:n3_fin;
      if ~isempty(n3_disponibles)
        targets = n3_disponibles(randperm(length(n3_disponibles), ...
                  min(3, length(n3_disponibles))));
        for t = targets
          orig(end+1) = i;
          dest(end+1) = t;
        end
      end
    end
  end

  % Algunas conexiones de retorno (nivel 3 -> nivel 1)
  for i = n3_inicio : min(n3_fin, n3_inicio+2)
    j = randi(n1);
    orig(end+1) = i;
    dest(end+1) = j;
  end

  % Eliminar autoloops y duplicados
  mask = orig ~= dest;
  orig = orig(mask);
  dest = dest(mask);

  G = sparse(dest, orig, 1, n, n);

end
