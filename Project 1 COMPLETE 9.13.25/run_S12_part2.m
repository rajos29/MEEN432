
clear; clc; close all;

% base params
J1=100; 
b1=1; 
J2=1; 
b2=1;
k_list=[10 100 1000];
A_list=[1 100];
useStep=1; 
amp=1; 
freq=5; 
Tf=25;

% ICs
w01=0; 
theta01=0; 
w02=0; 
theta02=0;


mdl='part2';                      

% push to base
vars = {
 'J1',J1; 'b1',b1; 'J2',J2; 'b2',b2;
 'useStep',useStep; 'amp',amp; 'freq',freq; 'Tf',Tf;
 'w01',w01; 'theta01',theta01; 'w02',w02; 'theta02',theta02;
 'w0',w01; 'theta0',theta01; 'J',J1; 'b',b1
};
for i=1:size(vars,1), assignin('base',vars{i,1},vars{i,2}); end

load_system(mdl);
set_param(mdl,'StopTime',num2str(Tf));

fixed_solvers={'ode1','ode4'}; fixed_dts={'0.1','1'};
var_solvers={'ode45'};

rows=strings(0,1); CPU1=[]; CPU2=[]; CPU3=[];

for Ai=1:numel(A_list)
  A=A_list(Ai); assignin('base','A',A);
  for kk=1:numel(k_list)
    k=k_list(kk); assignin('base','k',k);

    % variable-step
    for s=1:numel(var_solvers)
      solver = var_solvers{s}; dt = '';
      case_str = sprintf('A=%g  k=%g  | %s',A,k,solver);
      try
        CPU1(end+1,1) = time_option(mdl,solver,dt,[1 0 0]);   % Opt1_Flex
        CPU2(end+1,1) = time_option(mdl,solver,dt,[0 1 0]);   % Opt2_Lumped
        CPU3(end+1,1) = time_option(mdl,solver,dt,[0 0 1]);   % Opt3_Integrated
        rows(end+1,1)=case_str;
      catch ME
        warning("Skipped case: %s\n%s",case_str,ME.message);
      end
    end

    % fixed-step
    for s=1:numel(fixed_solvers)
      for d=1:numel(fixed_dts)
        solver = fixed_solvers{s}; dt = fixed_dts{d};
        case_str = sprintf('A=%g  k=%g  | %s dt=%s',A,k,solver,dt);
        try
          CPU1(end+1,1) = time_option(mdl,solver,dt,[1 0 0]);
          CPU2(end+1,1) = time_option(mdl,solver,dt,[0 1 0]);
          CPU3(end+1,1) = time_option(mdl,solver,dt,[0 0 1]);
          rows(end+1,1)=case_str;
        catch ME
          warning("Skipped case: %s\n%s",case_str,ME.message);
        end
      end
    end

    % overlay (enable all, show ode45)
    set_opts(mdl,[1 1 1]);
    [t,O] = run_capture(mdl,show_key,'',{'w1_flex','w2_flex','w_lumped','w_int'});
    figure('Name',sprintf('A=%g, k=%g',A,k)); hold on; grid on;
    plot(t,O.w1,'r-','DisplayName','Opt1 \omega_1');
    plot(t,O.w2,'m--','DisplayName','Opt1 \omega_2');
    plot(t,O.wL,'b-.','DisplayName','Opt2 \omega');
    plot(t,O.wS2,'g:','DisplayName','Opt3 \omega');
    xlabel('t [s]'); ylabel('\omega [rad/s]'); legend('Location','best');
  end
end


n = min([numel(rows),numel(CPU1),numel(CPU2),numel(CPU3)]);
T = table(rows(1:n),CPU1(1:n),CPU2(1:n),CPU3(1:n), ...
          'VariableNames',{'case','cpu_opt1','cpu_opt2','cpu_opt3'});
disp(T);
if n < numel(rows)
  warning('Printed %d rows. Skipped %d due to errors.', n, numel(rows)-n);
end

% helpers
function cpu = time_option(mdl,solver,fixedStep,mask)
  set_opts(mdl,mask);
  [~,~,cpu] = run_once(mdl,solver,fixedStep);
end

function set_opts(mdl,mask)
  
  subs = {[mdl '/Opt1_Flex'],[mdl '/Opt2_Lumped'],[mdl '/Opt3_Integrated']};
  for j=1:3
    if mask(j)==1
      set_param(subs{j},'Commented','off');
    else
      set_param(subs{j},'Commented','on');
    end
  end
end

function [t,out,cpu]=run_once(mdl,solver,fixedStep)
  if any(strcmp(solver,{'ode1','ode4'}))
    set_param(mdl,'SolverType','Fixed-step','Solver',solver,'FixedStep',fixedStep);
  else
    set_param(mdl,'SolverType','Variable-step','Solver',solver);
  end
  tic; S=sim(mdl,'SrcWorkspace','base','ReturnWorkspaceOutputs','on'); cpu=toc;
  t = S.tout; out = struct();
end

function [t,O]=run_capture(mdl,solver,fixedStep,need)
  if any(strcmp(solver,{'ode1','ode4'}))
    set_param(mdl,'SolverType','Fixed-step','Solver',solver,'FixedStep',fixedStep);
  else
    set_param(mdl,'SolverType','Variable-step','Solver',solver);
  end
  S=sim(mdl,'SrcWorkspace','base','ReturnWorkspaceOutputs','on');

  have=S.who;
  for i=1:numel(need)
    assert(ismember(need{i},have), "Missing '%s'. Exported: %s", need{i}, strjoin(have,', '));
  end

  [w1,t1]=vec(S,'w1_flex',S.tout);
  [w2,t2]=vec(S,'w2_flex',S.tout);
  [wL,tL]=vec(S,'w_lumped',S.tout);
  [wS,tS]=vec(S,'w_int',S.tout);

  if ~isequal(t2,t1), w2 = interp1(t2,w2,t1,'linear','extrap'); end
  if ~isequal(tL,t1), wL = interp1(tL,wL,t1,'linear','extrap'); end
  if ~isequal(tS,t1), wS = interp1(tS,wS,t1,'linear','extrap'); end

  t=t1(:);
  O.w1=w1(:); O.w2=w2(:); O.wL=wL(:); O.wS2=wS(:);
end

function [y,t]=vec(S,name,tref)
  x=S.get(name);
  if isa(x,'timeseries'), y=x.Data; t=x.Time; else, y=x; t=tref; end
end
