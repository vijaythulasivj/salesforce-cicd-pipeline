
/*****************************************************************
Name:  AOMDraftOrderHandlerTest
============================================================
Purpose: test AOMDraftOrderHandlerTest class.
============================================================
History
-------
VERSION  AUTHOR             DATE           DETAIL          Description
1.0     Shravani           11/04/2022      Created         Sky New CRM Phase 2
-------         
*****************************************************************/
@isTest
public class AOMDraftOrderHandlerTest {
    
    @testSetup 
    public static void setupTest(){
        Account acc = new Account();
        acc.Name = 'MASSIMO BARDAZZI'; //DO NOT CHANGE
        acc.Codice_Cliente__c = 'T04073441'; //DO NOT CHANGE
        insert acc;
        
        //contact
        Contact con = new Contact();
        con.FirstName = 'MASSIMO'; //DO NOT CHANGE
        con.LastName = 'BARDAZZI'; //DO NOT CHANGE
        con.AccountId = acc.Id;
        con.OtherPhone = '02323789442';
        con.Codice_Fiscale__c = 'SCMGJA2387293872';
        con.Comune_Nascita__c = 'STAZZANO';
        con.Comune_Nascita__c = 'MASSIMO';
        con.Birthdate = Date.today();
        con.Numero_Documento__c = 'FGEYEH3';
        con.Provincia_Nascita__c = 'AL';
        con.Phone = '3428302836';
        insert con;
        acc.vlocity_cmt__PersonContactId__c = con.Id;
        update acc;
        
        //USER
        User us = new User();
        us.Tipo_venditore__c = 'AUTOMA';
        us.Username = 'test@automa.it';
        us.LastName = 'Test_Aut';
        us.Email = 'test@automa687.it';
        us.Alias = 'testa';
        us.TimeZoneSidKey = 'Europe/Rome';
        us.LocaleSidKey='it_IT';
        us.EmailEncodingKey = 'ISO-8859-1';
        us.LanguageLocaleKey = 'en_US';
        us.ProfileId ='00eb0000000pc2RAAQ';
        insert us;
        
        //PRICELIST
        Pricebook2 standardBook =  new Pricebook2(Id=Test.getStandardPricebookId(), IsActive = true, vlocity_cmt__IsDefault__c = true);
        vlocity_cmt__PriceList__c vp = new vlocity_cmt__PriceList__c();
        vp.vlocity_cmt__Pricebook2Id__c = standardBook.Id;
        vp.vlocity_cmt__IsActive__c = true;
        vp.vlocity_cmt__Code__c = 'Listino_Sky_Base';
        vp.Name = 'Listino SKY BASE';
        insert vp;
        vlocity_cmt__PriceList__c vpNPP = new vlocity_cmt__PriceList__c();
        vpNPP.vlocity_cmt__Pricebook2Id__c = standardBook.Id;
        vpNPP.vlocity_cmt__IsActive__c = true;
        vpNPP.vlocity_cmt__Code__c = 'Listino_Sky_NPP';
        vpNPP.Name = 'Listino Sky NPP';
        insert vpNPP;
        
        //CONTRACT
        Id RTParent = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('PARENT').getRecordTypeId();
        Id RTChild = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('TV').getRecordTypeId();
        Id RTCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Activity').getRecordTypeId();
        Id RTCaseSR = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        
        Contract parent = new Contract();
        parent.RecordTypeId = RTParent;
        parent.Order_Number__c = 'P000';
        parent.AccountId = acc.Id;
        parent.Contract_Trait__c = 'Standard';
        parent.Payer_Id__C = acc.id;
        insert parent;
        
        Contract contr = new Contract();
        contr.AccountId = acc.Id;
        contr.Payer_Id__c = acc.Id;
        contr.Billing_Id__c = acc.Id; // VS - NPP - STAMPA
        contr.Order_Number__c = '4530018'; //DO NOT CHANGE
        contr.ShippingCity = 'STAZZANO';
        contr.Particella_Toponomastica__c = 'VIA';
        contr.ShippingPostalCode = '15383';
        contr.ShippingState = 'ITALIA';
        contr.ShippingStreet = 'ROSENDO';
        contr.Complesso__c = '4';
        contr.Numero_Civico__c = '23';
        contr.Scala__c = '6';
        contr.Tipo_Documento__c = 'CARTA IDENTITA';
        //contr.Data_Cessazione_Dt__c = date.today();
        contr.RecordTypeId = RTChild;
        contr.Contract_Trait__c = 'Standard';
        contr.vlocity_cmt__ParentContractId__c = parent.Id;
        contr.Data_Richiesta_Cessazione_Dt__c = Date.today().addDays(5);
        contr.Data_Scadenza_Dt__c = date.today();
        contr.Tipologia_Commitment__c = 'IC';
        contr.vlocity_cmt__PriceListId__c = vp.Id;
        contr.Ambiente_Servizio__c = 'SKY DTT';
        contr.Status = 'Bozza';
        insert contr;
        
        parent.ChildContractTV__c = contr.id;
        update parent;
        
        OmniRemoteActionSky8020 controller1 = new OmniRemoteActionSky8020();
        Pricebook2 listinoskybase1 =  new Pricebook2(Name = controller1.PRICEBOOK2_LISTINO_SKY_BASE, IsActive = true, vlocity_cmt__IsDefault__c = true);
        insert listinoskybase1;
        
        Order order4 = new Order();
        order4.AccountId = contr.AccountId;
        order4.ContractId = parent.id;
        order4.EffectiveDate = Date.today();
        order4.Status = 'Draft';
        order4.Pricebook2id = listinoskybase1.id;
        order4.Type = OG_Utilities.ORDERTYPE_CHANGE_CONSISTENCY_ORDER;
        order4.OG_Integration_Outcome__c =  'ESITO: 0%'; 
        order4.vlocity_cmt__RequestDate__c = Date.today();
        order4.Name = 'root4';
        order4.vlocity_cmt__FulfilmentStatus__c = 'In Progress';
        order4.OG_SellingChannel__c = 'CRM';
        order4.OG_SchedulatedDate__c = Date.today();
        order4.OrderOfferType_BLB__c= 'CEASE_BB'; 
        order4.vlocity_cmt__PriceListId__c = vp.id;
        order4.withdrawal_flg__c = true;
        order4.OrderReason_BLB__c='{"DOCUMENT_UPLOAD":null,"DOC_NOT_VERIFIED":null,"ID_NOT_VERIFIED":null,"DOC_PAYER_NOT_VERIFIED":null,"ID_PAYER_NOT_VERIFIED":null,"DOC_USER_NOT_VERIFIED":null,"ID_USER_NOT_VERIFIED":null,"DECA":null,"TAKEN_APPOINTMENT":true,"MIGRATIONCODE_UPLOAD":null}';
        insert order4; 
        
        Order order5 = new Order();
        order5.AccountId = contr.AccountId;
        order5.ContractId = parent.id;
        order5.EffectiveDate = Date.today();
        order5.Status = 'Draft';
        order5.Pricebook2id = listinoskybase1.id;
        order5.Type = OG_Utilities.ORDERTYPE_CHANGE_CONSISTENCY_ORDER;
        order5.OG_Integration_Outcome__c = 'IO Exception: Read timed out'; 
        order5.vlocity_cmt__RequestDate__c = Date.today();
        order5.Name = 'root5';
        //order5.OfferType__c = 'TV';
        order5.vlocity_cmt__FulfilmentStatus__c = 'In Progress';
        order5.OG_SellingChannel__c = 'CRM';
        order5.OG_SchedulatedDate__c = Date.today();
        order5.OrderOfferType_BLB__c= 'CEASE_BB'; 
        order5.vlocity_cmt__PriceListId__c = vp.id;
        order5.withdrawal_flg__c = true;
        order5.BB_Integration_Outcome__c ='';
        //order5.LastModifiedDate = Date.today();
        order5.OrderReason_BLB__c='{"DOCUMENT_UPLOAD":null,"DOC_NOT_VERIFIED":null,"ID_NOT_VERIFIED":null,"DOC_PAYER_NOT_VERIFIED":null,"ID_PAYER_NOT_VERIFIED":null,"DOC_USER_NOT_VERIFIED":null,"ID_USER_NOT_VERIFIED":null,"DECA":null,"TAKEN_APPOINTMENT":true,"MIGRATIONCODE_UPLOAD":null}';
        insert order5;
        
        Order order10 = new Order();
        order10.AccountId = contr.AccountId;
        order10.ContractId = parent.id;
        order10.EffectiveDate = Date.today();
        order10.Status = 'Draft';
        order10.Pricebook2id = listinoskybase1.id;
        order10.Type = OG_Utilities.ORDERTYPE_CHANGE_CONSISTENCY_ORDER;
        order10.OG_Integration_Outcome__c =  'ESITO: 0%'; 
        order10.vlocity_cmt__RequestDate__c = Date.today();
        order10.Name = 'root10';
        order10.vlocity_cmt__FulfilmentStatus__c = 'In Progress';
        order10.OG_SellingChannel__c = 'CRM';
        order10.OG_SchedulatedDate__c = Date.today();
        order10.OrderOfferType_BLB__c= 'CEASE_BB'; 
        order10.vlocity_cmt__PriceListId__c = vp.id;
        order10.withdrawal_flg__c = true;
        order10.OrderReason_BLB__c='{"DOCUMENT_UPLOAD":null,"DOC_NOT_VERIFIED":null,"ID_NOT_VERIFIED":null,"DOC_PAYER_NOT_VERIFIED":null,"ID_PAYER_NOT_VERIFIED":null,"DOC_USER_NOT_VERIFIED":null,"ID_USER_NOT_VERIFIED":null,"DECA":null,"TAKEN_APPOINTMENT":true,"MIGRATIONCODE_UPLOAD":null}';
        insert order10; 
        
        Order order11 = new Order();
        order11.AccountId = contr.AccountId;
        order11.ContractId = parent.id;
        order11.EffectiveDate = Date.today();
        order11.Status = 'Draft';
        order11.Pricebook2id = listinoskybase1.id;
        order11.Type = OG_Utilities.ORDERTYPE_CHANGE_CONSISTENCY_ORDER;
        order11.OG_Integration_Outcome__c = 'IO Exception: Read timed out'; 
        order11.vlocity_cmt__RequestDate__c = Date.today();
        order11.Name = 'root11';
        order11.vlocity_cmt__FulfilmentStatus__c = 'In Progress';
        order11.OG_SellingChannel__c = 'CRM';
        order11.OG_SchedulatedDate__c = Date.today();
        order11.OrderOfferType_BLB__c= 'CEASE_BB'; 
        order11.vlocity_cmt__PriceListId__c = vp.id;
        order11.withdrawal_flg__c = true;
        order11.BB_Integration_Outcome__c ='';
        order11.OrderReason_BLB__c='{"DOCUMENT_UPLOAD":null,"DOC_NOT_VERIFIED":null,"ID_NOT_VERIFIED":null,"DOC_PAYER_NOT_VERIFIED":null,"ID_PAYER_NOT_VERIFIED":null,"DOC_USER_NOT_VERIFIED":null,"ID_USER_NOT_VERIFIED":null,"DECA":null,"TAKEN_APPOINTMENT":true,"MIGRATIONCODE_UPLOAD":null}';
        insert order11;
        
        // to test positive scenario for AOM_CSV_Retrigegr_Batch
        Order order6 = new Order();
        order6.AccountId = contr.AccountId;
        order6.ContractId = parent.id;
        order6.EffectiveDate = Date.today();
        order6.Status = 'Draft';
        order6.Pricebook2id = listinoskybase1.id;
        order6.Type = OG_Utilities.ORDERTYPE_CHANGE_CONSISTENCY_ORDER;
        order6.OG_Integration_Outcome__c = 'IO Exception: Unexpected end of file from server'; 
        //order6.OfferType__c = 'TV';
        order6.vlocity_cmt__RequestDate__c = Date.today();
        order6.Name = 'root6';
        order6.vlocity_cmt__FulfilmentStatus__c = 'In Progress';
        order6.OG_SellingChannel__c = 'CRM';
        order6.OG_SchedulatedDate__c = Date.today();
        order6.OrderOfferType_BLB__c= 'NEW_TV'; 
        order6.vlocity_cmt__PriceListId__c = vp.id;
        order6.withdrawal_flg__c = true;
        order6.BB_Integration_Outcome__c ='';
        //order5.LastModifiedDate = Date.today();
        order6.OrderReason_BLB__c='{"DOCUMENT_UPLOAD":null,"DOC_NOT_VERIFIED":null,"ID_NOT_VERIFIED":null,"DOC_PAYER_NOT_VERIFIED":null,"ID_PAYER_NOT_VERIFIED":null,"DOC_USER_NOT_VERIFIED":null,"ID_USER_NOT_VERIFIED":null,"DECA":null,"TAKEN_APPOINTMENT":true,"MIGRATIONCODE_UPLOAD":null}';
        insert order6;
        
        Order order7 = new Order();
        order7.AccountId = contr.AccountId;
        order7.ContractId = parent.id;
        order7.EffectiveDate = Date.today();
        order7.Status = 'Draft';
        order7.Pricebook2id = listinoskybase1.id;
        order7.Type = OG_Utilities.ORDERTYPE_CHANGE_CONSISTENCY_ORDER;
        order7.OG_Integration_Outcome__c = 'IO Exception: Read timed out'; 
        order7.vlocity_cmt__RequestDate__c = Date.today();
        order7.Name = 'root7';
        //order5.OfferType__c = 'TV';
        order7.vlocity_cmt__FulfilmentStatus__c = 'In Progress';
        order7.OG_SellingChannel__c = 'CRM';
        order7.OG_SchedulatedDate__c = Date.today();
        order7.OrderOfferType_BLB__c= 'CEASE_BB'; 
        order7.vlocity_cmt__PriceListId__c = vp.id;
        order7.withdrawal_flg__c = true;
        order7.BB_Integration_Outcome__c ='';
        //order5.LastModifiedDate = Date.today();
        order7.OrderReason_BLB__c='{"DOCUMENT_UPLOAD":null,"DOC_NOT_VERIFIED":null,"ID_NOT_VERIFIED":null,"DOC_PAYER_NOT_VERIFIED":null,"ID_PAYER_NOT_VERIFIED":null,"DOC_USER_NOT_VERIFIED":null,"ID_USER_NOT_VERIFIED":null,"DECA":null,"TAKEN_APPOINTMENT":true,"MIGRATIONCODE_UPLOAD":null}';
        insert order7;
        
        order7.Status = 'Cancellato';
        update order7;
        
        Case cParent = new Case();
        cParent.OG_RelatedOrder__c = null; //order4.Id;
        cParent.Contract_NewCRM_Id__c= contr.Id;
        cParent.RecordTypeId= RTCaseSR;
        cParent.ChatIdentifier__c = '123213213';
        cParent.Contract_ID__c = contr.Id;
        cParent.AccountId = acc.Id;
        cParent.ContactId = con.Id;
        cParent.Nome_Attivita__c = 'MIGRAZIONE NPP';
        cParent.Codice_Attivita__c = 'SKYNPP';
        cParent.DataQualityType__c = 'value';
        cParent.DurationCall_CTI__c = '3000';
        insert cParent;
        
        
        Case c1 = new Case();
        c1.OG_RelatedOrder__c = order4.Id;
        c1.Contract_NewCRM_Id__c= contr.Id;
        c1.ParentId= cParent.Id;
        c1.RecordTypeId= RTCase;
        c1.ChatIdentifier__c = '123213213';
        c1.Contract_ID__c = contr.Id;
        c1.AccountId = acc.Id;
        c1.ContactId = con.Id;
        c1.Nome_Attivita__c = 'MIGRAZIONE NPP';
        c1.Codice_Attivita__c = 'SKYNPP';
        c1.DataQualityType__c = 'value';
        c1.DurationCall_CTI__c = '3000';
        insert c1;
        System.debug('Case Child=> ' + c1);
        
    }
          
