clear;
clc;
close all;

%  plot/save switches
PLOT_OVERLAY = false;
PLOT_TORQUES = false;
PLOT_ERR_DT  = true;
PLOT_CPU_DT  = true;
PLOT_ERR_CPU = true;
PLOT_CONTOUR = true;

SAVE   = true;
OUTDIR = 'part1_figs';
if SAVE
  if ~exist(OUTDIR,'dir')
    mkdir(OUTDIR);
  end
  set(0,'DefaultFigureVisible','off');
end

%  cases
cases = [ ...
  struct('name','StepA','J',100,'b',10,'w0',10,'theta0',0,'Tf',25,'useStep',1,'A',100,'amp',1,'freq',0.1), ...
  struct('name','StepB','J',100,'b',10,'w0',0,'theta0',0,'Tf',25,'useStep',1,'A',0,'amp',1,'freq',0.1), ...
  struct('name','CaseA','J',100,'b',10,'w0',10,'theta0',0,'Tf',25,'useStep',0,'A',100,'amp',1,'freq',0.1), ...
  struct('name','CaseB','J',0.01,'b',0.1,'w0',10,'theta0',0,'Tf',25,'useStep',0,'A',100,'amp',1,'freq',100) ...
];
mdl = 'part1';

%  solvers
fixed_dts = {'0.001','0.01','0.1','1'};
fixed_solvers = {'ode1','ode4'};
var_solvers = {'ode45','ode23tb'};

load_system(mdl);

