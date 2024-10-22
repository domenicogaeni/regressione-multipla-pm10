%% REGRESSIONE MULTIPLA - GRUPPO LISBONA
% Componenti del gruppo: Gaeni Domenico (matricola: 1065107) e Palazzi Fabio (matricola: 1066365).
% Abbiamo scelto di analizzare il pm10 perchè si tratta di un'inquinante
% molto pericoloso per la salute dell'uomo e vogliamo estrapolare un modello
% che ci permetta di definire al meglio questo inquinante.
%%%

%% Caricamento dati
load('G19.mat')

%% Ispezione del dataset
summary(tG)

%% Analisi dei valori di PM10 nella stazione di MANTOVA e BERGAMO
grpstats(tG,'ARPA_AQ_cod_staz_tG1',{'mean','std','min','max'},'DataVars',{'PM10_tG1'})
grpstats(tG,'ARPA_AQ_cod_staz_BG',{'mean','std','min','max'},'DataVars',{'PM10_BG'})
% da una prima analisi dei valori del pm10 si può osservare che la media è
% più alta nella stazione di Mantova rispetto a quella unica di Bergamo.

%% Analizziamo il pm10 in funzione dei singoli regressori. 
% Così facendo ci facciamo un'idea di come i singoli regressori influenzano
% la variabile risposta PM10.
% Temperatura:
y = tG.PM10_tG1;
x = tG.Temperatura_tG1;
scatter(x,y,'filled')
title('Temperatura e PM10')
xlabel('Temperatura: °')
ylabel('PM10: mug/m^3')
lsline

% Pioggia
y = tG.PM10_tG1;
x = tG.Pioggia_cum_tG1;
scatter(x,y,'filled')
title('Pioggia e PM10')
xlabel('Pioggia: mm')
ylabel('PM10: mug/m^3')
lsline

% Umidità
y = tG.PM10_tG1;
x = tG.Umidita_relativa_tG1;
scatter(x,y,'filled')
title('Umidità e PM10')
xlabel('Umidità: %')
ylabel('PM10: mug/m^3')
lsline

% Ozono
x = tG.O3_tG1;
scatter(x,y,'filled')
title('Ozono e PM10')
xlabel('Ozono: mug/m^3')
ylabel('PM10: mug/m^3')
lsline

% Ossidi Azoto
x = tG.NOx_tG1;
scatter(x,y,'filled')
title('Ossidi Azoto e PM10')
xlabel('Ossidi Azoto: mug/m^3')
ylabel('PM10: mug/m^3')
lsline

% Biossido di azoto
x = tG.NO2_tG1
scatter(x,y,'filled')
title('Biossido azoto e PM10')
xlabel('Biossido Azoto: mug/m^3')
ylabel('PM10: mug/m^3')
lsline

%% Regressione lineare multipla per la stazione di MANTOVA.
data = tG(:,{'Temperatura_tG1','Pioggia_cum_tG1','Umidita_relativa_tG1','O3_tG1', 'NOx_tG1', 'NO2_tG1', 'PM10_tG1'})
data.Properties.VariableNames = {'Temp','Pioggia','Umid','Ozono','Ossidi_azoto', 'Biossido_azoto', 'PM10'};

% 1° studio: consideriamo tutti i regressori.
m1 = fitlm(data,'ResponseVar','PM10','PredictorVars',{'Temp','Pioggia', 'Umid','Ozono','Ossidi_azoto', 'Biossido_azoto'})
% dall'analisi della fitlm si può osservare che si ha un R2_corretto=0.626
% e che la Temperatura e Ozono hanno un p-value alto (> 0.10), quindi 
% significa che si accetta l'ipotesi nulla (H0: beta_i=0). Si procede non
% considerando la temperatura (il regressore con il p-value più alto).

% 2° studio: senza temperatura.
m2 = fitlm(data,'ResponseVar','PM10','PredictorVars',{'Pioggia', 'Umid','Ozono','Ossidi_azoto', 'Biossido_azoto'})
% dall'analisi di questo secondo tetativo si osserva R2_corretto = 0.628
% (leggermente più altro rispetto al 1° studio) e che il p-Value degli 
% ossidi di azoto > 0.10, per cui si accetta l'ipotesi nulla. Facciamo un 
% terzo studio ignorando anche gli ossidi di azoto dal modello.

% 3° studio: senza ossidi azoto.
m3 = fitlm(data,'ResponseVar','PM10','PredictorVars',{'Pioggia','Umid', 'Ozono' , 'Biossido_azoto'})
% Analizzando l'output si ha che il p-value dell'ozono > 0,10 per cui
% si prova ad eliminare anche questo regressore dal modello. Inoltre si ha
% che R2_corretto = 0.626.

% 4° studio: senza ozono.
m4 = fitlm(data,'ResponseVar','PM10','PredictorVars',{'Pioggia','Umid', 'Biossido_azoto'})
% Analizzando l'output si ha che il p-value dell'umidità > 0,10 per cui
% si prova ad eliminare anche questo regressore dal modello. Inoltre si ha
% che R2_corretto = 0.623.

