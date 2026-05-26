% =========================================================================
% cargar_case118.m
% Parser del IEEE 118 Bus Test Case en formato MATPOWER
%
% FUENTE DE DATOS:
%   IEEE 118 Bus Test Case — datos originales de 1961
%   Formato MATPOWER Version 2 (Cornell University)
%   Descargado de: https://github.com/MATPOWER/matpower/blob/master/data/case118.m
%
% QUE HACE:
%   Lee case118.m de MATPOWER y extrae la topologia de la red
%   como un grafo dirigido para aplicar PageRank.
%
% FORMATO MATPOWER (mpc.branch):
%   Col 1: fbus  — bus origen
%   Col 2: tbus  — bus destino
%   Col 3: r     — resistencia (pu)
%   Col 4: x     — reactancia (pu)
%   Col 5: b     — susceptancia (pu)
%   ...
%   Solo usamos columnas 1 y 2 para construir el grafo.
%
% MODELADO COMO GRAFO DIRIGIDO:
%   Las lineas de transmision son bidireccionales fisicamente,
%   pero las modelamos como directed edges en ambas direcciones
%   para capturar dependencias mutuas entre buses.
%   Esto es consistente con el modelo del navegante aleatorio:
%   si hay flujo de potencia entre A y B, ambos dependen del otro.
%
% TIPOS DE BUS (mpc.bus col 2):
%   1 = PQ bus     (carga, sin generacion)
%   2 = PV bus     (generador)
%   3 = Slack bus  (referencia, generador principal)
%
% SALIDAS:
%   G      : matriz sparse 118x118 de adyacencia
%   info   : struct con metadata de la red
%   mpc    : struct MATPOWER completo (por si se necesita)
%
% USO:
%   [G, info, mpc] = cargar_case118()
%
% PREREQUISITO:
%   case118.m debe estar en el mismo directorio o en el path de Octave
%
% REFERENCIA:
%   IEEE 118 Bus Test Case (1961)
%   MATPOWER — Zimmerman et al., IEEE Trans. Power Syst., 2011
% =========================================================================

function [G, info, mpc] = cargar_case118()

  % --- Verificar que case118.m existe ---
  if ~exist('case118.m', 'file') && ~exist('case118', 'file')
    error(['cargar_case118: no se encontro case118.m\n' ...
           'Descargalo de:\n' ...
           'https://github.com/MATPOWER/matpower/blob/master/data/case118.m\n' ...
           'y copialo a la carpeta del proyecto.']);
  end

  % --- Cargar datos MATPOWER ---
  mpc = case118();

  n_bus    = size(mpc.bus, 1);      % 118 buses
  n_branch = size(mpc.branch, 1);   % 186 ramas

  fprintf('IEEE 118 Bus Test Case cargado:\n');
  fprintf('  Buses   : %d\n', n_bus);
  fprintf('  Ramas   : %d\n', n_branch);

  % --- Extraer topologia ---
  % mpc.branch col 1 = fbus (origen), col 2 = tbus (destino)
  fbus = mpc.branch(:, 1);   % bus origen
  tbus = mpc.branch(:, 2);   % bus destino

  % Los IDs de bus en case118 van de 1 a 118 pero pueden no ser
  % consecutivos. Verificamos y remapeamos si es necesario.
  todos_buses = unique([fbus; tbus; mpc.bus(:,1)]);
  n = length(todos_buses);

  if max(todos_buses) == n
    % IDs consecutivos 1..118: usamos directo
    orig = fbus;
    dest = tbus;
  else
    % Remapear IDs a indices consecutivos
    fprintf('  Remapeando IDs de bus a indices 1..%d\n', n);
    mapa = zeros(max(todos_buses), 1);
    for k = 1:length(todos_buses)
      mapa(todos_buses(k)) = k;
    end
    orig = mapa(fbus);
    dest = mapa(tbus);
  end

  % --- Modelado bidireccional ---
  % Lineas de transmision: flujo en ambas direcciones
  % Duplicamos aristas para capturar dependencia mutua
  orig_bi = [orig; dest];
  dest_bi = [dest; orig];

  % Eliminar autoloops
  mask    = orig_bi ~= dest_bi;
  orig_bi = orig_bi(mask);
  dest_bi = dest_bi(mask);

  % --- Construir matriz sparse ---
  % G(i,j) = 1: nodo j tiene una arista hacia nodo i
  G = sparse(dest_bi, orig_bi, 1, n, n);

  % En redes con lineas paralelas puede haber G(i,j) > 1
  % Para PageRank necesitamos solo conectividad, no multiplicidad
  G = min(G, 1);    % binarizar

  % --- Clasificacion de buses ---
  tipo_bus    = mpc.bus(:, 2);
  idx_slack   = find(tipo_bus == 3);   % slack bus (ref)
  idx_gen     = find(tipo_bus == 2);   % generadores PV
  idx_carga   = find(tipo_bus == 1);   % cargas PQ

  fprintf('  Slack bus (ref): %d  -> bus %d\n', ...
          length(idx_slack), mpc.bus(idx_slack, 1));
  fprintf('  Generadores PV : %d\n', length(idx_gen));
  fprintf('  Cargas PQ      : %d\n\n', length(idx_carga));

  % --- Info struct ---
  info.n           = n;
  info.n_branch    = n_branch;
  info.densidad    = nnz(G) / (n*(n-1));
  info.tipo_bus    = tipo_bus;
  info.idx_slack   = idx_slack;
  info.idx_gen     = idx_gen;
  info.idx_carga   = idx_carga;
  info.bus_ids     = mpc.bus(:, 1);   % IDs originales IEEE
  info.Pd          = mpc.bus(:, 3);   % demanda real (MW)
  info.dangling    = find(full(sum(G)) == 0);

end