for c = 1:numel(cases)
  % base parameters
  J = cases(c).J;
  b = cases(c).b;
  w0 = cases(c).w0;
  theta0 = cases(c).theta0;
  Tf = cases(c).Tf;
  useStep = cases(c).useStep;
  A = cases(c).A;
  amp = cases(c).amp;
  freq = cases(c).freq;

  % base workspace
  push = @(n,v) assignin('base',n,v);
  cellfun(@(p) push(p{1},p{2}), { ...
    {'J',J},{'b',b},{'w0',w0},{'theta0',theta0}, ...
    {'useStep',useStep},{'A',A},{'amp',amp},{'freq',freq}});
  set_param(mdl,'StopTime',num2str(Tf));

  % reference: RK4 dt=0.001 (used for sine); analytic used for step
  set_param(mdl,'Solver','ode4','FixedStep','0.001');
  tic;
  refOut = sim(mdl,'SrcWorkspace','base');
  refCPU = toc; 
  t_ref = refOut.tout(:);
  w_ref = refOut.get('w');
  w_ref = w_ref(:);
  th_ref = refOut.get('theta');
  th_ref = th_ref(:); 
  t_in_ref = try_get(refOut,'t_in');
  if isempty(t_in_ref)
    t_in_ref = zeros(size(t_ref));
  end
  tau_b_ref = b .* w_ref;

  if useStep == 1
    w_true_ref = (A/b) + (w0 - A/b) .* exp(-(b/J) .* t_ref);
  end

  emptyRun = struct('solver','','dt','','t',[],'w',[],'theta',[], ...
                    'tau_in',[],'tau_b',[],'cpu',NaN,'maxErr',NaN);
  runs = repmat(emptyRun,0,1);

  % fixed-step sweeps
  for s = 1:numel(fixed_solvers)
    for d = 1:numel(fixed_dts)
      [t,w,theta,tau_in,tau_b,cpu] = run_model(mdl,fixed_solvers{s},fixed_dts{d},b);
      r = emptyRun;
      r.solver = fixed_solvers{s};
      r.dt = fixed_dts{d};
      r.t = t;
      r.w = w;
      r.theta = theta;
      r.tau_in = tau_in;
      r.tau_b = tau_b;
      r.cpu = cpu;
      runs(end+1) = r;
    end
  end

  % variable-step
  for s = 1:numel(var_solvers)
    [t,w,theta,tau_in,tau_b,cpu] = run_model(mdl,var_solvers{s},'',b);
    r = emptyRun;
    r.solver = var_solvers{s};
    r.dt = 'var';
    r.t = t;
    r.w = w;
    r.theta = theta;
    r.tau_in = tau_in;
    r.tau_b = tau_b;
    r.cpu = cpu;
    runs(end+1) = r;
  end

  % errors
  for k = 1:numel(runs)
    tk = runs(k).t;
    wk = runs(k).w;
    if useStep == 0
      w_ref_i = interp1(t_ref, w_ref, tk, 'linear','extrap');
      err = abs(wk - w_ref_i);
    else
      w_true_k = (A/b) + (w0 - A/b) .* exp(-(b/J) .* tk);
      err = abs(wk - w_true_k);
    end
    runs(k).maxErr = max(err);
  end

  % table
  solv = string({runs.solver})';
  dtv = string({runs.dt})';
  cpu = [runs.cpu]';
  err = [runs.maxErr]';
  T = table(solv, dtv, cpu, err, 'VariableNames',{'solver','dt','cpu_s','maxErr'});
  fprintf('\n==== %s  (J=%.4g, b=%.4g, freq=%.4g) ====\n', cases(c).name,J,b,freq);
  disp(T);
  if SAVE
    writetable(T, fullfile(OUTDIR, sprintf('%s_table.csv',cases(c).name)));
  end

  % overlay
  if PLOT_OVERLAY
    showIdx = find(strcmp({runs.solver},'ode45'),1);
    figure;
    plot(runs(showIdx).t, runs(showIdx).w,'DisplayName','test');
    hold on;
    if useStep == 0
      plot(t_ref, w_ref,'--','DisplayName','RK4 dt=0.001 ref');
    else
      plot(t_ref, w_true_ref,'--','DisplayName','analytic');
    end
    grid on;
    xlabel('t [s]');
    ylabel('\omega [rad/s]');
    title(sprintf('%s: S1 \\omega', cases(c).name));
    legend;
    maybe_save(sprintf('%s_overlay.png',cases(c).name), SAVE, OUTDIR);
  end

  % torques
  if PLOT_TORQUES
    figure;
    plot(t_ref, t_in_ref,'DisplayName','\tau_{in}');
    hold on;
    plot(t_ref, tau_b_ref,'--','DisplayName','\tau_b=b\omega');
    grid on;
    xlabel('t [s]');
    ylabel('\tau [N·m]');
    title(sprintf('%s: Torques', cases(c).name));
    legend;
    maybe_save(sprintf('%s_torques.png',cases(c).name), SAVE, OUTDIR);
  end

  % error vs dt
  if PLOT_ERR_DT
    figure;
    hold on;
    grid on;
    for s = 1:numel(fixed_solvers)
      mask = strcmp({runs.solver}, fixed_solvers{s});
      dts = string({runs(mask).dt});
      x = str2double(strrep(dts,'var','NaN'));
      [xsorted, idx] = sort(x);
      y = [runs(mask).maxErr];
      y = y(idx);
      plot(xsorted, y, 'o-','DisplayName',fixed_solvers{s});
    end
    set(gca,'XScale','log','YScale','log');
    xlabel('\Delta t [s]');
    ylabel('max |error| [rad/s]');
    title(sprintf('%s: error vs step', cases(c).name));
    legend;
    maybe_save(sprintf('%s_err_vs_dt.png',cases(c).name), SAVE, OUTDIR);
  end

  % CPU vs dt
  if PLOT_CPU_DT
    figure;
    hold on;
    grid on;
    for s = 1:numel(fixed_solvers)
      mask = strcmp({runs.solver}, fixed_solvers{s});
      x = str2double(strrep(string({runs(mask).dt}),'var','NaN'));
      [xsorted, idx] = sort(x);
      y = [runs(mask).cpu];
      y = y(idx);
      plot(xsorted, y, 'o-','DisplayName',fixed_solvers{s});
    end
    set(gca,'XScale','log');
    xlabel('\Delta t [s]');
    ylabel('CPU [s]');
    title(sprintf('%s: CPU vs step', cases(c).name));
    legend;
    maybe_save(sprintf('%s_cpu_vs_dt.png',cases(c).name), SAVE, OUTDIR);
  end

  % error vs CPU
  if PLOT_ERR_CPU
    figure;
    grid on;
    hold on;
    for k = 1:numel(runs)
      label = sprintf('%s dt=%s',runs(k).solver,runs(k).dt);
      plot(runs(k).cpu, runs(k).maxErr,'o','DisplayName',label);
    end
    set(gca,'YScale','log');
    xlabel('CPU [s]');
    ylabel('max |error| [rad/s]');
    title(sprintf('%s: error vs CPU', cases(c).name));
    legend('Location','eastoutside');
    maybe_save(sprintf('%s_err_vs_cpu.png',cases(c).name), SAVE, OUTDIR);
  end

  % CPU–error contour with iso-ω_in (sine only)
  if PLOT_CONTOUR && useStep == 0
    freq_list = logspace(log10(0.1), log10(100), 12);
    dt_list = [0.001 0.01 0.1];
    ERR = zeros(numel(dt_list), numel(freq_list));
    CPUg = zeros(numel(dt_list), numel(freq_list));
    for ii = 1:numel(dt_list)
      step_str = num2str(dt_list(ii));
      set_param(mdl,'Solver','ode4','FixedStep',step_str);
      for jj = 1:numel(freq_list)
        push('freq', freq_list(jj));
        tic;
        out = sim(mdl,'SrcWorkspace','base');
        CPUg(ii,jj) = toc;
        t = out.tout(:);
        w = out.get('w');
        w = w(:);
        w_ref_i = interp1(t_ref, w_ref, t, 'linear','extrap');
        ERR(ii,jj) = max(abs(w - w_ref_i));
      end
    end
    X = CPUg(:);
    Y = ERR(:);
    Z = repmat(freq_list, numel(dt_list),1);
    Z = Z(:);
    xg = logspace(log10(min(X)), log10(max(X)), 120);
    yg = logspace(log10(max(min(Y(Y>0)),eps)), log10(max(Y)), 120);
    [XG,YG] = meshgrid(xg,yg);
    ZG = griddata(X,Y,Z,XG,YG,'natural');

    figure;
    hold on;
    contourf(XG,YG,log10(ZG),20,'LineColor',[.85 .85 .85]);
    colorbar;
    caxis([log10(0.1) log10(100)]);
    set(gca,'XScale','log','YScale','log');
    xlabel('CPU [s]');
    ylabel('max |error| [rad/s]');
    title(sprintf('%s: CPU–error with iso-\\omega_{in} (RK4)',cases(c).name));
    [C,h] = contour(XG,YG, ZG, [0.1 1 10 100],'k');
    clabel(C,h);
    txt = sprintf('|\\lambda|=%.3g',abs(b/J));
    x_txt = xg(round(numel(xg)*0.7));
    y_txt = yg(round(numel(yg)*0.2));
    text(x_txt, y_txt, txt, 'Color','w','FontWeight','bold');
    push('freq', freq);
    maybe_save(sprintf('%s_cpu_error_contour.png',cases(c).name), SAVE, OUTDIR);
  end
end

%  helpers
function v = try_get(simOut, name)
  try
    v = simOut.get(name);
    v = v(:);
  catch
    v = [];
  end
end

function [t,w,theta,tau_in,tau_b,cpu] = run_model(mdl, solver, fixedStep, b)
  is_fixed = any(strcmp(solver,{'ode1','ode4'}));
  if is_fixed
    set_param(mdl,'Solver',solver,'FixedStep',fixedStep);
  else
    set_param(mdl,'Solver',solver);
  end
  tic;
  out = sim(mdl,'SrcWorkspace','base');
  cpu = toc;
  t = out.tout(:);
  w = out.get('w');
  w = w(:);
  theta = out.get('theta');
  theta = theta(:);
  tau_in = try_get(out,'t_in');
  if isempty(tau_in)
    tau_in = zeros(size(w));
  end
  tau_b = b .* w;
end

function maybe_save(fname, SAVE, OUTDIR)
  if SAVE
    exportgraphics(gcf, fullfile(OUTDIR,fname), 'Resolution',300);
    close(gcf);
  end
end
