function [S0,SR,Y,rf] = alignStruct (S0, S, Rs, noRotFlag)
%function [S0,SR,Y,rf] = alignStruct (S0, S, Rs, noRotFlag)
%
% Based on code by Akhter, Khan, Sheikh, and Kanade:
% "Nonrigid Structure from Motion in Trajectory Domain", NIPS08
% http://cvlab.lums.edu.pk/nrsfm/
%
% Modified by Paulo Gotardo
%
[F,P] = size(S0); F = F/3;

% make shapes zero mean
S0 = S0 - repmat( mean(S0,2), 1, P );
S  = S  - repmat( mean(S ,2), 1, P );

rf = cell(F,1);
if exist('noRotFlag')
    SR = S;
else
    SR = zeros(3*F,P);

    for f = 1:F
        f2 = 2*f-[1 0]; f3 = 3*f-[2 1 0];
    
        %r = [ Rs(f2, :) ; cross(Rs(f2(1),:), Rs(f2(2),:)) ];
        r = Rs(f2, :);
        n = norm(r(1,:));
        r = r / n;
        r = n * [ r ; cross( r(1,:), r(2,:) ) ];
        
        if ( det(r) < 0 ), r(3,:) = -r(3,:); disp('alignStruct() det<0!'), end
    
        % Apply each rotation f to its corresponding 3D shape in frame f
        SR(f3,:) = r * S(f3, :);
        rf{f} = r;
    end
end

% Procrust Alignment: find 3x3 rotation matrix Y
Y = findRotation(S0, SR);
for f = 1:F
    f3 = 3*f-[2 1 0];
    SR(f3,:) = Y * SR(f3,:);
end;

% ----------------------------------------------------------------------------

function [Y] = findRotation(S, Sh)

[F,P] = size(S); F = F / 3;

S1 = zeros(3,F*P);
S2 = zeros(3,F*P);
cols0 = 1:P;
for f = 1:F
    rows = 3*f - [2 1 0];
    cols = cols0 + (f-1)*P; 
    S1(:,cols) = S (rows,:);
    S2(:,cols) = Sh(rows,:);
end;

% This is not really a rotation, but a 3x3 afine alignment
Y = S1 / S2;             
% Y = inv(S2*S2')*S1*S2';

% Now make it a rotation:
[U, D, V] = svd(Y);
Y = U*V';

% ----------------------------------------------------------------------------
