clc; close all; clear all;

m = 0.5;    M = 5;  L = 1;  g = 9.8;

A = [0 1 0 0; (m+M)*g/(M*L) 0 0 0; 0 0 0 1; (-m*g)/M 0 0 0];
B = [0; -1/M*L; 0; 1/M];

eigenVals = eig(A);

rank(ctrb(A, B));

C_block = eye(4);

D_block = zeros(4,1);

desiredEigen = [-1+j -1-j -2+2j -2-2j];  % also the slow eigen values.
fastEigen = [-100+j -100-j -200+2j -200-2j];
    
F = -acker(A,B,desiredEigen);

C = [1 0 0 0; 0 0 1 0];     

D = zeros(2,1);         

K_slow = place(A', C', desiredEigen)';
K_fast = place(A', C', fastEigen)';

A_observer = A - K_slow * C;       B_observer = [B K_slow];
C_observer = eye(4);               D_observer = zeros(4,3);

% sim("StaticFeedback")
sim("Q3_StaticObserverFeedback")

f1=figure(1) ;
set(f1,"position",[1 305 672 500])
subplot(321),plot(tout,xhat( :,1)),title("angle"),grid,
subplot(323),plot(tout,xhat( :,2)),title("derived angle"),grid
subplot(322),plot(tout,xhat( :,3)),title("position"),grid,
subplot(324),plot(tout,xhat( :,4)),title("derived position"),grid
subplot(325),plot(tout,u),title("input u"),grid

f2=figure(2) ;
set(f2,"position",[1 305 672 500])
subplot(321),plot(tout,x( :,1),tout,xhat( :,1),"r"),title("angle K-slow"),grid
subplot(323),plot(tout,x( :,2),tout,xhat( :,2),"r"),title("derived angle K-slow"),grid
subplot(322),plot(tout,x( :,3),tout,xhat( :,3),"r"),title("position K-slow"),grid
subplot(324),plot(tout,x( :,4),tout,xhat( :,4),"r"),title("derived position K-slow"),grid
subplot(325),plot(tout,u),title("input u K_slow"),grid

A_observer = A - K_fast * C;       B_observer = [B K_fast];
C_observer = eye(4);               D_observer = zeros(4,3);

% sim("StaticFeedback")
sim("Q3_StaticObserverFeedback")

f3=figure(3) ;
set(f3,"position",[1 305 672 500])
subplot(321),plot(tout,x( :,1),tout,xhat( :,1),"r"),title("angle K-fast"),grid
subplot(323),plot(tout,x( :,2),tout,xhat( :,2),"r"),title("derived angle K-fast"),grid
subplot(322),plot(tout,x( :,3),tout,xhat( :,3),"r"),title("position K-fast"),grid
subplot(324),plot(tout,x( :,4),tout,xhat( :,4),"r"),title("derived position K-fast"),grid
subplot(325),plot(tout,u),title("input u  K_fast"),grid
