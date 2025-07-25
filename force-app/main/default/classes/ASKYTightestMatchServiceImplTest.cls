@isTest
private class ASKYTightestMatchServiceImplTest {
    static private void TestDataSetup(){

        vlocity_cmt__TriggerSetup__c itemTrigger = new vlocity_cmt__TriggerSetup__c(Name='AllTriggers', vlocity_cmt__IsTriggerOn__c=true);
        insert itemTrigger;

        List<SObject> sObjList = new List<SObject>();

        Product2 prod1 = new Product2 (Name='Prod1');
        sObjList.add(prod1);

        Product2 prod2 = new Product2 (Name='Prod2');
        sObjList.add(prod2);

        insert sObjList;
        sObjList.clear();

        Pricebook2 standardBook =  new Pricebook2(Id = Test.getStandardPricebookId(), Name = 'TestPricebook', IsActive = true);

        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = standardBook.Id,
                Product2Id = prod1.Id, UnitPrice = 10, vlocity_cmt__RecurringPrice__c = 5, IsActive = true, UseStandardPrice = false);
        sObjList.add(pbe1);

        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = standardBook.Id,
            Product2Id = prod2.Id, UnitPrice = 20, vlocity_cmt__RecurringPrice__c = 10, IsActive = true, UseStandardPrice = false);
        sObjList.add(pbe2);

        insert sObjList;
        sObjList.clear();

        //Pricebook2 testPricebook = new Pricebook2(Name = 'TestPricebook', IsActive = true);
        //insert testPricebook;

        vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c(vlocity_cmt__Pricebook2Id__c = standardBook.Id, vlocity_cmt__IsActive__c = true, vlocity_cmt__Code__c = 'TestPriceList');
        insert pl1;


        Map<String, Object> dataMap = new Map<String, Object>();

        // Create Object Type
        Id objectRTId = getRecordTypeId('vlocity_cmt__ObjectClass__c', 'Object Type');
        vlocity_cmt__ObjectClass__c chargeObjType = new vlocity_cmt__ObjectClass__c(Name = 'Charge', vlocity_cmt__ObjectApiName__c = 'PricingElement__c', RecordTypeId = objectRTId);
        vlocity_cmt__ObjectClass__c discObjType = new vlocity_cmt__ObjectClass__c(Name = 'Discount', vlocity_cmt__ObjectApiName__c = 'PricingElement__c', RecordTypeId = objectRTId);
        sObjList.clear();
        sObjList.add(chargeObjType);
        sObjList.add(discObjType);
        dataMap.put('OBJTYPE_CHARGE', chargeObjType);
        dataMap.put('OBJTYPE_DISC', discObjType);
        insert sObjList;

        // Create Pricing Variable
        List<Map<String, Object>> pVarList = new List<Map<String, Object>>();
        Map<String, Object> pVarMap = new Map<String, Object>{
                'Name' => 'One Time Std Price',
                'Aggregation__c' => 'Unit',
                'AppliesToVariableId__c' => null,
                'ChargeType__c' => 'One-time',
                'Code__c' => 'OT_STD_PRC',
                'IsActive__c' => true,
                'RecurringFrequency__c' => null,
                'Scope__c' => 'Line',
                'SubType__c' => 'Standard',
                'Type__c' => 'Price',
                'ValueType__c' => 'Pricing Element'
        };
        pVarList.add(pVarMap);
        pVarMap = new Map<String, Object>{
                'Name' => 'Recurring Monthly Std Price',
                'Aggregation__c' => 'Unit',
                'AppliesToVariableId__c' => null,
                'ChargeType__c' => 'Recurring',
                'Code__c' => 'REC_STD_MNTH_PRC',
                'IsActive__c' => true,
                'RecurringFrequency__c' => 'Monthly',
                'Scope__c' => 'Line',
                'SubType__c' => 'Standard',
                'Type__c' => 'Price',
                'ValueType__c' => 'Pricing Element'
        };
        pVarList.add(pVarMap);
        pVarMap = new Map<String, Object>{
                'Name' => 'One Time Std Price Discount Percent',
                'Aggregation__c' => 'Unit',
                'AppliesToVariableId__c' => null,
                'AdjustmentMethod__c' => 'Percent',
                'ChargeType__c' => 'Adjustment',
                'Code__c' => 'OT_STD_PRC_MANUAL_DISC',
                'IsActive__c' => true,
                'RecurringFrequency__c' => null,
                'Scope__c' => 'Line',
                'SubType__c' => 'Standard',
                'ValueType__c' => 'Pricing Element'
        };
        pVarList.add(pVarMap);
        List<SObject> pVarObjList = createObjects('PricingVariable__c', pVarList);
        dataMap.put('PVAR1', pVarObjList[0]);
        dataMap.put('PVAR2', pVarObjList[1]);
        dataMap.put('PVAR3', pVarObjList[2]);

        vlocity_cmt__PricingVariable__c pVar3 = (vlocity_cmt__PricingVariable__c)pVarObjList[2];
        pVar3.vlocity_cmt__AppliesToVariableId__c = pVarObjList[0].Id;

        update pVar3;

        // Create Pricing Element
        vlocity_cmt__PricingElement__c pElem1 = new vlocity_cmt__PricingElement__c(Name = 'One Time $100 Standalone Price', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 100.00,
                vlocity_cmt__Code__c = 'PELEM1', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = pVarObjList[0].Id, vlocity_cmt__PriceListId__c = pl1.Id);
        vlocity_cmt__PricingElement__c pElem2 = new vlocity_cmt__PricingElement__c(Name = 'MRC $20 Standalone Price', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 20.00,
                vlocity_cmt__Code__c = 'PELEM2', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = pVarObjList[1].Id, vlocity_cmt__PriceListId__c = pl1.Id);
        vlocity_cmt__PricingElement__c pElem3 = new vlocity_cmt__PricingElement__c(Name = 'One Time 50% Global Discount', vlocity_cmt__ObjectTypeId__c = discObjType.Id, vlocity_cmt__AdjustmentValue__c = 50,
                vlocity_cmt__Code__c = 'PELEM3', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = pVarObjList[2].Id, vlocity_cmt__PriceListId__c = pl1.Id);
        vlocity_cmt__PricingElement__c pElem4 = new vlocity_cmt__PricingElement__c(Name = 'One Time $400 Local Price', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 400.00,
                vlocity_cmt__Code__c = 'PELEM4', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = false, vlocity_cmt__PricingVariableId__c = pVarObjList[0].Id, vlocity_cmt__PriceListId__c = pl1.Id);
        vlocity_cmt__PricingElement__c pElem5 = new vlocity_cmt__PricingElement__c(Name = 'MRC $50 Local Price', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 50.00,
                vlocity_cmt__Code__c = 'PELEM5', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = false, vlocity_cmt__PricingVariableId__c = pVarObjList[1].Id, vlocity_cmt__PriceListId__c = pl1.Id);
        vlocity_cmt__PricingElement__c pElem6 = new vlocity_cmt__PricingElement__c(Name = 'MRC $70 Standalone Discount', vlocity_cmt__ObjectTypeId__c = discObjType.Id, vlocity_cmt__AdjustmentValue__c = 70.00,
                vlocity_cmt__Code__c = 'PELEM6', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = pVarObjList[1].Id, vlocity_cmt__PriceListId__c = pl1.Id);
        sObjList.clear();
        sObjList.add(pElem1);
        sObjList.add(pElem2);
        sObjList.add(pElem3);
        sObjList.add(pElem4);
        sObjList.add(pElem5);
        sObjList.add(pElem6);
        dataMap.put('PELEM1', pElem1);
        dataMap.put('PELEM2', pElem2);
        dataMap.put('PELEM3', pElem3);
        dataMap.put('PELEM4', pElem4);
        dataMap.put('PELEM5', pElem5);
        dataMap.put('PELEM6', pElem6);

        insert sObjList;

        //List<vlocity_cmt__PricingElement__c> pricingElement = [Select Id, Name from vlocity_cmt__PricingElement__c];

        vlocity_cmt__PriceListEntry__c ple1 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod1.Id, vlocity_cmt__PricingElementId__c = pElem1.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
        sObjList.clear();
        sObjList.add(ple1);
        vlocity_cmt__PriceListEntry__c ple2 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod2.Id, vlocity_cmt__PricingElementId__c = pElem4.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
        sObjList.clear();
        sObjList.add(ple2);

        insert sObjList;
        sObjList.clear();

        //EPCPostInstallService.createDefaultPricingVariablesAndBindings();

        Account a = new Account(Name='Acct');
        insert a;

        vlocity_cmt__InterfaceImplementation__c iit1 = new vlocity_cmt__InterfaceImplementation__c (Name='PricingInterface');
        insert iit1;
        vlocity_cmt__InterfaceImplementationDetail__c iid1 = new vlocity_cmt__InterfaceImplementationDetail__c (Name = 'PricingElementServiceImplementation',
                vlocity_cmt__InterfaceId__c=iit1.Id, vlocity_cmt__IsActive__c=true);
        insert iid1;

        vlocity_cmt__InterfaceImplementation__c iit012 = new vlocity_cmt__InterfaceImplementation__c (Name='PricingInterface');
        insert iit012;
        vlocity_cmt__InterfaceImplementationDetail__c iit012_001 = new vlocity_cmt__InterfaceImplementationDetail__c
                (Name = 'PricingElementServiceImplementation', vlocity_cmt__InterfaceId__c=iit012.Id, vlocity_cmt__IsDefault__c=true,vlocity_cmt__IsActive__c=true);
        insert  iit012_001;

        vlocity_cmt__InterfaceImplementation__c iit = new vlocity_cmt__InterfaceImplementation__c (Name='ContextRuleService');
        insert iit;
        List<vlocity_cmt__InterfaceImplementationDetail__c> iidList = new List<vlocity_cmt__InterfaceImplementationDetail__c> ();
        vlocity_cmt__InterfaceImplementationDetail__c iit_001 = new vlocity_cmt__InterfaceImplementationDetail__c  (Name = 'ContextRuleService', vlocity_cmt__InterfaceId__c=iit.Id, vlocity_cmt__IsDefault__c=true,vlocity_cmt__IsActive__c=true);

        iidList.add(iit_001);
        insert iidList;     
        
        Order testOrder = new Order(Name='Test Order',EffectiveDate=System.today(),status='Draft',AccountId = a.Id, vlocity_cmt__PriceListId__c = pl1.Id, Pricebook2Id = Test.getStandardPricebookId());
        insert testOrder;
        
        vlocity_cmt__Promotion__c promotion = new vlocity_cmt__Promotion__c(Name = 'Spring Promo', vlocity_cmt__IsActive__c = true, vlocity_cmt__Code__c = 'SO');
        insert promotion;
        
        vlocity_cmt__PromotionItem__c promoItem1 = new vlocity_cmt__PromotionItem__c(Name='PromoItem1', vlocity_cmt__PromotionId__c = promotion.Id, vlocity_cmt__ProductId__c = prod1.Id);
        insert promoItem1;
        
        vlocity_cmt__OrderAppliedPromotion__c orderAppliedPromotion = new vlocity_cmt__OrderAppliedPromotion__c(vlocity_cmt__OrderId__c = testOrder.Id, Name = 'Test', vlocity_cmt__Action__c = 'Add',vlocity_cmt__promotionId__c=promotion.Id);
        insert orderAppliedPromotion;
        
        

        List<priceBookEntry> priceBookEntry = [Select Id from PricebookEntry where Product2Id =: prod1.Id];
        Id priceBookEntryId = priceBookEntry[0].Id;

        List<SObject> soList = new List<SObject>();

        OrderItem orderItem = new OrderItem();
        orderItem.OrderId = testOrder.Id;
        orderItem.PricebookEntryId = pbe1.Id;
        orderItem.Quantity = 1;
        orderItem.vlocity_cmt__LineNumber__c = '0001';
        orderItem.UnitPrice = 10;
        orderItem.vlocity_cmt__ProvisioningStatus__c = 'Active';
        soList.add(orderItem);

        OrderItem orderItem2 = new OrderItem();
        orderItem2.OrderId = testOrder.Id;
        orderItem2.PricebookEntryId = pbe2.Id;
        orderItem2.Quantity = 1;
        orderItem2.vlocity_cmt__LineNumber__c = '0002';
        orderItem2.UnitPrice = 20;
        orderItem2.vlocity_cmt__ProvisioningStatus__c = 'Active';
        soList.add(orderItem2);

        insert soList;
        soList.clear();
        
        vlocity_cmt__OrderAppliedPromotionItem__c orderAppliedPromotionItem = new vlocity_cmt__OrderAppliedPromotionItem__c(vlocity_cmt__OrderItemId__c = orderItem.Id, vlocity_cmt__OrderAppliedPromotionId__c = orderAppliedPromotion.Id, Name = 'Add');
        insert orderAppliedPromotionItem;
        
        /*
        vlocity_cmt__Rule__c conRuleSet = new vlocity_cmt__Rule__c(Name = 'CPQ Ruleset', vlocity_cmt__RuleType__c = 'Qualification');
        insert conRuleSet;
        vlocity_cmt__EntityFilter__c conRule1 = new vlocity_cmt__EntityFilter__c(Name ='CPQ Rule 1', vlocity_cmt__IsActive__c = true);
        vlocity_cmt__EntityFilter__c conRule2 = new vlocity_cmt__EntityFilter__c(Name ='CPQ Rule 2', vlocity_cmt__IsActive__c = true);
        insert conRule1;
        insert conRule2;
        vlocity_cmt__RuleAssignment__c conRuleSetObj1 = new vlocity_cmt__RuleAssignment__c(Name= 'CPQ Ruleset Obj', vlocity_cmt__RuleId__c = conRuleSet.Id, vlocity_cmt__ObjectId__c = ple1.Id);
        insert conRuleSetObj1;
        vlocity_cmt__RuleFilter__c conRuleSetRule1 = new vlocity_cmt__RuleFilter__c( vlocity_cmt__RuleId__c = conRuleSet.Id, vlocity_cmt__EntityFilterId__c = conRule1.Id);
        vlocity_cmt__RuleFilter__c conRuleSetRule2 = new vlocity_cmt__RuleFilter__c( vlocity_cmt__RuleId__c = conRuleSet.Id, vlocity_cmt__EntityFilterId__c = conRule2.Id);
        insert conRuleSetRule1;
        insert conRuleSetRule2;
        vlocity_cmt__EntityFilterCondition__c filtCon1 = new vlocity_cmt__EntityFilterCondition__c(vlocity_cmt__Code__c = 'FC01', vlocity_cmt__EntityFilterId__c = conRule1.Id, vlocity_cmt__FieldName__c = 'Channel__c', vlocity_cmt__Operator__c = '==', vlocity_cmt__Value__c = 'Web');
        vlocity_cmt__EntityFilterCondition__c filtCon2 = new vlocity_cmt__EntityFilterCondition__c(vlocity_cmt__Code__c = 'FC02', vlocity_cmt__EntityFilterId__c = conRule2.Id, vlocity_cmt__FieldName__c = 'Segment__c', vlocity_cmt__Operator__c = '==', vlocity_cmt__Value__c = 'Market');
        insert filtCon1;
        insert filtCon2;
        */
    }

    static private List<SObject> createObjects(String objectName, List<Map<String, Object>> pVarList) {
        String nsp = 'vlocity_cmt__';
        sObject sObj;
        List<SObject> sObjList = new List<SObject>();
        String objName = (objectName.endsWith('__c'))? nsp+objectName:objectName;
        for (Map<String, Object> pVarInfo : pVarList) {
            sObj = Schema.getGlobalDescribe().get(objName).newSObject();
            sObjList.add(sObj);
            for (String key : pVarInfo.keySet()) {
                if (!key.endsWith('__c')) {
                    sObj.put(key, pVarInfo.get(key));
                } else {
                    sObj.put(nsp + key, pVarInfo.get(key));
                }
            }
        }

        insert sObjList;
        return sObjList;
    }

    static testMethod void tightestMatchTest() {
        TestDataSetup();
        Test.startTest();

        List<vlocity_cmt__PriceList__c> plList = [SELECT Id FROM vlocity_cmt__PriceList__c];
        Id priceListId = plList[0].Id;
        
        List<Order> orderList = [SELECT Id, Name, vlocity_cmt__PriceListId__c, Pricebook2Id FROM Order];
        SObject parent = orderList[0];

        List<OrderItem> orderLI = [Select Id, PricebookEntry.Product2Id, PricebookEntry.Product2.Name from OrderItem where OrderId =: parent.Id order by vlocity_cmt__LineNumber__c];

        List<Product2> prodList = [SELECT Id FROM Product2];
        List<Id> prodIds = new List<Id>();
        for (Product2 prod : prodList) {
            prodIds.add(prod.Id);
        }

        Map<Id, Object> productIdToPriceCodeMap = new Map<Id, Object>();

        vlocity_cmt.FlowStaticMap.flowMap.put('Pricing.ProductIdToPriceCodeMap', productIdToPriceCodeMap);

        Integer i = 0;
        for (OrderItem oItem : orderLI)
        {
            Map<Id, Object> itemToPriceCodesMap = new Map<Id, Object>();
            productIdToPriceCodeMap.put(orderLI[i].PricebookEntry.Product2Id, itemToPriceCodesMap);
            Set<String> priceCodes = new Set<String>();
            if (oItem.PricebookEntry.Product2.Name == 'Prod1')
            {
                priceCodes.add('PELEM1');
            }
            else if (oItem.PricebookEntry.Product2.Name == 'Prod2')
            {
                priceCodes.add('PELEM4');
            }
            itemToPriceCodesMap.put(orderLI[i].Id, priceCodes);
            i++;
        }


        Datetime pricingDateTime = Datetime.now();


        ASKYTightestMatchServiceImpl tightestMatchService = new ASKYTightestMatchServiceImpl();
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        input.put('priceListId', priceListId);
        input.put('parent', parent);
        input.put('pricingDateTime', pricingDateTime);
        input.put('prodIds', prodIds);

        tightestMatchService.invokeMethod('TightestMatchPriceListEntries', input, output, options);
        List<vlocity_cmt__PriceListEntry__c> bestMatchPLEs = (List<vlocity_cmt__PriceListEntry__c>)output.get('bestMatchPLEs');

        Test.stopTest();

    }
    
    static testMethod void tightestMatchTestWithPromotionFilter() {
        TestDataSetup();
        Test.startTest();

        List<vlocity_cmt__PriceList__c> plList = [SELECT Id FROM vlocity_cmt__PriceList__c];
        Id priceListId = plList[0].Id;
        
        List<Order> orderList = [SELECT Id, Name, vlocity_cmt__PriceListId__c, Pricebook2Id FROM Order];
        SObject parent = orderList[0];
        
        
        List<OrderItem> orderLI = [Select Id from OrderItem where OrderId =: orderList[0].Id];
        
        
        List<Product2> prodList = [SELECT Id FROM Product2];
        List<Id> prodIds = new List<Id>();
        for (Product2 prod : prodList) {
            prodIds.add(prod.Id);
        }
        
        List<vlocity_cmt__Promotion__c> promotions = [Select Id from vlocity_cmt__Promotion__c];
        
        List<vlocity_cmt__OrderAppliedPromotionItem__c> orderAppliedPromoItem = [Select Id, vlocity_cmt__OrderAppliedPromotionId__c from vlocity_cmt__OrderAppliedPromotionItem__c where vlocity_cmt__OrderItemId__c =: orderLI[0].Id];

        Map<Id, List<Object>> itemIdToListAppliedPromoMap = new Map<Id, List<Object>>();
        Map<Id, List<Id>> prodIdToListItemIdMap = new Map<Id, List<Id>>();
        
        List<Id> itemIds = new List<Id>();
        itemIds.add(orderList[0].Id);
        prodIdToListItemIdMap.put(prodIds[0], itemIds);
        
        List<Object> promoList = new List<Object>();
        Map<String, Object> infoMap = new Map<String, Object>();
        infoMap.put('AppliedPromotionId', orderAppliedPromoItem[0].vlocity_cmt__OrderAppliedPromotionId__c);
        infoMap.put('PromotionId', promotions[0].Id);
        promoList.add(infoMap);
       
        itemIdToListAppliedPromoMap = getItemPromotionInfo(new List<Id>{orderList[0].Id});
        
        Datetime pricingDateTime = Datetime.now();


        ASKYTightestMatchServiceImpl tightestMatchService = new ASKYTightestMatchServiceImpl();
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        input.put('priceListId', priceListId);
        input.put('parent', parent);
        input.put('pricingDateTime', pricingDateTime);
        input.put('prodIds', prodIds);
        
        Map<Id,Set<Id>> prodIdToAppliedPromotions = new Map<Id,Set<Id>>();
        for(Id prodId : prodIdToListItemIdMap.keySet())
        {
            List<Id> itemIdList = prodIdToListItemIdMap.get(prodId);
            for(Id itemId : itemIdList)
            {
                List<Object> appliedPromotionList = itemIdToListAppliedPromoMap.get(itemId);
                if(appliedPromotionList != null)
                {
                    for(Object appliedPromotion : appliedPromotionList)
                    {
                        Map<String, Object> promoObj = (Map<String, Object>)appliedPromotion;
                        if(prodIdToAppliedPromotions.get(prodId) == null)
                        {
                            Set<Id> promotionList = new Set<Id>();
                            promotionList.add((Id)promoObj.get('PromotionId'));
                            prodIdToAppliedPromotions.put(prodId, promotionList);
                        }
                        else
                        {
                            Set<Id> promotionList = prodIdToAppliedPromotions.get(prodId);
                            promotionList.add((Id)promoObj.get('PromotionId'));
                            prodIdToAppliedPromotions.put(prodId, promotionList);
                        }
                    }
                }   
            }   
        }
        
        input.put('prodIdToAppliedPromotions',prodIdToAppliedPromotions);

        tightestMatchService.invokeMethod('TightestMatchPriceListEntries', input, output, options);
        List<vlocity_cmt__PriceListEntry__c> bestMatchPLEs = (List<vlocity_cmt__PriceListEntry__c>)output.get('bestMatchPLEs');

        Test.stopTest();

    }

     static testMethod void ASkyPriceElemCtxTest() {
        TestDataSetup();
        Test.startTest();
        ASkyPriceElementsCtxImpl priceElemCtxService = new ASkyPriceElementsCtxImpl();
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<ID, Boolean> mapPle = new Map<ID, Boolean>();
        List<Vlocity_cmt__PricingElement__c> pList = [SELECT id, Vlocity_cmt__PriceListId__c FROM Vlocity_cmt__PricingElement__c LIMIT 10];
        for( Vlocity_cmt__PricingElement__c pl : pList)
            mapPle.put(pl.id, true);
        input.put('ObjectId', 'test');
        input.put('ObjectList', pList);
        input.put('eligibilityContextString', 'test');
        output.put('RuleExistsMap', mapPle);

        priceElemCtxService.invokeMethod( 'getAllEligibilityPricingElements', input, null, options );
        
        priceElemCtxService.invokeMethod( 'getAllEligibilityPricingElements', input, output, options );

        EncryptionService.generateRandomKey(3);
        Test.stopTest();
     }

    private static Id getRecordTypeId(String objectName, String recordTypeName) {
        System.debug('getRecordTypeId: '+objectName+ ', '+recordTypeName);
        List<String> types = new List<String>();
        types.add(objectName);
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(types);
        Map<String,Schema.RecordTypeInfo> rtMapByName = results[0].getRecordTypeInfosByName();
        System.debug('rtMapByName: '+rtMapByName);
        Id recTypeId = rtMapByName.get(recordTypeName).getRecordTypeId();
        System.debug('recTypeId: '+recTypeId);
        return recTypeId;       
    }

    private static Map<Id, List<Object>> getItemPromotionInfo(List<Id> itemIds)
    {
        Map<Id, List<Object>> result = new Map<Id, List<Object>>();
        if (itemIds == null || itemIds.isEmpty()) return result;
        SObjectType soType = itemIds[0].getSObjectType();
        String objectName = soType.getDescribe().getName();
        String appliedPromoItemObjName = 'vlocity_cmt__OrderAppliedPromotionItem__c';
        String itemIdField = 'vlocity_cmt__OrderItemId__c';
        String appliedPromoObjName = 'vlocity_cmt__OrderAppliedPromotion__c';
        String appliedPromoObjRel = 'vlocity_cmt__OrderAppliedPromotionId__r';
        for (SObject appliedPromoItemObj : queryAppliedPromotions(itemIds, appliedPromoItemObjName, itemIdField, appliedPromoObjName, appliedPromoObjRel))
        {
            Id itemId = (Id)appliedPromoItemObj.get(itemIdField);
            if (itemId != null)
            {
                List<Object> appliedPromoList = result.get(itemId);
                if (appliedPromoList == null)
                {
                    appliedPromoList = new List<Object>();
                    result.put(itemId, appliedPromoList);
                }
                SObject appliedPromoObj = appliedPromoItemObj.getSObject(appliedPromoObjRel);
                if (appliedPromoObj != null)
                {
                    SObject promoObj = appliedPromoObj.getSObject('vlocity_cmt__PromotionId__r');
                    if (promoObj != null)
                    {
                        Map<String, Object> infoMap = new Map<String, Object>();
                        infoMap.put('AppliedPromotionId', appliedPromoObj.Id);
                        infoMap.put('Sequence', appliedPromoList.size() + 1);
                        infoMap.put('PromotionId', promoObj.Id);
                        infoMap.put('PromotionName', promoObj.get('Name'));
                        infoMap.put('PromotionGlobalKey', promoObj.get('GlobalKey__c'));
                        appliedPromoList.add(infoMap);
                    }
                }
            }
        }
        return result;
    }

    private static List<SObject> queryAppliedPromotions(List<Id> itemIds, String appliedPromoItemObj, String itemIdField,
                                                        String appliedPromoObjName, String appliedPromoObjRel)
    {
        List<SObject> result = new List<sObject>();

        if (appliedPromoItemObj != null && itemIdField != null)
        {
            List<String> defaultQueryFields = getAppliedPromotionFieldsList(itemIdField, appliedPromoObjRel);
            String joinFields = String.join(defaultQueryFields,',');
            String sQuery = 'SELECT ' +  joinFields + ' FROM ' + appliedPromoItemObj
                + ' WHERE ' + itemIdField + ' in :itemIds ' +  ' ORDER BY CreatedDate';

            System.debug('queryAppliedPromotions itemIds: ' + JSON.serialize(itemIds));
            return database.query(sQuery);
        }
        return result;
    }

    private static List<String> getAppliedPromotionFieldsList(String itemIdField, String appliedPromoObjRel)
    {
        String appliedPromoObjIdField = appliedPromoObjRel.replace('__r','__c');
        return new List<String>{
            'Id', 'Name',
            'vlocity_cmt__AppliedAction__c',
            'vlocity_cmt__MaxQuantity__c',
            'vlocity_cmt__MinQuantity__c',
            itemIdField,
            appliedPromoObjIdField,
            appliedPromoObjRel + '.Id',
            appliedPromoObjRel + '.vlocity_cmt__Action__c',
            appliedPromoObjRel + '.vlocity_cmt__PromotionId__c',
            appliedPromoObjRel + '.vlocity_cmt__PromotionId__r.Id',
            appliedPromoObjRel + '.vlocity_cmt__PromotionId__r.Name',
            appliedPromoObjRel + '.vlocity_cmt__PromotionId__r.vlocity_cmt__GlobalKey__c'
            };
    }
     static testMethod void tightestMatchNPPTest() {

        List<SObject> sObjList = new List<SObject>();

        Product2 prod1 = new Product2 (Name='Prod1');
        sObjList.add(prod1);

        Product2 prod2 = new Product2 (Name='Prod2');
        sObjList.add(prod2);
        insert sObjList;
        sObjList.clear(); 
        Pricebook2 standardBook =  new Pricebook2(Id = Test.getStandardPricebookId(), Name = 'TestPricebook', IsActive = true);

        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = standardBook.Id,
        Product2Id = prod1.Id, UnitPrice = 10, vlocity_cmt__RecurringPrice__c = 5, IsActive = true, UseStandardPrice = false);
        sObjList.add(pbe1);

        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = standardBook.Id,
            Product2Id = prod2.Id, UnitPrice = 20, vlocity_cmt__RecurringPrice__c = 10, IsActive = true, UseStandardPrice = false);
        sObjList.add(pbe2);

        insert sObjList;
        vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c(vlocity_cmt__Pricebook2Id__c = standardBook.Id, vlocity_cmt__IsActive__c = true,
                                                                      vlocity_cmt__Code__c = 'Listino_Sky_NPP');
        insert pl1;
        
        Account a = new Account(Name='Acct');
        insert a;
        
        List<Asset> assetList= new List<Asset>();
        Asset ast1= new Asset();
        ast1.Name = prod1.Name;
        ast1.Product2Id = prod1.Id;
        ast1.vlocity_cmt__PricebookEntryId__c = pbe1.Id;
        ast1.vlocity_cmt__PriceListId__c = pl1.Id; 
        ast1.AccountId = a.Id;
        assetList.add(ast1);
        Asset ast2= new Asset();
        ast2.Name = prod2.Name;
        ast2.Product2Id = prod2.Id;
        ast2.vlocity_cmt__PricebookEntryId__c = pbe2.Id;
        ast2.vlocity_cmt__PriceListId__c = pl1.Id; 
        ast2.AccountId = a.Id;
        assetList.add(ast2);
        
        insert assetList;
         
        ASKYTightestMatchServiceImpl tightestMatchService = new ASKYTightestMatchServiceImpl();
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        input.put('parent', a);
        input.put(CPQ_Utility.STRING_ITEMLIST, assetList);

        tightestMatchService.invokeMethod('TightestMatchPriceListEntries', input, output, options);
       
     }    
         

}
