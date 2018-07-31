function [X_inv,Y_inv,Z_inv] =  VisualizeIDCT( IDCTcoefficients,NumInv,show )
% Visualize the DCT coefficient by padding and plot the IDCT

X_dct = IDCTcoefficients(1:1:8);
Y_dct = IDCTcoefficients(9:1:16);
Z_dct = IDCTcoefficients(17:1:24);
X_dct(8+1:NumInv) = 0; % 30 here is the number in the SfM program
Y_dct(8+1:NumInv) = 0;
Z_dct(8+1:NumInv) = 0;
X_inv = idct(X_dct);
Y_inv = idct(Y_dct);
Z_inv = idct(Z_dct);

if show
    plot3(X_inv,Y_inv,Z_inv,'*');axis ij;grid on;
    xlabel('x');
    ylabel('y');
    zlabel('z');
end

end

