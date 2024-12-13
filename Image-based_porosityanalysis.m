%Code to analyze pore distributions in lemon 
clear; close all; clc;
File_Name='no osmium1.tif'; 
Resolution=0.459; 
N=4; 
A=imread(File_Name);
B=A;
if ndims(A)==3; B=rgb2gray(A); end

level = multithresh(B,N);
C= imquantize(B,level);
RGB1 = label2rgb(B);
imwrite(RGB1,[File_Name(1:end-4) '_Depth Map.png']);

P=zeros(size(C));
for I=1:size(C,1)
    for J=1:size(C,2)
        if C(I,J)==1
            P(I,J)=1;
        end
    end
end
P=1-P;
P=bwmorph(P,'majority',1);

imwrite(P,[File_Name(1:end-4) '_Binary Segmentation.png']);

Conn=8;
[s1,s2]=size(P);
D=-bwdist(P,'cityblock');
B=medfilt2(D,[3 3]);
B=watershed(B,Conn);
Pr=zeros(s1,s2);

for I=1:s1
    for J=1:s2
        if P(I,J)==0 && B(I,J)~=0
            Pr(I,J)=1;
        end
    end
end
Pr=bwareaopen(Pr,9,Conn);

[Pr_L,Pr_n]=bwlabel(Pr,Conn);
RGB2 = label2rgb(Pr_L,'jet','white','shuffle');
imwrite(RGB2,[File_Name(1:end-4) '_Pore Space Segmentation.png']);
V=zeros(Pr_n,1);
for I=1:s1
    for J=1:s2
        if Pr_L(I,J)~=0
            V(Pr_L(I,J))=V(Pr_L(I,J))+1;
        end
    end
end
SP=4*pi*sum(sum(Pr))/(sum(sum(bwperim(Pr,4))))^2;
X=Resolution.*(V./pi).^.5; % Pore radius
Porosity=1-mean(P(:))
Average_Pore_radius=mean(X) % micron
Standard_Deviation_of_Pore_radius=std(X) % micron

figure; 
subplot(2,3,1); imshow(A); title('Original SEM Image');
subplot(2,3,2); imshow(RGB1); title('Depth Map');
subplot(2,3,3); imshow(P); title('Binary Segmentation');
subplot(2,3,4); imshow(RGB2); title('Pore Space Segmentation');
annotation('textbox',[0 .9 .1 .1], 'String', [ 'Porosity = ' num2str(Porosity) ' (fraction)']);
subplot(2,3,5:6); hist(X,25); xlabel('Pore Radius (10^-5)'); ylabel('Frequency'); title('Pore Size Distribution');
set(gcf, 'Position' , get(0, 'Screensize' ));



 