% 5° studio: senza umidità.
m5 = fitlm(data,'ResponseVar','PM10','PredictorVars',{'Pioggia', 'Biossido_azoto'})
% Analizzando l'output si ha che tutti i regressori sono significativi,
% cioè con un pValue << 0,10. Inoltre R2_corretto = 0.62 non molto diverso 
% da quello del 1° studio. 

% Proviamo a considerare nello studio 5 anche gli ossidi di azoto perchè
% riteniamo che siano collegati in qualche modo al biossido di azoto.
% 6° studio: studio 5 + azoto.
m6 = fitlm(data,'ResponseVar','PM10','PredictorVars',{'Pioggia', 'Ossidi_azoto', 'Biossido_azoto'})
% Si ottiene che il pValue dell'azoto ora è < 0.10. R2_corretto è 0.625
% Per cui si può concludere che i regressori che influenzano il modello
% sono la pioggia, gli ossidi di azoto e il biossido di azoto.
% Si ha che il 62.5% della variabilità complessiva di PM10 è spiegato dalla
% relazione lineare con la pioggia, ossidi di azoto e e biossido di azoto.

% Rappresentazione grafica del 6° studio.
plot(m6)
title('Stazione di Mantova - PM10')

% Analisi dei residui
resm6 = m6.Residuals.Raw
plot(resm6)
yline(0,'r','LineWidth',3)
yline(mean(resm6),'b','LineWidth',2)
title('Analisi dei residui - Stazione Mantova')
ylabel('Residuo')
xlabel('Osservazione n°')
% Si può osservare guardando il grafico che i residui si distribuiscono
% uniformanente attorno allo 0 (hanno media = 0).
histfit(resm6)
title('Analisi dei residui - Stazione Mantova')
% I residui si distribuiscono come una normale.

% Stepwise per verifica risultati
xAllReg = [tG.Pioggia_cum_tG1, tG.Umidita_relativa_tG1, tG.O3_tG1, tG.Temperatura_tG1, tG.NO2_tG1, tG.NOx_tG1]
stepwisefit(xAllReg,y)
% Si può osservare che i regressori significativi sono gli stessi del 5°
% studio. Il sesto studio è stato pensato per alzare l'indice di
% determinazione di 0.025.


%% Regressione lineare multipla per stazione BERGAMO.
data_BG = tG(:,{'Temperatura_BG','Pioggia_cum_BG','Umidita_relativa_BG','O3_BG', 'NOx_BG', 'NO2_BG', 'PM10_BG'})
data_BG.Properties.VariableNames = {'Temp','Pioggia','Umid','Ozono','Ossidi_azoto', 'Biossido_azoto', 'PM10'};

% 1° studio: consideriamo tutti i regressori.
m1_BG = fitlm(data_BG,'ResponseVar','PM10','PredictorVars',{'Temp','Pioggia', 'Umid','Ozono','Ossidi_azoto', 'Biossido_azoto'})
% Si può osservare che il p-value della Temperatura, Ozono e Umidità è molto
% elevato. Inoltre si osserva che R2_corretto = 0.659. Si esegue un secondo 
% studio senza considerare la temperatura (quella con p-value più alto).

% 2° studio: senza temperatura.
m2_BG = fitlm(data_BG,'ResponseVar','PM10','PredictorVars',{'Pioggia', 'Umid','Ozono','Ossidi_azoto', 'Biossido_azoto'})
% Si osserva che il p-value dell'ozono è il più alto (p-value > 0.10), per cui
% si prova ad escluderlo dal modello. Inoltre si ha che R2_corretto=0.661

% 3° studio: senza ozono.
m3_BG = fitlm(data_BG,'ResponseVar','PM10','PredictorVars',{'Pioggia', 'Umid', 'Ossidi_azoto', 'Biossido_azoto'})
% Si osserva che per l'umidità si ha un p-value > 0.10 per cui si procede
% ad eliminarlo dal modello. Inoltre si ha che R2_corretto = 0.662

% 4° studio: senza umidità.
m4_BG = fitlm(data_BG,'ResponseVar','PM10','PredictorVars',{'Pioggia', 'Ossidi_azoto', 'Biossido_azoto'})
% Da questo studio si ha che tutti i regressori sono significativi, hanno
% un p-value < 0.01 (rigetto forte). Inoltre si ha che R2_corretto = 0.663

% Rappresento graficamente il 4° studio:
plot(m4_BG)
title('Stazione di Bergamo - PM10')

% Analisi dei residui
resm4_BG = m4_BG.Residuals.Raw
plot(resm4_BG)
yline(0,'r','LineWidth',3)
yline(mean(resm4_BG),'b','LineWidth',2)
title('Analisi dei residui - Stazione Bergamo')
ylabel('Residuo')
xlabel('Osservazione n°')
% Si può osservare guardando il grafico che i residui si distribuiscono
% uniformanente attorno allo 0 (hanno media = 0).
histfit(resm4_BG)
title('Analisi dei residui - Stazione Bergamo')
% I residui si distribuiscono come una normale.

% Stepwise per verifica risultati:
xAllRegBG = [tG.Pioggia_cum_BG, tG.Umidita_relativa_BG, tG.O3_BG, tG.Temperatura_BG, tG.NO2_BG, tG.NOx_BG]
stepwisefit(xAllRegBG,tG.PM10_BG)
% Si può osservare che i regressori significativi sono ancora gli stessi.