function characters = LicPlateRec(character_image)
% µ÷ÓÃº¯Êırecognise Ê¶±ğ×Ö·û£¬·µ»Ø³µÅÆ×Ö·û´®

characters = '';
lib1 = '¾©½ò¼½½úÃÉÁÉ¼ªºÚ»¦ËÕÕãÍîÃö¸ÓÂ³Ô¥¶õÏæÔÁ¹ğÇíÓå´¨¹óÔÆ²ØÉÂ¸ÊÇàÄşĞÂ';
lib2 = '1234567890ABCDEFGHJKLMNPQRSTUVWXYZ';

temp_char = character_image{1};
temp_char = temp_char(:)';
load('hanzi_theta1.mat');
load('hanzi_theta2.mat');
characters = strcat(characters, recognise(hanzi_theta1, hanzi_theta2, temp_char, lib1));

load('theta1.mat');
load('theta2.mat');
for i = 2:7
    temp_char = character_image{i};
    temp_char = temp_char(:)';
    characters = strcat(characters, recognise(Theta1, Theta2, temp_char, lib2));
end
end
