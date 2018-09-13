disp("***************BEGIN Quiz 6*********************")
clear all
time=[6	12	16	18	11
11	7	12	19	13
16	11	7	10	18
19	20	11	8	22
12	14	21	24	6];
obs_trip=[110	315	30	50	260
40	15	30	20	100
10	5	15	30	20
70	10	150	250	190
90	15	30	40	285];
% step 1
interval_1 = 0;
interval_2 = 0;
interval_3 = 0;
for i = 1:5
    for j = 1:5
        if time(i,j) <= 10
            interval_1 = interval_1 + obs_trip(i,j);
        end
        if time(i,j)>10 && time(i,j)<=15
            interval_2 = interval_2 + obs_trip(i,j);
        end
        if time(i,j)>=15
            interval_3 = interval_3 + obs_trip(i,j);
        end
    end
end
V=eye(5,5);
A=sum(obs_trip);
P=sum(obs_trip,2);
% step 2
for i = 1:5
    for j = 1:5
        V(i,j)=P(i)*A(j)/sum(A);
    end
end
Ratio = zeros(1,3); %set it first for now
F_2d = ones(5,5);
% step 3 iter 2
while any(abs(Ratio-[1,1,1]) > 0.01)
    interval_1e = 0;
    interval_2e = 0;
    interval_3e = 0;
    for i = 1:5
        for j = 1:5
            if time(i,j) <= 10
                interval_1e = interval_1e + V(i,j);
            end
            if time(i,j)>10 && time(i,j)<=15
                interval_2e = interval_2e + V(i,j);
            end
            if time(i,j)>=15
                interval_3e = interval_3e + V(i,j);
            end
        end
    end
    Ratio = [interval_1/interval_1e,interval_2/interval_2e,interval_3/interval_3e];
    for i = 1:5
        for j = 1:5
            if time(i,j) <= 10
                F_2d(i,j) = F_2d(i,j)*Ratio(1);
            end
            if time(i,j)>10 && time(i,j)<=15
                F_2d(i,j) = F_2d(i,j)*Ratio(2);
            end
            if time(i,j)>=15
               F_2d(i,j) = F_2d(i,j)*Ratio(3);
            end
        end
    end
    % step 4
    A=sum(V);
    P=sum(V,2);
    denominator=[1:5];
    for i = 1:5
        denominator(i)=sum(A.*F_2d(i,:),2);
    end
    for i = 1:5
        for j = 1:5
            V(i,j)=P(i)*A(j)*F_2d(i,j)/denominator(i);
        end
    end
    
end
Ratio
disp("Thus we got")
F_2d
disp("or put F in to 1D as")
F_1d=zeros(3,1);
for i = 1:5
        for j = 1:5
            if time(i,j) <= 10
                F_1d(1) = F_2d(i,j);
            end
            if time(i,j)>10 && time(i,j)<=15
                F_1d(2) = F_2d(i,j);
            end
            if time(i,j)>=15
               F_1d(3) = F_2d(i,j);
            end
        end
end
F_1d
disp('We now have F, and need to find Kij')
A_obs=sum(obs_trip);
P_obs=sum(obs_trip,2);
CF = A_obs./A;
RF = P_obs./P;
while or(any(abs(CF-ones(1,5))>0.01),any(abs(RF-ones(1,5))>0.01))
    for j = 1:5
        V(:,j)=V(:,j).*CF(j);
    end
    P=sum(V,2);
    RF = P_obs./P;
    for i = 1:5
        V(i,:)=V(i,:).*RF(i);
    end
    A=sum(V);
    CF = A_obs./A;
end
CF
RF
K=obs_trip./V
disp("minimum value in V")
disp(min(min(V)))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp("CLIBRATION COMPLETE")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp("Mean absolute error ratio")
N = 5;
sigma = 0;
for i = 1:5
        for j = 1:5
            x = abs(V(i,j)-obs_trip(i,j))/V(i,j);
            sigma = sigma+x;
        end
end
err=(1/N^2)*sigma
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp("Use the 2025 expected travel time matrix")
time=[ 8    15    18    24    15
    17     9    14    21    18
    18    14     7    11    20
    21    26    13     9    23
    15    14    21    22     8];
for i = 1:5
    for j = 1:5
        if time(i,j) <= 10
            F_2d(i,j) = F_1d(1);
        end
        if time(i,j)>10 && time(i,j)<=15
            F_2d(i,j) = F_1d(2);
        end
        if time(i,j)>=15
            F_2d(i,j) = F_1d(3);
        end
    end
end
P_exp=[500;400;400;800;500];
A_exp=[400 400	300	500	1000];
for i = 1:5
    denominator(i)=sum(A_exp.*F_2d(i,:).*K(i,:),2);
end
for i = 1:5
        for j = 1:5
            V(i,j)=P_exp(i)*A_exp(j)*F_2d(i,j)*K(i,j)/denominator(i) ;
        end
end
A_est=sum(V);
P_est=sum(V,2);
%Compare Trips
CF = A_exp./A_est;
RF = P_exp./P_est;
while or(any(abs(CF-ones(1,5))>0.01),any(abs(RF-ones(1,5))>0.01))
    for j = 1:5
        V(:,j)=V(:,j).*CF(j);
    end
    P_est=sum(V,2);
    RF = P_exp./P_est;
    for i = 1:5
        V(i,:)=V(i,:).*RF(i);
    end
    A_est=sum(V);
    CF = A_exp./A_est;
end
disp("Therefore 2025 Trip distribution")
V
disp("********************END*************************")