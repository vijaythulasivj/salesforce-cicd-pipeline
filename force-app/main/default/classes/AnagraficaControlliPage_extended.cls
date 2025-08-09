
global class AnagraficaControlliPage_extended {
    
    global class cf_info {
        global string codEsito;
        global string nome;
        global string cognome;
        global string sesso;
        global Integer giorno;
        global Integer mese;
        global String anno;
        global string comune;
        global string prov;
        global string paese;
    }
    
    public string codiceCognomeCF(string nome) {
        
        nome = nome.toUpperCase();
        nome = nome.replace(' ','');
        nome = nome.replace('\'','');
        
        string reorder_vocali = '';
        string reorder_consonanti = '';
        string vocali = 'AEIOU';
        string to_return = '';
        
        if(nome.length() == 2) {
            
            to_return = nome.toUpperCase() + 'X';
            
            return to_return;
            
        } else for(Integer i = 0; i < nome.length(); i++) {
            
            if(vocali.contains(nome.substring(i,i+1))) {
                
                reorder_vocali = reorder_vocali + nome.substring(i,i+1);
                
            } else reorder_consonanti = reorder_consonanti + nome.substring(i,i+1);
        
        }
        
        reorder_vocali = reorder_vocali.toUpperCase();
        reorder_consonanti = reorder_consonanti.toUpperCase();
        
        to_return = reorder_consonanti + reorder_vocali;
        
        return to_return.substring(0,3);
    }

    public string codiceNomeCF(string nome) {
        
        nome = nome.toUpperCase();
        nome = nome.replace(' ','');
        nome = nome.replace('\'','');
                
        string reorder_vocali = '';
        string reorder_consonanti = '';
        string vocali = 'AEIOU';
        string to_return = '';
        
        if(nome.length() == 2) {
            
            to_return = nome.toUpperCase() + 'X';
            
            return to_return;
            
        } else for(Integer i = 0; i < nome.length(); i++) {
            
            if(vocali.contains(nome.substring(i,i+1))) {
                
                reorder_vocali = reorder_vocali + nome.substring(i,i+1);
                
            } else reorder_consonanti = reorder_consonanti + nome.substring(i,i+1);
        
        }
        
        reorder_vocali = reorder_vocali.toUpperCase();
        reorder_consonanti = reorder_consonanti.toUpperCase();
        
        if(reorder_consonanti.length() > 3) {
            
            to_return = reorder_consonanti.substring(0,1) + reorder_consonanti.substring(2,4);
        
        } else to_return = reorder_consonanti + reorder_vocali;
        
        return to_return.substring(0,3);
    }
    
    
    public string codiceDataNascita(Integer giorno, Integer mese, string anno, string sesso) {
        System.debug(LOGGINGLEVEL.INFO,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%anno input ' + anno);
        List<string> codici_mesi = new List<string>{'A', 'B', 'C', 'D', 'E', 'H', 'L', 'M', 'P', 'R', 'S', 'T'};
        string codice = '';
        
        codice = codice + anno.substring(2,4);
        codice = codice + codici_mesi[mese - 1];
        System.debug(LOGGINGLEVEL.INFO,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%codice mese' + codice);
        
        if(sesso == 'M') {
            if(giorno < 10) {
    
                codice = codice + '0' + giorno;
            } else codice = codice + giorno;
            
        } else {
            giorno = giorno + 40;
            codice = codice + giorno;
        }
        
        return codice.toUpperCase();
    }
    
    public string codiceBelfiore(string comune) {
        
        string to_return = '';
        
        List<List_of_values__c> lov_list = [SELECT Id, Belfiore__c, Comune__c, Sigla_Provincia_cf__c, Ordine__c FROM List_of_values__c WHERE Comune__c = :comune AND Ordine__c = '1' LIMIT 1];
        
        system.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$ DEBUG BELFIORE: ' + lov_list);
        
        if(!lov_list.isEmpty()) {
            
            for( List_of_values__c lov_tmp : lov_list) {
            
                to_return = lov_tmp.Belfiore__c;
                
            }
            
        } else to_return = 'KO - ERRORE: COMUNE NON TROVATO';
        
        return to_return;
    }
    
    public string codiceFinale(string cf) {
        
        system.debug('££££££££££££££££££££ DEBUG COD INIZIALE ' + cf);
        
        String codice = '';
        Integer somma = 0;
        
        Map<String,String> pari = new Map<String,String>{'0' => '0', '1' => '1', '2' => '2', '3' => '3', '4' => '4', '5' => '5', '6' => '6', '7' => '7', '8' => '8', '9' => '9', 'A' => '0', 'B' => '1', 'C' => '2', 'D' => '3', 'E' => '4', 'F' => '5', 'G' => '6', 'H' => '7', 'I' => '8', 'J' => '9', 'K' => '10', 'L' => '11', 'M' => '12', 'N' => '13', 'O' => '14', 'P' => '15', 'Q' => '16', 'R' => '17', 'S' => '18', 'T' => '19', 'U' => '20', 'V' => '21', 'W' => '22', 'X' => '23', 'Y' => '24', 'Z' => '25'};
        Map<String,String> dispari = new Map<String,String>{'0' => '1', '1' => '0', '2' => '5', '3' => '7', '4' => '9', '5' => '13', '6' => '15', '7' => '17', '8' => '19', '9' => '21', 'A' => '1', 'B' => '0', 'C' => '5', 'D' => '7', 'E' => '9', 'F' => '13', 'G' => '15', 'H' => '17', 'I' => '19', 'J' => '21', 'K' => '2', 'L' => '4', 'M' => '18', 'N' => '20', 'O' => '11', 'P' => '3', 'Q' => '6', 'R' => '8', 'S' => '12', 'T' => '14', 'U' => '16', 'V' => '10', 'W' => '22', 'X' => '25', 'Y' => '24', 'Z' => '23'};
        Map<String,String> finale = new Map<String,String>{'0' => 'A', '1' => 'B', '2' => 'C', '3' => 'D', '4' => 'E', '5' => 'F', '6' => 'G', '7' => 'H', '8' => 'I', '9' => 'J', '10' => 'K', '11' => 'L', '12' => 'M', '13' => 'N', '14' => 'O', '15' => 'P', '16' => 'Q', '17' => 'R', '18' => 'S', '19' => 'T', '20' => 'U', '21' => 'V', '22' => 'W', '23' => 'X', '24' => 'Y', '25' => 'Z'};
        
        for(Integer i = 0; i < cf.length(); i++) {
            
            system.debug('££££££££££££££££££££ DEBUG CICLO ' + i);
            
            if(math.mod(i+1,2) == 0) {//pari
                system.debug('££££££££££££££££££££ DEBUG PARI1 ' + cf.substring(i,i+1));
                system.debug('££££££££££££££££££££ DEBUG PARI2 ' + pari.get(cf.substring(i,i+1)));
                system.debug('££££££££££££££££££££ DEBUG PARI3 ' + Integer.valueOf(pari.get(cf.substring(i,i+1))));
                system.debug('££££££££££££££££££££ DEBUG PARI4 ' + somma);
                somma = somma + Integer.valueOf(pari.get(cf.substring(i,i+1)));

                
            } else {
                system.debug('££££££££££££££££££££ DEBUG DISP ' + cf.substring(i,i+1));
                system.debug('££££££££££££££££££££ DEBUG DISP ' + dispari.get(cf.substring(i,i+1)));
                system.debug('££££££££££££££££££££ DEBUG DISP ' + Integer.valueOf(dispari.get(cf.substring(i,i+1))));
                system.debug('££££££££££££££££££££ DEBUG PARI ' + somma);
                somma = somma + Integer.valueOf(dispari.get(cf.substring(i,i+1)));
                

            }
            
        }
        
        system.debug('££££££££££££££££££££ DEBUG SOMMA ' + somma);
        Integer itemp = math.mod(somma, 26);
        system.debug('££££££££££££££££££££ DEBUG SOMMA ' + itemp);
        
        codice = finale.get(string.valueOf(itemp));
        
        system.debug('££££££££££££££££££££ DEBUG CODICE ' + codice);
        
        return codice;
    }
    
    public AnagraficaControlliPage_extended.cf_info checkCFinfo(string cf){
        
        System.debug(LOGGINGLEVEL.INFO,'%%%%%%%%%%%%%%%%%%%%%%INPUT CF'+ cf);
        string codici_mesi = 'ABCDEHLMPRST';
        AnagraficaControlliPage_extended.cf_info temp_info = new AnagraficaControlliPage_extended.cf_info();
        
        //check omocodia
        cf = checkOmocodia(cf);
        
        //data
        //if(integer.valueOf(cf.substring(6,8)) <= 16){
        //    temp_info.anno = '20' + cf.substring(6,8);
        //} else 
        temp_info.anno = '19' + cf.substring(6,8);
        system.debug('££££££££££££££££££ DEBUG ANNO: ' + temp_info.anno);
        
        temp_info.mese = Integer.valueOf(codici_mesi.indexOf(cf.substring(8,9))) + 1;
        System.debug(LOGGINGLEVEL.INFO,'%%%%%%%%%%%%%%%%%%%%%%TEMP MESE'+temp_info.mese);
        
        temp_info.giorno = Integer.valueOf(cf.substring(9,11));
        
        //sesso
        if(temp_info.giorno > 31) {
            
            temp_info.sesso = 'F';
            temp_info.giorno = (Integer.valueOf(cf.substring(9,11)) - 40);
            
        } else {
        
            temp_info.sesso = 'M';
            temp_info.giorno = Integer.valueOf(cf.substring(9,11));
            
        }
        
        //maggiore età
        
        date data_nascita = date.parse(string.valueOf(temp_info.giorno) + '/' + string.valueOf(temp_info.mese) + '/' + temp_info.anno);
        string risultato = check_cf_maggiorenne(data_nascita);
        
        if(risultato == 'KO') temp_info.codEsito = 'KO';
        
        //Comune
        system.debug('$$$$$$$$$$$$$$$$$ DEBUG BELFIORE CF: ' + cf);        
        string temp_belf = cf.substring(11,15);
        system.debug('$$$$$$$$$$$$$$$$$ DEBUG BELFIORE: ' + temp_belf);
        List<List_of_values__c> lov_list = [SELECT Id, Belfiore__c, Comune__c, Sigla_Provincia_cf__c FROM List_of_values__c WHERE Belfiore__c = :temp_belf AND Ordine__c = '1' LIMIT 1];
        
        if(!lov_list.isEmpty()) {
            
            for( List_of_values__c lov_tmp : lov_list) {
                
                if(cf.substring(11,12) != 'Z') {

                    temp_info.comune = lov_tmp.Comune__c;
                    temp_info.prov = lov_tmp.Sigla_Provincia_cf__c ;
                    temp_info.paese = 'ITALIA';
                    
                } else if(cf.substring(11,12) == 'Z') {//stato estero
                
                    temp_info.paese = 'ESTERO';
                    temp_info.prov = 'EE' ;
                    temp_info.comune = lov_tmp.Comune__c; //gli stati stranieri sono registrati nel field "Comune__c"
                
                }
            }
            
        } else temp_info.codEsito = 'KO';
        
        //carattere controllo
        string checksum_cf = codiceFinale(cf.substring(0,15));
        if(checksum_cf != cf.right(1)) temp_info.codEsito = 'KO';
        
        return temp_info;
        
    }
    
    public string checkOmocodia(string cf) {
        
        Map<String, String> omcd = new Map<String,String>{'L' => '0', 'M' => '1', 'N' => '2', 'P' => '3', 'Q' => '4', 'R' => '5', 'S' => '6', 'T' => '7', 'U' => '8', 'V' => '9'};
        
        //anno
        string temp1 = omcd.get(cf.substring(6,7));
        if(temp1 != null) cf = cf.left(6) + temp1 + cf.right(cf.length()-7);
        
        string temp2 = omcd.get(cf.substring(7,8));
        if(temp2 != null) cf = cf.left(7) + temp2 + cf.right(cf.length()-8);
        
        //mese
        string temp3 = omcd.get(cf.substring(9,10));
        if(temp3 != null) cf = cf.left(9) + temp3 + cf.right(cf.length()-10);
        string temp4 = omcd.get(cf.substring(10,11));
        if(temp4 != null) cf = cf.left(10) + temp4 + cf.right(cf.length()-11);
        
        //belfiore
        string temp5 = omcd.get(cf.substring(12,13));
        if(temp5 != null) cf = cf.left(12) + temp5 + cf.right(cf.length()-13);
        string temp6 = omcd.get(cf.substring(13,14));
        if(temp6 != null) cf = cf.left(13) + temp6 + cf.right(cf.length()-14);
        string temp7 = omcd.get(cf.substring(14,15));
        if(temp7 != null) cf = cf.left(14) + temp7 + cf.right(cf.length()-15);
        
        return cf;  
    }

    public string checkCCnumber(string CC) {
        
        string result = '';
        
        if(CC.length() == 16 || CC.length() == 15 || CC.length() == 14) {

            string BIN1 = CC.substring(0,4);
            System.debug(LOGGINGLEVEL.INFO,'%%%%%%%%%%%%%%%%%%%%%%%%%' + BIN1);
            string BIN2 = CC.substring(0,6);
            System.debug(LOGGINGLEVEL.INFO,'%%%%%%%%%%%%%%%%%%%%%%%%%' + BIN2);
            
            //List<List_of_values__c> lov_list = [SELECT Id, Bin__c, Len__c FROM List_of_values__c WHERE Bin__c in (:BIN1, :BIN2)];
            List<List_of_values__c> lov_list = [SELECT Id, Bin__c, Len__c FROM List_of_values__c WHERE Bin__c = :BIN1 OR Bin__c = :BIN2];
            
            if(!lov_list.isEmpty()){
                System.debug(LOGGINGLEVEL.INFO,'%%%%%%%%%%%%%%%%%%%%%%%%%' + 'BIN TROVATO ' + lov_list);
                boolean found = true;
                
                /*boolean found = false;                
                for(List_of_values__c lov_temp : lov_list){
                    if(cc.length() == integer.valueOf(lov_temp.Len__c)) found = true;
                }*/
                
                if(found){ 
                    result =  'OK';
                } else result =  'KO';
                
            } else result =  'KO';
            
        
        } else result =  'KO';
        
        return result;
    }
    
    public string checkABI(string abi) {
        
        string result = '';
    
        List<List_of_values__c> lov_list = [SELECT Id, ABI__c, CAB__c, Codice_Paese__c FROM List_of_values__c WHERE ABI__c = :abi];
        
        if(!lov_list.isEmpty()){
            
            result = 'OK';
        
        } else result = 'KO - ABI non trovato';
    
        return result;
    }
    
    public string checkABI_CAB(string abi, string cab) {
        
        string result = '';
        
        List<List_of_values__c> lov_list = [SELECT Id, ABI__c, CAB__c, Codice_Paese__c FROM List_of_values__c WHERE ABI__c = :abi AND CAB__c = :cab LIMIT 1];
        
        if(!lov_list.isEmpty()){
            
            result = 'OK';
        
        } else result = 'KO - Coppia ABI-CAB non trovata';
        
        return result;
    }
        
    
    public list<string> calcoloIBANnumber(string abi, string cab, string cc) {
        //check Abi/cab
        //string result = '';
        List<string> result = new List<string>();
        string cin = '';
        string codicep = '';
        string codiceControllo = '';
        
        List<List_of_values__c> lov_list = [SELECT Id, ABI__c, CAB__c, Codice_Paese__c,  Nome_Banca__c, Nome_Agenzia__c, Indirizzo_Agenzia__c FROM List_of_values__c WHERE ABI__c = :abi AND CAB__c = :cab LIMIT 1];
            
            if(!lov_list.isEmpty()){
            
            for(List_of_values__c lov_list_tmp : lov_list) {
                
                    cc = zeroPaddingCC(cc,12);
                    
                    //codice paese
                    if (lov_list_tmp.Codice_Paese__c == '' || lov_list_tmp.Codice_Paese__c == null) {
                        
                        codicep = 'IT';
                        
                    } else codicep = lov_list_tmp.Codice_Paese__c;
                    
                    //calcolo cin
                    cin = calcoloCin(abi + cab + cc);
                    
                    codiceControllo = calcoloCodiceControlloIBAN(cin + abi + cab + cc + codicep + '00');
                    
                    result.add(codicep + codiceControllo + cin + abi + cab + cc);
                     result.add(lov_list_tmp.Nome_Banca__c );
                    result.add(lov_list_tmp.Nome_Agenzia__c );
                     result.add(lov_list_tmp.Indirizzo_Agenzia__c);
                    
                }
            } else result.add('KO');
            
        return result;
    }
    
    public string zeroPaddingCC(string num, Integer len) {
        
        string result = '';
        result = num;
        
        for(integer i=0; i < (len-num.length()); i++) {
            
            result = '0' + result;
        
        }
        
        return result;
    }
    
    public string calcoloCin(string seq) {
        
        string aa = 'A0B1C2D3E4F5G6H7I8J9K#L#M#N#O#P#Q#R#S#T#U#V#W#X#Y#Z#-#.# #';
        string bb = 'B1A0K#P#L#C2Q#D3R#E4V#O#S#F5T#G6U#H7M#I8N#J9W#Z#Y#X# #-#.#';
        Integer dd = 0;

        for (Integer ii = 1; ii < 22; ii += 2) {
            dd = dd + Integer.valueOf(math.floor(aa.indexOf(seq.substring(ii,ii+1)) / 2));
        }
        for (Integer ii = 0; ii < 22; ii += 2) {
            dd = dd + Integer.valueOf(math.floor(bb.indexOf(seq.substring(ii,ii+1)) / 2));
        }
        dd = dd - Integer.valueOf((math.floor(dd / 26) * 26));
        
        integer index_n = dd * 2;
        
        return aa.substring(index_n, index_n + 1);
    
    }
    
    public string calcoloCodiceControlloIBAN(string seq) {
        
        string result = '';
        string result_temp = '';
        string tabella = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        seq = seq.toUpperCase();
        integer divisore = 97;
        
        for(integer i=0; i < seq.length(); i++){
            
            string temp_s = seq.substring(i,i+1);
            
            //system.debug('££££££££££ DEBUG ' + temp_s);
            
            if(temp_s.isAlpha()) {
                result_temp = result_temp + string.valueOf(tabella.indexOf(temp_s));
            } else result_temp = result_temp + temp_s;
            
            //system.debug('££££££££££ DEBUG ' + result_temp + ' ' + seq);
        }
        
        system.debug('££££££££££ DEBUG ' + result_temp);
        
        //funzione modulo
        integer i = 0;
        integer temp_num = 0;
        string temp_num_string = '';
        
        while(i < result_temp.length()) {
            system.debug('££££££££££ DEBUG CICLO ' + i);
            
            if(i==0) {
            
                temp_num_string = result_temp.substring(0,9);
                temp_num = math.mod(Integer.valueOf(temp_num_string),97);
                system.debug('££££££££££ DEBUG NUM ' + temp_num_string + ' ' + temp_num);
                i = 9;
                
            } else {
                
                if((i+7) >= result_temp.length()) {
                    temp_num_string = string.valueOf(temp_num) + result_temp.substring(i,result_temp.length());
                    temp_num = math.mod(Integer.valueOf(temp_num_string),97);
                    system.debug('££££££££££ DEBUG LAST ' + i + ' ' + temp_num_string + ' ' + temp_num);
                   
                    i = result_temp.length() + 1;
                                       
                } else {

                    temp_num_string = string.valueOf(temp_num) + result_temp.substring(i,i+7);
                    temp_num = math.mod(Integer.valueOf(temp_num_string),97);
                    system.debug('££££££££££ DEBUG NUM ' + temp_num_string + ' ' + temp_num);
                    
                    system.debug('££££££££££ DEBUG CICLO+7 ' + i + ' ' + Integer.valueOf(i+7));
    
                    i = i + 7;
                }
            } 
        
        }
              
        temp_num = 98 - math.mod(temp_num,97);
        
        if(temp_num < 10) {
            
            result = '0' + string.valueOf(temp_num);
            
        } else result = string.valueOf(temp_num);
        
        return result;
    }
    
    public List<string> extractInfoFromIBAN(string iban) {
        
        List<string> result = new List<string>();
        
        if(iban.length() == 27) {
        
            String ABI = iban.substring(5,10);
            String CAB = iban.substring(10,15);
            String conto = iban.substring(15,27);
            
            while(conto.left(1) == '0') { //elimino lo zero padding
                
                conto = conto.substring(1,conto.length());
            
            }
            
           //estraggo info della banca
            
            RecordType rt1 = [SELECT Id, Name FROM RecordType WHERE Name = 'Abi Cab' LIMIT 1];
            List<List_of_values__c> lov_list = [Select Id, Codice_Paese__c, abi__c, cab__c, Nome_Banca__c, Nome_Agenzia__c , Indirizzo_Agenzia__c 
                                                from List_of_values__c 
                                                where RecordTypeId = :rt1.Id
                                                and abi__c = :ABI
                                                and cab__c = :CAB
                                                Order by CreatedDate desc
                                                LIMIT 1];
            
            //Valori ABI CAB coerenti con la List Of Values                               
            if(!lov_list.isEmpty()){
                        
                result.add(iban.substring(5,10)); //ABI
                result.add(iban.substring(10,15)); //CAB
                result.add(conto); 
                result.add(lov_list[0].Nome_Banca__c); //nome banca
                result.add(lov_list[0].Nome_Agenzia__c); //nome agenzia
                result.add(lov_list[0].Indirizzo_Agenzia__c); //indirizzo agenzia
                result.add(lov_list[0].Codice_Paese__c); //codice paese   
                system.debug(LOGGINGLEVEL.INFO,'%%%%%%%%%%%%%%%%%%%%%%%' + ' ABI CAB TROVATI');
            }
            //KO Valore non censito
            else {
                result.add('KO');
                system.debug(LOGGINGLEVEL.INFO,'%%%%%%%%%%%%%%%%%%%%%%%' + ' ABI CAB NON TROVATI');
            
            }
        }
        return result;
    }
    
    public string check_cf_maggiorenne(date data_nascita){
        
        string result = '';
        
        Date data_nascita2 = data_nascita.addYears(18);
        date oggi = date.today();
        
        if(data_nascita2 > oggi) result = 'KO';
        
        system.debug('££££££££££££ DEBUG MAGGIORENNE: ' + data_nascita + ' - ' + result);
        
        return result;
    }

}

