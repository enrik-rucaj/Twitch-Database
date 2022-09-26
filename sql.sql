drop table if exists Streamer cascade;
drop table if exists Canale cascade;
drop table if exists Stream cascade;
drop table if exists Utente cascade;
drop table if exists Followers;
drop table if exists moderatori;
drop table if exists Società cascade;
drop table if exists Inserzionisti cascade;
drop table if exists Donazione cascade;
drop table if exists CreditCard;
drop table if exists Evento cascade;
drop table if exists ListaInvitati cascade;
drop table if exists ListaBannati;
drop table if exists ListaAnnunci;
drop table if exists listaVisioni;

CREATE TABLE Società(
	PartitaIva		char(11) ,
	Nomeazienda	  varchar(50) NOT NULL,
	Stato			    varchar(56) NOT NULL,
	Città			    varchar(85) NOT NULL,
	Cap				    char(5)	NOT NULL,
	Via				    varchar(30)	NOT NULL,
	Civico			  int	NOT NULL,
	PRIMARY KEY(PartitaIva)
);

CREATE TABLE CreditCard(
	Numero			  bigint PRIMARY KEY,
	Circuito		  varchar(20) NOT NULL,
	Intestatario	varchar(20) NOT NULL,
	Datascadenza	date NOT NULL,
	Cvc				    char(3) NOT NULL
);

CREATE TABLE Streamer(
	Username	    varchar(25) PRIMARY KEY,
	oretotali	    int NOT NULL,
	numfollower   int NOT NULL,
	numabbonati   int NOT NULL,
	Company		    char(11),
	FOREIGN KEY(Company) REFERENCES Società(PartitaIva) on update cascade,
	Check(numfollower>=numabbonati)
);