    @isTest
    public static void getLabelTest(){
        Test.startTest();
        AOMDraftOrderHandler.getUserAccess();
        AOMDraftOrderHandler.getFeature();
        Test.stopTest();
    }
    
    @isTest
    public static void resubmissionTest(){
        Order order = [SELECT Id FROM Order WHERE Name = 'root4' LIMIT 1];
        Test.startTest();
        AOMDraftResubmission.resubmission(order.Id);
        Test.stopTest();
    } 
     
    
    @isTest
    public static void importCSVFileoTest(){
        Order ord =[Select id from order where Name = 'root7' LIMIT 1];
        Test.startTest();
        String orderId1 = ord.Id;
        AOMDraftOrderHandler.importCSVFile(orderId1);
        Test.stopTest();
    } 
    //@Anmol 8/12/22 - START
    @isTest
    public static void AOM_CSV_Retrigger_BatchTest1 () {
        
        List<Order> ord =[Select id from order where Name = 'root6' OR Name = 'root5'];
        Test.startTest();

        AOM_CSV_Retrigger_Batch csvProcess = new AOM_CSV_Retrigger_Batch();
        Id batchId = Database.executeBatch(csvProcess,2);
        Test.stopTest();
        
    }
    @isTest
    public static void AOM_CSV_Retrigger_BatchTest2 () {
        List<Order> ord = new List<Order>();
        Test.startTest();
        
        AOM_CSV_Retrigger_Batch csvProcess1 = new AOM_CSV_Retrigger_Batch();
        Id batchId = Database.executeBatch(csvProcess1,2);
        Test.stopTest(); 
    }
    @isTest
    public static void AOM_ScheduleBatchableTest () {
        Test.startTest();
        AOM_ScheduleBatchable sh1 = new AOM_ScheduleBatchable();
        String sch = '0 0 2 * * ?'; 
        system.schedule('AOM_SchedulableBatcheable testing', sch, sh1); 
        Test.stopTest();
    } 
    @isTest
    public static void DraftOrderRetriggerBatchTest () {
        //List<Order> ord =[Select id from order where Name = 'root4' OR Name = 'root5'];
        Order ord =[Select id from order where Name = 'root4' limit 1];
        String orderIdSet = ord.id + ',' + ord.id;
        List<Order> removedOrderList = new List<Order>();
        Test.startTest();
        Id batchId = Database.executeBatch(new DraftOrderRetriggerBatch(orderIdSet,removedOrderList),2);
        Test.stopTest();
    }   
    //@Anmol 8/12/22 - END  
    //Shravani-20/12/2022   
     @isTest
    public static void DraftOrderRetriggerBatchTest2 () {
        String orderIdSet = '';
        
        List<Order> ordList =[Select id from order where Name = 'root10' OR Name = 'root11' ];

        for(Order ord : ordList){
            orderIdSet += orderIdSet + ord.id + ',' ;
        }
        List<Order> orderListToCancel = new List<Order>();
        Test.startTest();
        Id batchId = Database.executeBatch(new DraftOrderRetriggerBatch(orderIdSet,orderListToCancel),2);
        DraftOrderRetriggerBatch batch = new DraftOrderRetriggerBatch(orderIdSet,orderListToCancel);
        batch.orderListToCancel.addAll(ordList);
        Test.stopTest();
    }   
    
}
