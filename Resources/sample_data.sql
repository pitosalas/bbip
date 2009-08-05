insert into zguide (z_ent, z_opt, zname, ziconname) values (3, 1, 'People', '001');
insert into zguide (z_ent, z_opt, zname, ziconname) values (3, 1, 'News', '002');

insert into zfeed (z_ent, z_opt, zname, zurl) values (2, 1, 'noizZze', 'http://blog.noizeramp.com/feed/');
insert into zfeed (z_ent, z_opt, zname, zurl) values (2, 1, 'Pito''s Blog', 'http://www.salas.com/feed/');
insert into zfeed (z_ent, z_opt, zname, zurl) values (2, 1, 'Exler', 'http://exler.ru/blog/blog.xml');

insert into z_2guides values (1, 1);
insert into z_2guides values (2, 1);
insert into z_2guides values (3, 2);

insert into zarticle (z_ent, z_opt, zread, zfeed, zpubdate, ztitle, zurl, zbody) values (1, 1, 0, 1, 1249461900, 'NR Before', 'http://blog.noizeramp.com/1', '1');
insert into zarticle (z_ent, z_opt, zread, zfeed, zpubdate, ztitle, zurl, zbody) values (1, 1, 0, 1, 1249461901, 'NR After', 'http://blog.noizeramp.com/2', '2');
insert into zarticle (z_ent, z_opt, zread, zfeed, zpubdate, ztitle, zurl, zbody) values (1, 1, 0, 2, 1249461905, 'Pito After', 'http://salas.com/3', '3');
insert into zarticle (z_ent, z_opt, zread, zfeed, zpubdate, ztitle, zurl, zbody) values (1, 1, 0, 3, 1249461904, 'Exler After', 'http://exler.ru/4', '4');

update z_primarykey set z_max=4 where z_ent=1;
update z_primarykey set z_max=3 where z_ent=2;
update z_primarykey set z_max=2 where z_ent=3;