CREATE TABLE Canale(
	Streamer	    varchar(25) PRIMARY KEY,
	Datacreazione date NOT NULL,
	Descrizione		varchar(300),
	FOREIGN KEY(Streamer) references Streamer(Username) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Stream(
	StreamId			int PRIMARY KEY,
	Dataorainizio	timestamp NOT NULL,
	Dataorafine		timestamp,
	Titolo				varchar(50) NOT NULL,
	Numviews			int NOT NULL,
	Categoria			varchar(20) NOT NULL,
	Canale				varchar(25) NOT NULL,
	inlive				boolean NOT NULL,
	FOREIGN KEY(Canale) REFERENCES Canale(Streamer),
	CHECK((Dataorafine IS NOT NULL AND Dataorainizio<Dataorafine AND inlive=false)OR(Dataorafine IS NULL AND inlive=true))
);

CREATE TABLE Utente(
	Username	    varchar(25) PRIMARY KEY,
	Nome		      varchar(20) NOT NULL,
	Cognome		    varchar(20) NOT NULL,
	Email		      varchar(30) NOT NULL,
	Password	    varchar(100)NOT NULL,
	IsBannato     boolean NOT NULL
);

CREATE TABLE Followers(
	Streamer	    varchar(25),
	Utente		    varchar(25),
	IsAbbonato	  boolean NOT NULL,
	dataInizio 	  date,
	dataScadenza  date,
	livello 	    int,
	PRIMARY KEY(Streamer,Utente),
	FOREIGN KEY(Streamer) REFERENCES Streamer(Username) on update cascade on delete cascade,
	FOREIGN KEY (Utente) REFERENCES Utente(Username) on update cascade on delete cascade,
	Check(
				(IsAbbonato=true AND
		 		dataInizio IS NOT NULL AND
				dataScadenza IS NOT NULL AND
				livello IS NOT NULL AND
				dataInizio<dataScadenza)
				or
				(IsAbbonato=false AND
				dataInizio IS NULL AND
				dataScadenza IS NULL AND
				livello IS NULL
				)
		 )
);

CREATE TABLE Moderatori(
	Canale	      varchar(25),
	Username      varchar(25),
	DataInizio    date,
  PRIMARY KEY(Canale,Username),
	FOREIGN KEY(Canale) REFERENCES Canale(Streamer),
	FOREIGN KEY(Username) REFERENCES Utente(Username)
);


CREATE TABLE Inserzionisti(
	PartitaIva		char(11) ,
	Nomeazienda	  varchar(50) NOT NULL,
	Stato			    varchar(56) NOT NULL,
	Città			    varchar(85) NOT NULL,
	Cap				    char(5)	NOT NULL,
	Via				    varchar(30)	NOT NULL,
	Civico			  int	NOT NULL,
	PRIMARY KEY(PartitaIva)
);

CREATE TABLE Donazione(
	Id		        int PRIMARY KEY,
	Username	    varchar(25) NOT NULL,
	Dataora	      timestamp NOT NULL,
	conBits		    boolean NOT NULL,
	QuantitàBits	int,
	QuantitàEuro	float,
	Cc		        bigint,
	Stream		    int NOT NULL,
	FOREIGN KEY(Username) REFERENCES Utente(Username) on update cascade,
	FOREIGN KEY(Cc) REFERENCES CreditCard(Numero) on update cascade,
	FOREIGN KEY(Stream)	REFERENCES Stream(StreamId) on update cascade,
	Check(
			(	
        conBits=false AND
				QuantitàBits IS NULL AND
				QuantitàEuro IS NOT NULL AND
				CC IS NOT NULL
			)
			or
			(
        conBits=true AND
				QuantitàEuro IS NULL AND
				QuantitàBits IS NOT NULL AND
        CC IS NULL
			)
		)
);



CREATE TABLE Evento(
	Nome		      varchar(50),
	Edizione	    varchar(20),
	DataEvento		date NOT NULL,
	PRIMARY KEY(Nome,Edizione)
);

CREATE TABLE ListaInvitati(
	NomeEvento		varchar(50),
	EdizioneEvento varchar(20),
	Invitato	    varchar(25),
	PRIMARY KEY(NomeEvento,EdizioneEvento,Invitato),
	FOREIGN KEY (NomeEvento,EdizioneEvento) REFERENCES Evento(Nome,Edizione),
	FOREIGN KEY(Invitato) REFERENCES Streamer(Username) on update cascade
);

CREATE TABLE ListaBannati(
	Canale		    varchar(25),
	UtenteBannato	varchar(25),
	TempoDiBan	  int,
	DataBan		    date,
	PRIMARY KEY(Canale,UtenteBannato,DataBan),
	FOREIGN KEY(Canale) REFERENCES Canale(Streamer),
	FOREIGN KEY(UtenteBannato) REFERENCES Utente(Username) on update cascade on delete cascade
);

CREATE TABLE ListaAnnunci(
	Inserzionista	char(11),
	Stream        int,
	PRIMARY KEY(Inserzionista,Stream),
	FOREIGN KEY(Inserzionista) REFERENCES Inserzionisti(PartitaIva) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(Stream) REFERENCES Stream(StreamId) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE ListaVisioni(
	Utente        varchar(25),
	Stream        int,
	PRIMARY KEY (Utente,Stream),
	FOREIGN KEY(Utente) REFERENCES Utente(Username),
	FOREIGN KEY(Stream) REFERENCES Stream(StreamId)
);



INSERT INTO Società(PartitaIva,Nomeazienda,Stato,Città,Cap,Via,Civico)VALUES
('14213582394','VShojo','USA','San Francisco','14121','Lombard street',420),
('23213552694','Hololive','Japan','Tokyo','23142','Takeshita street',242);
INSERT INTO Streamer(Username,oretotali,numfollower,numabbonati,Company) VALUES
('shroud',244,10082855,4278,NULL),
('veibae',230,881250,1221,'14213582394'),
('watsonamelia_hololiveen',10,54615,5000,'23213552694'),
('gawrgura',41,3001201,2000,'23213552694'),
('moriCalliope',102,200000,510,'23213552694'),
('takanashikiara',120,600042,5132,'23213552694'),
('Ina',222,142415,942,'23213552694'),
('Kronii',231,312349,3000,'23213552694'),
('Mumei',160,1231252,10023,'23213552694'),
('Sana',65,100200,100,'23213552694'),
('Irys',241,500231,2300,'23213552694'),
('Fauna',92,412321,40000,'23213552694'),
('Bae',140,593041,3520,'23213552694'),
('Pekora',69,14241,323,'23213552694');
INSERT INTO Evento(Nome,Edizione,DataEvento) VALUES
('TwitchCon','2020','2020-06-23'),
('Twitch Rivals-Pubg','3rd','2020-05-22'),
('TwitchCon','2021','2021-06-25');

INSERT INTO ListaInvitati(NomeEvento,EdizioneEvento,Invitato) VALUES
('TwitchCon','2020','shroud'),
('TwitchCon','2020','veibae'),
('Twitch Rivals-Pubg','3rd','shroud'),
('Twitch Rivals-Pubg','3rd','veibae'),
('TwitchCon','2021','shroud'),
('TwitchCon','2021','veibae'),
('TwitchCon','2021','watsonamelia_hololiveen');
INSERT INTO Utente(Username,Nome,Cognome,Email,Password,isBannato) VALUES
('Pufu22','Justin','Giuggiola','giuggiola22@gmail.com','sfawgs','no'),
('riku16','Henry','Ottabo','waifu16@libero.it','tsafsd','no');

INSERT INTO CreditCard(Numero,Circuito,Intestatario,Datascadenza,Cvc) VALUES
(4151835260682891,'VISA','Justin Giuggiola','2023-07-01','291'),
(4151835577709106,'VISA','Henry Ottabo','2026-07-01','512');
INSERT INTO Canale(Streamer,Datacreazione,Descrizione)VALUES
('shroud','2014-09-23','BIG GAMER'),
('veibae','2020-06-03','Vtuber from hell'),
('watsonamelia_hololiveen','2022-04-01','Time traveler'),
('gawrgura','2022-03-12','Shark'),
('moriCalliope','2022-02-24','Reaper'),
('takanashikiara','2021-12-23','Phoenix'),
('Ina','2022-04-03','Tako'),
('Kronii','2021-08-31','Time warden'),
('Mumei','2022-05-22','Owl'),
('Sana','2021-10-29','Space protector'),
('Irys','2022-02-15','Hope'),
('Fauna','2021-12-12','Mother nature'),
('Bae','2022-03-12','Chaos rat'),
('Pekora','2020-04-21','Konpeko konpeko konpeko');

INSERT INTO Moderatori(Canale,Username,DataInizio) VALUES
('watsonamelia_hololiveen','Pufu22','2022-04-01'),
('watsonamelia_hololiveen','riku16','2022-05-01');
INSERT INTO Stream(StreamId,Dataorainizio,Dataorafine,Titolo,Numviews,Categoria,Canale,inlive) VALUES
('23','2020-05-21 07:02:01','2020-05-22 16:02:01','Wow',2300,'just chatting','shroud','No');
INSERT INTO Donazione(id,Username,Dataora,conBits,QuantitàBits,QuantitàEuro,Cc,Stream) VALUES
(92,'Pufu22','2020-05-22 08:02:01','No',NULL,'45.23',4151835260682891,23),
(31,'Pufu22','2020-05-22 08:20:01','No',NULL,'12.43',4151835260682891,23),
(22,'Pufu22','2020-05-22 10:40:06','No',NULL,'32.23',4151835260682891,23),
(45,'riku16','2020-05-22 08:30:01','No',NULL,'22.00',4151835577709106,23),
(69,'riku16','2020-05-22 08:31:01','No',NULL,'22.00',4151835577709106,23),
(420,'riku16','2020-05-22 08:32:01','No',NULL,'22.00',4151835577709106,23);
INSERT INTO Inserzionisti(PartitaIva,Nomeazienda,Stato,Città,Cap,Via,Civico) VALUES
('23149320489','Colgate','USA','Los Angeles','42321','Boulevard of Dreams',69);
INSERT INTO ListaAnnunci(Inserzionista,Stream)VALUES
('23149320489',23);


INSERT INTO Società (partitaIva,nomeAzienda,stato,città,cap,via,civico)
VALUES
  ('29358990520','Ut Dolor LLC','Spain','Valencia','3916','Ap #872-9868 Arcu. Rd.',149),
  ('42391270503','Magna Nec LLC','Pakistan','Lahore','22030','P.O. Box 787, 4072 Egestas Rd.',105),
  ('48595490524','Diam Ltd','Ukraine','Kiev','PL82','65675 Molestie Ave',173),
  ('42230170427','Turpis In Condimentum Incorporated','Sweden','Uppsala','9438','184, 2781 Tellus Street',91),
  ('32510460135','Id Industries','Norway','Oslo','96839','1062 Risus Road',42),
  ('45711590799','Vel Sapien Corporation','Germany','Berlin','2996','Ap #877-1452 Quis Rd.',267),
  ('43123810244','At Egestas Corp.','Norway','Bergen','3438','6275 Non Av.',170),
  ('16463980405','Malesuada Augue Inc.','Turkey','Ankara','71336','Ap #754-5737 Donec St.',5),
  ('38310780010','Eget Consulting','Mexico','Mexico City','82326','Ap #653-8380 Vitae St.',245),
  ('18507210260','Orci Quis Corp.','Peru','Lima','4531','8451 Ornare. Road',247);
  
INSERT INTO Streamer (username,oreTotali,numFollower,numAbbonati,company)
VALUES
  ('Gaules',176,446428,170616,'29358990520'),
  ('MontanaBlack88',58,785937,137644,'42391270503'),
  ('MOONMOON',80,4038410,134681,'48595490524'),
  ('Yassuo',270,1308558,156118,'42230170427'),
  ('YoDa',60,4479670,83021,'32510460135'),
  ('NICKMERKS',282,2413037,80667,'45711590799'),
  ('Castro_1021',294,2274870,181006,'43123810244'),
  ('AdmiralBahroo',217,2697073,142764,'16463980405'),
  ('RiotGames',240,1012118,162814,'38310780010'),
  ('DrDisrespect',293,980205,183682,'18507210260');
  
INSERT INTO Canale (Streamer,dataCreazione,descrizione)
VALUES
  ('Gaules','2021-10-30','Playing the drums or guitar.'),
  ('MontanaBlack88','2021-12-28','Love First'),
  ('MOONMOON','2023-04-21','hey guys check us out irl live from the land of the rising snes'),
  ('Yassuo','2021-11-03','Working out'),
  ('YoDa','2022-08-31','Keeping up with streetwear fashion.'),
  ('NICKMERKS','2021-12-10','Just a man on a mission.'),
  ('Castro_1021','2022-04-13','Stay Connected.'),
  ('AdmiralBahroo','2022-01-26','Protector of all that is cute and fluffy'),
  ('RiotGames','2023-01-07','Collecting daggers, watching anime and cooking.'),
  ('DrDisrespect','2023-05-04','Watching wrestling and watching anime');

INSERT INTO Stream (streamId,titolo,dataOraInizio,dataOraFine,numViews,categoria,inLive,canale)
VALUES
  (1,'Wagers time','2021-11-30 06:48:19','2022-01-19 18:15:01',22347,'just chatting','No','Gaules'),
  (2,'TLOU part 1& 2','2022-05-23 22:51:01','2022-06-10 03:48:50',178483,'art','No','MontanaBlack88'),
  (3,'20k GTD','2021-06-21 16:23:54',NULL,168600,'podcast','Yes','MOONMOON'),
  (4,'Looking for molly','2022-05-07 01:17:10','2022-09-07 16:38:31',84638,'fortnite','No','YoDa'),
  (5,'Fifa in post finale','2021-07-22 01:46:50','2022-07-30 05:41:20',99855,'minecraft','No','NICKMERKS'),
  (6,'Ranked on RollerChampions','2022-05-18 05:21:33',NULL,20944,'sport','Yes','Castro_1021'),
  (7,'Witchy Screams','2022-12-23 05:34:55','2023-01-25 11:56:00',185027,'pokemon','NO','AdmiralBahroo'),
  (8,'MomoCon 2022','2021-05-22 19:11:52','2023-04-18 00:26:26',164662,'just chatting','No','RiotGames'),
  (9,'Push660','2023-04-30 13:09:11',NULL,40962,'podcast','Yes','DrDisrespect'),
  (10,'Checking out VRising','2022-03-12 18:06:32',NULL,2591,'sport','Yes','DrDisrespect');
  
INSERT INTO Utente (username,nome,cognome,email,password,isBannato)
VALUES
  ('SteFro','Stella','Frost','ac@google.couk','laoreet','Yes'),
  ('TyeTan','Tyrone','Tanner','felis@google.couk','Aliquam','No'),
  ('LauPit','Laura','Pittman','eget.varius.ultrices@yahoo.ca','morbi','No'),
  ('HayGom','Hayes','Gomez','faucibus.ut@protonmail.edu','Pellentesque','No'),
  ('XenHen','Xenos','Hendricks','penatibus.et@icloud.com','adipiscing,','No'),
  ('MarHod','Mary','Hodges','diam.proin.dolor@hotmail.net','imperdiet,','Yes'),
  ('AnBuck','Anne','Buckley','ornare.egestas@protonmail.edu','odio','No'),
  ('BoRich','Bo','Richardson','sed.sem@aol.net','Donec','No'),
  ('NorSan','Nora','Sandoval','purus@outlook.org','nec,','No'),
  ('JaquCl','Jaquelyn','Cleveland','sed.eget@protonmail.net','aliquam','No');
  
INSERT INTO Followers (streamer,utente,isAbbonato,dataInizio,dataScadenza,livello)
VALUES
  ('Gaules','SteFro','Yes','2022-01-05','2022-02-05',2),
  ('Yassuo','JaquCl','Yes','2022-06-21','2022-07-21',2),
  ('DrDisrespect','NorSan','Yes','2022-05-16','2022-06-16',2),
  ('Castro_1021','MarHod','Yes','2022-12-23','2023-01-23',2),
  ('MOONMOON','NorSan','No',NULL,NULL,NULL),
  ('RiotGames','LauPit','No',NULL,NULL,NULL),
  ('YoDa','SteFro','No',NULL,NULL,NULL),
  ('NICKMERKS','BoRich','Yes','2021-09-01','2021-10-01',3),
  ('YoDa','HayGom','No',NULL,NULL,NULL),
  ('DrDisrespect','AnBuck','Yes','2022-02-11','2022-03-11',3);
  
INSERT INTO Moderatori (username,dataInizio,canale)
VALUES
  ('SteFro','2021-05-30','Gaules'),
  ('TyeTan','2022-03-23','Gaules'),
  ('BoRich','2022-01-02','MOONMOON'),
  ('JaquCl','2021-11-30','NICKMERKS'),
  ('AnBuck','2021-11-27','RiotGames'),
  ('HayGom','2022-03-02','DrDisrespect'),
  ('LauPit','2022-04-24','MOONMOON'),
  ('LauPit','2021-07-28','RiotGames'),
  ('SteFro','2021-09-27','YoDa'),
  ('SteFro','2022-01-24','Castro_1021');
  

INSERT INTO Inserzionisti (partitaIva,nomeAzienda,stato,città,cap,via,civico)
VALUES
  ('44407030525','Cakewalk','Brazil','Brasilia','51258','694-8296 Mollis. Ave',174),
  ('19265070888','Finale','Australia','Sydney','78188','755-9318 Sed Ave',240),
  ('55605670987','Borland','Netherlands','Amsterdam','83786','993-4682 Dignissim Rd.',226),
  ('61358240705','Ritemed','Philippines','Manila','29828','529-8027 Dolor Road',53),
  ('65004110709','Chami','Australia','Melbourne','22847','326-6092 Dignissim St.',217),
  ('38677780611','Yahoo','Ireland','Dublin','83244','300-7175 In, St.',257),
  ('36583050731','Microsoft','Chile','Valparaiso','55136','357-7961 In, Rd.',157),
  ('23249520091','Adobe','Sweden','Uppsala','72885','Ap #265-5597 Tellus Street',44),
  ('66703431214','Lego','Russia','Moscow','51537','Ap #513-6713 Non Avenue',279),
  ('75113400727','Ikea','Ukraine','Kiev','43134','1824 Vulputate, St.',73);
  
  INSERT INTO CreditCard (numero,dataScadenza,cvc,intestatario,circuito)
VALUES
  (5485537535571785,'2023-06-17','654','Mario Draghi','Visa'),
  (4916346274326735,'2023-12-31','812','Giorgia Meloni','Visa'),
  (4532842146444460,'2024-05-27','700','Maria Gianbattista','Visa'),
  (4321722766352778,'2023-11-06','276','Marco Salvini','MasterCard'),
  (4485888964833,'2024-04-02','200','Franco Berlusconi','MasterCard'),
  (5279273271316553,'2023-12-16','928','Erica Rossi','MasterCard'),
  (511326524822636,'2023-07-28','795','Federico Bianchi','Visa'),
  (4539272864759,'2023-11-18','643','Ernesto Pesce','Visa'),
  (5479732975413857,'2023-09-16','800','Giuseppe Fucile','MasterCard'),
  (5238543731523885,'2024-03-23','810','Elena Franchi','MasterCard');
INSERT INTO Donazione (Id,username,dataOra,conBits,quantitàBits,quantitàEuro,stream,cc)
VALUES
  (1,'AnBuck','2022-05-23 07:30:25','No',NULL,25.88,1,5485537535571785),
  (2,'SteFro','2022-04-17 14:54:09','No',NULL,41.75,2,4916346274326735),
  (3,'AnBuck','2021-09-25 02:55:26','Yes',1250,NULL,2,NULL),
  (4,'BoRich','2021-06-30 23:23:48','Yes',860,NULL,7,NULL),
  (5,'MarHod','2022-03-07 13:33:06','No',NULL,21,7,5279273271316553),
  (6,'NorSan','2021-10-04 05:33:57','No',NULL,223,8,5279273271316553),
  (7,'AnBuck','2021-07-22 17:21:50','Yes',3718,NULL,5,NULL),
  (8,'TyeTan','2021-07-22 23:36:53','Yes',3981,NULL,5,NULL),
  (9,'LauPit','2022-02-08 17:24:43','No',NULL,14.64,8,5479732975413857),
  (10,'LauPit','2022-04-15 17:07:52','No',NULL,94.43,3,5238543731523885),
  (11,'Pufu22','2021-07-22 17:21:50','No',NULL,10,5,4151835260682891),
  (12,'Pufu22','2021-07-22 17:22:50','No',NULL,10,5,4151835260682891),
  (13,'Pufu22','2021-07-22 17:24:50','No',NULL,10,5,4151835260682891),
  (14,'Pufu22','2021-07-22 17:26:50','No',NULL,10,5,4151835260682891);
  

  
INSERT INTO Evento (nome,edizione,dataEvento)
VALUES
  ('eSport','Minecraft','2022-04-14'),
  ('eSport','Fifa','2023-05-21'),
  ('eSport','BrawlStars','2021-05-30'),
  ('eSport','Tekken','2022-06-24'),
  ('MusicContest','ItalyEdition','2022-07-04'),
  ('eSport','Fortnite','2022-09-19'),
  ('eSport','WWE','2022-08-01'),
  ('MusicContest','UkraineEdition','2021-06-04'),
  ('MusicContest','BelgiumEdition','2022-12-09'),
  ('MusicContest','UkEdition','2022-07-24');
  
INSERT INTO ListaInvitati (nomeEvento,edizioneEvento,Invitato)
VALUES
  ('eSport','Fortnite','Gaules'),
  ('eSport','Fortnite','YoDa'),
  ('MusicContest','UkraineEdition','MOONMOON'),
  ('MusicContest','BelgiumEdition','MontanaBlack88'),
  ('eSport','WWE','Yassuo'),
  ('eSport','Fifa','Castro_1021'),
  ('eSport','BrawlStars','DrDisrespect'),
  ('MusicContest','ItalyEdition','NICKMERKS'),
  ('MusicContest','ItalyEdition','MOONMOON'),
  ('eSport','BrawlStars','RiotGames');

INSERT INTO ListaBannati (utentebannato,canale,tempoDiBan,dataBan)
VALUES
  ('SteFro','MOONMOON',56,'2021-07-25'),
  ('MarHod','Gaules',60,'2021-12-12'),
  ('SteFro','Yassuo',26,'2021-10-05'),
  ('MarHod','YoDa',21,'2022-01-09'),
  ('MarHod','Castro_1021',35,'2022-01-28'),
  ('SteFro','NICKMERKS',49,'2021-11-14'),
  ('MarHod','NICKMERKS',43,'2021-06-18'),
  ('SteFro','DrDisrespect',10,'2022-01-02'),
  ('SteFro','RiotGames',13,'2021-12-18'),
  ('SteFro','AdmiralBahroo',59,'2021-07-28');

INSERT INTO ListaAnnunci (inserzionista,stream)
VALUES
  ('44407030525',7),
  ('55605670987',8),
  ('55605670987',3),
  ('38677780611',5),
  ('61358240705',1),
  ('36583050731',2),
  ('66703431214',7),
  ('61358240705',5),
  ('23249520091',6),
  ('75113400727',8);

INSERT INTO ListaVisioni (utente,stream)
VALUES
  ('SteFro',1),
  ('TyeTan',2),
  ('NorSan',8),
  ('LauPit',3),
  ('AnBuck',7),
  ('XenHen',9),
  ('MarHod',7),
  ('XenHen',5),
  ('AnBuck',3),
  ('BoRich',2);
  
/*Query1: Mostrare la top 10 degli streamer con più follower e che siano affiliati con una società con stabilimento in Giappone.*/
select Username, numfollower 
from Streamer 
where Company in(select PartitaIva 
                 from Società 
                 where Stato='Japan') 
order by numfollower desc LIMIT 10 ;

/*Query2: Mostrare tutti i moderatori di un canale che ci sono stati fin dalla creazione di quest’ultima.*/
select dataCreazione, username 
from Moderatori join Canale on Moderatori.Canale='watsonamelia_hololiveen' 
where dataInizio=Canale.dataCreazione;

/*Query3: Stampare tutti i streamer che sono stati invitati negli eventi del 2020.*/
select username 
from Streamer 
where username in (select invitato 
                   from ListaInvitati 
                   where nomeEvento in (select nome 
                                        from Evento 
                                        where dataEvento between '2020-01-01' and '2020-12-31')
                         And edizioneEvento in (select edizione 
                                                from Evento 
                                                where dataEvento between '2020-01-01' and '2020-12-31'));

/*Query4: Mostrare l’utente che ha fatto più donazioni a un certo streamer.*/
drop view if exists donatori; 
Create view donatori as 
select username, count(*) as numDon 
from Donazione 
where stream in (select streamId 
                 from Stream 
                 where canale=(select streamer from Canale where streamer='Gaules'))
group by username 
order by numdon desc;
 
select username, numDon 
from donatori LIMIT 1;

/*Query5: Stampare gli inserzionisti presenti in quelle stream dove ci sono almeno 5 donazioni e hanno un numero di visualizzazioni maggiore di 1000.*/
drop view if exists streams; 
create view streams as 
select streamId 
from Stream join Donazione on Stream.streamId=Donazione.stream 
where Stream.numViews>1000 
group by streamId 
having Count(*)>5;
 
select nomeAzienda 
from Inserzionisti 
where partitaIva in (select inserzionista 
                     from ListaAnnunci as l join streams on l.Stream=streams.streamid);

/*Query6: Mostrare tutti gli eventi dopo il 2020 e di ciascun evento l’invitato con più abbonati.*/
drop view if exists eventi21 cascade; 
Create view eventi21 as 
select Nome,Edizione 
from Evento 
where  DataEvento>'2020-12-31';

drop view if exists invitati21 cascade; 
Create view invitati21 as 
select e.Nome,e.Edizione,Invitato 
from eventi21 as e join ListaInvitati as li on e.Nome=li.nomeEvento and e.Edizione=li.EdizioneEvento;

drop view if exists mostabb; 
Create view mostabb as 
select nome,edizione,max(numabbonati) as pog 
from Streamer join invitati21 on invitati21.Invitato=Username 
group by nome,edizione;

select Nome,Edizione,Username 
from mostabb join Streamer on pog=numabbonati;
