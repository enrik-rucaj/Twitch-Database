#include<iostream>
#include <iomanip>
#include<cstdio>
#include<fstream>
#include<stdlib.h>
#include "dependencies/include/libpq-fe.h"

using namespace std;

#define NOMEDB  "Twitch"
#define HOST  "127.0.0.1"
#define USER  "postgres"
#define PASS  "Ame2257!"
#define PORT  5432

void printQuery(PGresult* res) {
    int numTuple=PQntuples(res); 
    int numcol=PQnfields(res);
    if(numTuple==0)
        cout<<"Nessuna tupla trovata.\n";
    else
    for(int i=0;i<numTuple;++i){
        for(int j=0;j<numcol;++j)
            cout<<std::setw(6)<<PQgetvalue(res,i,j) << "\t"<<std::setw(6) ;
        cout<<endl;
    }
        
    PQclear(res);
    
}

PGresult* eseguiQuery(PGconn* conn, const char* query) {
    PGresult* res = PQexec(conn, query);
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << PQerrorMessage(conn) << endl;
        PQclear(res);
        exit(1);
    }

    return res;
}

int main (int argc, char **argv){
    PGconn* conn;
    char conninfo[250];
    sprintf(conninfo, "user=%s password=%s dbname=%s hostaddr=%s port=%d",
                USER, PASS, NOMEDB, HOST, PORT
    );
    cout<<"Connessione in corso...\n";
    do{
        conn=PQconnectdb(conninfo);
    }while(PQstatus(conn) != CONNECTION_OK);
    cout<<"Connesso\n";

    const char* query[6] = {
        /*Mostrare streamer con più follower e che siano in una società con stabilimento in Giappone*/
        "select Username, numfollower from Streamer where Company in(select PartitaIva from Società where Stato='Japan') order by numfollower desc LIMIT 10 ;",
        /*Streamer che sono stati invitati ad eventi nel 2020*/
        "select Username from Streamer where Username in (select Invitato from ListaInvitati where NomeEvento in (select Nome from Evento where DataEvento between '2020-01-01' and '2020-12-31')And EdizioneEvento in (select Edizione from Evento where DataEvento between '2020-01-01' and '2020-12-31'));",
        /*Mostrare l'utente che ha fatto più donazioni verso un certo streamer*/
        "drop view if exists donatori; Create view donatori as select Username,count(*) as numDon from Donazione where Stream in (select StreamId from Stream where Canale=(select Streamer from Canale where Streamer='%s'))group by Username order by numdon desc;\
        select Username,numDon from donatori LIMIT 1 ;",
        /*Mostrare tutti gli eventi dopo il 2020 e l'invitato con più abbonati*/
        "drop view if exists eventi21 cascade; Create view eventi21 as select Nome,Edizione from Evento where  DataEvento>'2020-12-31';\
         drop view if exists invitati21 cascade; Create view invitati21 as select e.Nome,e.Edizione,Invitato from eventi21 as e join ListaInvitati as li on e.Nome=li.nomeEvento and e.Edizione=li.EdizioneEvento ;\
         drop view if exists mostabb; Create view mostabb as select nome,edizione,max(numabbonati) as pog from Streamer join invitati21 on invitati21.Invitato=Username group by nome,edizione;\
         select Nome,Edizione,Username from mostabb join Streamer on pog=numabbonati;\
         ",
        /*Mostrare tutti i moderatori di un canale che ci sono stati fin dalla creazione di quest'ultima*/
         "select Datacreazione,Username from Moderatori join Canale on Moderatori.Canale='%s' where DataInizio=Canale.Datacreazione;",
        

        /*Mostrare gli inserzionisti presenti in stream che hanno ricevuto più di 5 donazioni e che hanno un numero di views maggiore di 1000*/
        "drop view if exists streams; create view streams as select streamId from Stream join Donazione on Stream.StreamId=Donazione.Stream Where Stream.Numviews>1000 group by streamId Having Count(*)>5;\
        select nomeazienda from Inserzionisti where PartitaIva in (select Inserzionista from ListaAnnunci as l join streams on l.Stream=streams.streamid);"
        
    };

    bool terminato=false;
    PGresult* result;
    while(!terminato){
        cout<<"Seleziona la query da eseguire:\n"
        <<"0. Esci\n"
        <<"1. Mostra tutti i moderatori di un canale che ci sono stati fin dalla creazione di quest'ultima\n"
        <<"2. Mostra i TOP 10 streamer con il maggior numero di follower e che siano in una società giapponese\n"
        <<"3. Mostra streamer che sono stati invitati ad eventi nel 2020\n"
        <<"4. Mostra l'utente che ha fatto il maggior numero di donazioni verso un certo streamer\n"
        <<"5. Mostra tutti gli eventi dopo il 2020 e l'invitato con il maggior numero di abbonati\n"
        <<"6. gli inserzionisti presenti in stream che hanno ricevuto almeno un numero di donazioni maggiore di 5 e che hanno un numero di views maggiore di 1000\n";
        int scelta=-1;
        cin>>scelta;
        char completeQuery[2000];
        switch (scelta)
        {
        case 0:
            terminato=true;
            exit(1);
            break;
        case 2:
            result=eseguiQuery(conn,query[0]);
            printQuery(result);
            break;
        case 3:
            result=eseguiQuery(conn,query[1]);
            printQuery(result);
            break;
        case 4:
            char streamer1[25] ;
            cout<<"Scegliere il nome dello streamer dalla seguente lista:\n";
            result=eseguiQuery(conn,"SELECT Username FROM Streamer");
            printQuery(result);
            cin>>streamer1;
            sprintf(completeQuery, query[2], streamer1);
            result=eseguiQuery(conn,completeQuery);
            printQuery(result);
            break;
        case 5:
            result=eseguiQuery(conn,query[3]);
            printQuery(result);
            break;
        case 1:
            char streamer2[25] ;
            cout<<"Scegliere il nome dello streamer dalla seguente lista:\n";
            result=eseguiQuery(conn,"SELECT Username FROM Streamer");
            printQuery(result);
            cin>>streamer2;
            sprintf(completeQuery, query[4], streamer2);
            result=eseguiQuery(conn,completeQuery);
            printQuery(result);
            break;
        case 6:
            result=eseguiQuery(conn,query[5]);
            printQuery(result);
            break;
        }
        cout<<"Premi Enter";
        fflush(stdin);
        getchar();
    };
    PQfinish(conn);
}

