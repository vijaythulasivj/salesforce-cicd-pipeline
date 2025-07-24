global with sharing class ASKYTightestMatchServiceImpl implements vlocity_cmt.VlocityOpenInterface
{

    private final static String CLASS_NAME =  ASKYTightestMatchServiceImpl.class.getName();
    private static Map<String, String> contractTraitToPriceListMap;
    public static final String TIGHTEST_MATCH_METHOD = 'TightestMatchPriceListEntries';

    static
    {
        contractTraitToPriceListMap = new Map<String, String>
        {
            'FreeVIP' => 'Free VIP',
            'MV Unico U2' => 'MV Unico U2',
            'Dipendente' => 'Dipendenti',
            'Collaboratore' => 'Collaboratori',
            'Experience' => 'Experience KIT',
            'Free' => 'Free',
            'Old' => 'Old Pricelist',
            'SalesPartner' => 'Sales Partner'
        };
    }


    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)
    {
        try{ 
        Boolean toRet=true;
        Boolean price=false;
        String currentMethodName = 'invokeMethod';
        CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' ---- START');
        system.debug('## SPE 1371 in ASKYTightestMatchServiceImpl input before :  '+input);
        system.debug('## SPE 1371 in ASKYTightestMatchServiceImpl output before:  '+output);
        if (TIGHTEST_MATCH_METHOD.equalsIgnoreCase(methodName))
        {
            Id priceListId = (Id)input.get(CPQ_Utility.STRING_PRICELISTID);
            SObject parent = (SObject)input.get(CPQ_Utility.STRING_PARENT);
            Datetime pricingDateTime = (Datetime)input.get(CPQ_Utility.STRING_PRICINGDATETIME);
            List<Id> prodIds = (List<Id>)input.get(CPQ_Utility.STRING_PRODIDS);
            Map<Id, Set<Id>> prodIdToAppliedPromotions = (Map<Id, Set<Id>>)input.get(CPQ_Utility.STRING_PRODIDTOAPPLIEDPROMOTIONS);
                system.debug('input'+input);
                if(parent!=null){
                  String priceListName='';
                  String parentObjName = parent.getSObjectType().getDescribe().getName();
                  if(String.isNotBlank(priceListId)){
                    priceListName = CPQ_Utility.getPricelistName(new vlocity_cmt__PriceList__c(id=priceListId));
                  }
                  else if('Account'.equalsIgnoreCase(parentObjName)){
                    list<SObject> itemlist=(list<SObject>)input.get(CPQ_Utility.STRING_ITEMLIST);
                    priceListName = CPQ_Utility.getPricelistName((SObject)itemlist?.get(0));
                  }
                  else{
                    priceListName = CPQ_Utility.getPricelistName(parent);   
                    } 
                 System.debug('::::priceListName::::' +priceListName);
                 if('Listino_Sky_NPP'.equalsIgnoreCase(priceListName)){
                      System.debug('::::Call Standard Start::::');
                      CpqAppHandlerHook.contextRuleServiceMap.put( CPQ_Utility.CURRENT_ORDER_MAP_KEY, parent.Id);
                      vlocity_cmt.VOIInvoker invoker2 = vlocity_cmt.VOIInvoker.getInstance();
                      vlocity_cmt.VlocityOpenInterface voi2 = (vlocity_cmt.VlocityOpenInterface)invoker2.invoke('TightestMatchServiceImplementation', 'debugCreate', null, null, null);
                      price = true;
                      toRet = voi2.invokeMethod(methodName ,input, output, output);
                      System.debug('::::Call Standard End::::');
                  }
                }
           if(!price){
                System.debug('::::Call Custom Start::::');
            getTightestMatchPriceListEntries(pricingDateTime, prodIds, parent, priceListId, prodIdToAppliedPromotions, input,
                                             output); //LM Added input for SPE-387, SPE-391
            }
            CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' ---- END');
            return true;
        }
        if (CPQ_Utility.IS_LOGGING_ENABLED)
        {
            CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' ASKYTightestMatchServiceImpl output: ' + JSON.serialize(output));
        }
        output.put('Error', 'Unsupported method name: ' + methodName);
        CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' ---- END');
        system.debug('## SPE 1371 in ASKYTightestMatchServiceImpl input after :  '+input);
        system.debug('## SPE 1371 in ASKYTightestMatchServiceImpl output after:  '+output);
        return false;
        }catch(exception e){
            system.debug(':::ASKYTightestMatchServiceImpl.'+methodName+':::');
            system.debug(e.getMessage());
            return false;
        }
    }


    public void getTightestMatchPriceListEntries(Datetime pricingDateTime, List<Id> prodIds, SObject parent, Id priceListId,
            Map<Id, Set<Id>> prodIdToAppliedPromotions, Map<String, Object> input,
            Map<String, Object> output)   //LM Added Map input for SPE-387, SPE-391
    {
        String currentMethodName = 'getTightestMatchPriceListEntries';
        CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' ---- START');
        try
        {
            Datetime effectiveFromDt = pricingDateTime;
            Map<String, Object> inputMap = new Map<String, Object>();
            inputMap.put(CPQ_Utility.STRING_PRODUCTIDS, prodIds);
            inputMap.put(CPQ_Utility.STRING_EFFECTIVEFROMDATE, effectiveFromDt);
            Map<String, Object> options = new Map<String, Object>();
            Cpq_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' inputMap: ' + Json.serialize(input));
            Cpq_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' inputMap.get(itemIdToAppliedPromotions): ' + inputMap.get('itemIdToAppliedPromotions'));
            system.debug('inputMap: ' + input);
            system.debug('inputMap.get(itemIdToAppliedPromotions): ' + inputMap.get('itemIdToAppliedPromotions'));
            // [051119] AL V3 perf START
            if(input.containsKey('parent')){
                SObject orderParent = (SObject)input.get('parent');
                if(orderParent != null){
                    String objType = orderParent.Id.getSObjectType().getDescribe().getName();
                    System.debug('objType: ' + objType);
                    if(objType.equals('Order')){
                        System.debug('OrderId: ' + orderParent.Id);
                        CpqAppHandlerHook.contextRuleServiceMap.put( CPQ_Utility.CURRENT_ORDER_MAP_KEY, orderParent.Id); 
                    }          
                }
            }
            // [051119] AL V3 perf END
            // BEGIN: Hard-coded PriceList context rule
            /*String contractTrait;
            SObject parentObj = Database.query('SELECT Id, ContractId, Contract.Contract_Trait__c FROM ' + parent.Id.getSObjectType() +
                ' WHERE Id =\'' + parent.Id + '\' LIMIT 1');

            if (parentObj != null)
            {
                SObject cont = parentObj.getSObject(CPQ_Utility.STRING_CONTRACT);
                if (cont != null)
                {
                    contractTrait = (String)cont.get(CPQ_Utility.STRING_CONTRACT_TRAIT);
                }
            }*/
            //Added for Cache - START
            String contractTrait = (String)CpqAppHandlerHook.contextRuleServiceMap.get(
                                       CPQ_Utility.CURRENT_CONTRACT_TRAIT_MAP_KEY); //Commented for Cache
            /*Cache.SessionPartition sessionPart = Cache.Session.getPartition( CPQ_Utility.CACHE_PARTITION_NAME );
            String contractTrait = ( String ) sessionPart.get( CPQ_Utility.CURRENT_CONTRACT_TRAIT_MAP_KEY );*/
            //Added for Cache - END
            Cpq_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' contractTrait from contextRuleServiceMap: ' + contractTrait);
            //CONTRACT TRAIT RETENTION = STANDARD
            If(contractTrait != null && contractTrait.equalsIgnoreCase(CPQ_Utility.STRING_LISTINO_RETENTION))
            {
                contractTrait = CPQ_Utility.STRING_LISTINO_STANDARD;
            }

            Map<String, Id> priceListNameToIdMap = new Map<String, Id>();
            // Get Child PriceLists
            List<vlocity_cmt__PriceList__c> initialChildPLs = [SELECT Id, Name,
                                            vlocity_cmt__ParentPriceListId__c FROM vlocity_cmt__PriceList__c WHERE vlocity_cmt__ParentPriceListId__c = : priceListId];
            for (vlocity_cmt__PriceList__c prclst : initialChildPLs)
            {
                priceListNameToIdMap.put(prclst.Name, prclst.Id);
            }
            Id childPLId;
            if (String.isNotBlank(contractTrait))
            {
                String plName = contractTraitToPriceListMap.get(contractTrait);
                if (String.isNotBlank(plName))
                {
                    childPLId = priceListNameToIdMap.get(plName);
                }
                CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' ---childPLId: ' + childPLId + ' childPLName: ' + plName);
            }

            Map<Id, String> mapPLToWeights = new Map<Id, String>();
            //Make list of qualified PriceLists, children and parent
            List<Id> initialPLs = new List<Id> {priceListId};
            if (childPLId != null)
            {
                initialPLs.add(childPLId);
            }
            inputMap.put(CPQ_Utility.STRING_PRICELISTIDS, initialPLs);
            Set<Id> promotionIds;
            //SPE-387, flag to filter ples by promotion only if the promotionid is passed by the caller
            Boolean filterByPromoIdsOnly = false;
            if (prodIdToAppliedPromotions != null && !prodIdToAppliedPromotions.isEmpty())
            {
                promotionIds = new Set<Id>();
                for (Id key : prodIdToAppliedPromotions.keySet())
                {
                    promotionIds.addAll(prodIdToAppliedPromotions.get(key));
                }
            }

            //start: SPE-458
            Map<Id, Set<Id>> itemIdToAppliedPromotions = (Map<Id,Set<Id>>)input.get('itemIdToAppliedPromotions');
            if (itemIdToAppliedPromotions != null && !itemIdToAppliedPromotions.isEmpty()){
                if (promotionIds == null)
                {
                    promotionIds = new Set<Id>();
                }
                for (Id key : itemIdToAppliedPromotions.keySet())
                {
                    promotionIds.addAll(itemIdToAppliedPromotions.get(key));
                }
            }
            //end: SPE-458

            //LM added START SPE-387
            List<Id> promoIds = (List<Id>)input.get('promotionIds');
            if (promoIds != null && !promoIds.isEmpty())
            {
                filterByPromoIdsOnly = true;
                if (promotionIds == null) promotionIds = new Set<Id>();
                promotionIds.addAll(promoIds);
            }
            inputMap.put('filterByPromoIdsOnly', filterByPromoIdsOnly);
            //LM added END
            if (promotionIds != null)
            {
                inputMap.put(CPQ_Utility.STRING_PROMOTIONIDS, new List<Id>(promotionIds));
            }
            // SC VLOCITY 15062020 START
            Set<Id> assetIdList = new Set<Id>();
            Boolean isAsset = false;
            List<SObject> itemList = (List<SObject>)input.get('itemList');
            if (itemList != null && !itemList.isEmpty())
            {
                if(itemList[0].getsobjecttype().getDescribe().getName() == 'Asset'){
                    isAsset = true;
                    for(Asset a : (List<Asset>)itemList){
                        assetIdList.add((String)a.Id);
                    }// SC VLOCITY 03072020 START
                    DateTime nowDate = DateTime.now();
                    List<vlocity_cmt__AccountPriceAdjustment__c> priceAdjByAssetList = [SELECT Id, vlocity_cmt__PriceListEntryId__c FROM vlocity_cmt__AccountPriceAdjustment__c WHERE vlocity_cmt__AssetId__c IN :assetIdList AND (vlocity_Cmt__EffectiveStartDate__c <= :nowDate OR vlocity_Cmt__EffectiveStartDate__c = NULL) AND (vlocity_Cmt__EffectiveEndDate__c >= :nowDate OR vlocity_Cmt__EffectiveEndDate__c = NULL)];
                    // SC VLOCITY 03072020 END
                    Set<Id> pleByAssetIds = new Set<Id>();
                    for(vlocity_cmt__AccountPriceAdjustment__c apAdj : priceAdjByAssetList){
                        pleByAssetIds.add(apAdj.vlocity_cmt__PriceListEntryId__c);
                    }
                    inputMap.put('pleByAssetIds', pleByAssetIds);
                    inputMap.put('isAsset', isAsset);
                }
            }
            // SC VLOCITY 15062020 END

            //Get all PriceListElements from all qualified PriceLists (children and parent PL)
            if (CPQ_Utility.IS_LOGGING_ENABLED) { CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' getPriceListEntries inputMap: ' + JSON.serialize(inputMap)); }

            Map<Id, SObject> initialPLEs = getPriceListEntries(inputMap, options);

            if (CPQ_Utility.IS_LOGGING_ENABLED) { CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' getTightestMatchPriceListEntries initialPLEs: ' + JSON.serialize(initialPLEs));}

            /* ---- BEGIN SOLUTION 1 ------- */
            Map<Id, Object> productIdToPriceCodeMap = (Map<Id, Object>)vlocity_cmt.FlowStaticMap.flowMap.get(
                        CPQ_Utility.STRING_PRODUCTIDTOPRICECODEMAP);
            if (CPQ_Utility.IS_LOGGING_ENABLED) { CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' productIdToPriceCodeMap2:' + JSON.serialize(productIdToPriceCodeMap)); }

            // Map of item Id to List of PLE Ids
            Map<Id, Map<String, Set<Id>>> itemIdToPLEIds = new Map<Id, Map<String, Set<Id>>>();
            List<SObject> pleToProcess;
            Map<Id, SObject> pleProcessed;
            if (productIdToPriceCodeMap != null && !productIdToPriceCodeMap.isEmpty())
            {
                pleToProcess = new List<SObject>();
                pleProcessed = new Map<Id, SObject>();

                for (SObject pleObj : initialPLEs.values())
                {
                    Boolean bSkip = false;
                    vlocity_cmt__PriceListEntry__c ple = (vlocity_cmt__PriceListEntry__c)pleObj;
                    CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' productId: ' + ple.vlocity_cmt__ProductId__c + ' productName: ' +
                                    ple.vlocity_cmt__ProductId__r.Name);
                    Map<Id, Object> itemToPriceCodesMap = (Map<Id, Object>)productIdToPriceCodeMap.get(ple.vlocity_cmt__ProductId__c);
                    CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' itemToPriceCodesMap: ' + itemToPriceCodesMap);
                    if (itemToPriceCodesMap != null && !itemToPriceCodesMap.isEmpty())
                    {
                        for (Id itemId : itemToPriceCodesMap.keySet())
                        {
                            Set<String> priceCodes = (Set<String>)itemToPriceCodesMap.get(itemId);
                            CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' priceCodes: ' + priceCodes);
                            CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' ple priceCode: ' +
                                            ple.vlocity_cmt__PricingElementId__r.vlocity_cmt__Code__c);
                            if (priceCodes != null && priceCodes.contains(ple.vlocity_cmt__PricingElementId__r.vlocity_cmt__Code__c))
                            {
                                String priceVarCode = ple.vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableId__r.vlocity_cmt__Code__c;
                                CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' ple priceVarCode: ' +
                                                ple.vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableId__r.vlocity_cmt__Code__c);
                                Map<String, Set<Id>> varCodeToPLEMap = (Map<String, Set<Id>>)itemIdToPLEIds.get(itemId);
                                if (varCodeToPLEMap == null)
                                {
                                    varCodeToPLEMap = new Map<String, Set<Id>>();
                                    itemIdToPLEIds.put(itemId, varCodeToPLEMap);
                                }
                                Set<Id> pleIds = varCodeToPLEMap.get(priceVarCode);
                                if (pleIds == null)
                                {
                                    pleIds = new Set<Id>();
                                    varCodeToPLEMap.put(priceVarCode, pleIds);
                                }
                                pleIds.add(ple.Id);
                                pleProcessed.put(ple.Id, ple);
                                bSkip = true;
                                CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' skipping ple: ' + ple.Id + ' priceVarCode: ' + priceVarCode);
                            }
                        }
                    }
                    if (!bSkip)
                    {
                        // This is not a ple we are tracking, so we will send it to the context rule service.
                        pleToProcess.add(ple);
                    }
                }
            }
            else { pleToProcess = initialPLEs.values(); }
            if (!itemIdToPLEIds.isEmpty())
            {
                output.put('itemIdToPLEIds', itemIdToPLEIds);
                if (CPQ_Utility.IS_LOGGING_ENABLED) { CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' itemIdToPLEsMap:' + JSON.serialize(itemIdToPLEIds)); }
            }

            CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' pleToProcess:' + pleToProcess);
            /* ---- END SOLUTION 1 ------- */

            // SPE-392 Determine which PLEs have context rules and only send those to the context rule service. PLEs with no rules are pre-qualified.
            Map<Id, SObject> pleToProcessMap = (pleToProcess != null
                                                && !pleToProcess.isEmpty()) ? (new Map<Id, sObject>(pleToProcess)) : (new Map<Id, sObject>());
            List<SObject> preQualifiedPLEs = new List<SObject>();
            List<SObject> pleInputForRules = getPriceListEntriesWithRules(pleToProcessMap, preQualifiedPLEs);
            // Filter the pricing elements by context rules
            vlocity_cmt.CtxRulesPriceElementsOpenImplementation ctxRuleService = new vlocity_cmt.CtxRulesPriceElementsOpenImplementation();
  
            Map<String, Object> ruleInput = new Map<String, Object>();
            Map<String, Object> ruleOutput = new Map<String, Object>();
            Map<String, Object> ruleOptions = new Map<String, Object>();

            // SPE-392 Call the context rule service only for PLEs with context rules.
            List<SObject> qualifiedPLEs;
            Set<Id> qualifiedPLEIds = new Set<Id>();
            if (pleInputForRules != null && !pleInputForRules.isEmpty())
            {
                ruleInput.put(CPQ_Utility.STRING_OBJECTID, parent.Id);
                ruleInput.put(CPQ_Utility.STRING_OBJECTLIST, pleInputForRules);
                ctxRuleService.invokeMethod('getAllEligibilityPricingElements', ruleInput, ruleOutput, ruleOptions);
                qualifiedPLEs = (List<SObject>)ruleOutput.get(CPQ_Utility.STRING_PASSLIST);
            }

            // SPE-392 Ensure this list is initialized if it was not returned from the context rule service
            if (qualifiedPLEs == null) qualifiedPLEs = new List<SObject>();

            // SPE-392 Add the preQualifiedPLEs to the context service qualified ones if any.
            qualifiedPLEs.addAll(preQualifiedPLEs);

            if (pleProcessed != null && !pleProcessed.isEmpty())
            {
                qualifiedPLEs.addAll(pleProcessed.values());
            }
            //Map qualified PriceListEntries to rule weights
            Map<Id, String> mapPLEToWeights = (Map<Id, String>)ruleOutput.get(CPQ_Utility.STRING_OBJECTWEIGHTMAP);

            // SPE-392 mapPLEToWeights could be null if we skipped calling the context rule service, check and initialize here
            if (mapPLEToWeights == null) mapPLEToWeights = new Map<Id, String>();

            //create helper map of priceListEntry ID to priceListEntry obj
            Map<Id, vlocity_cmt__PriceListEntry__c> mapPLEIdToPLE = new Map<Id, vlocity_cmt__PriceListEntry__c>();
            for (SObject qualifiedPLEObj : qualifiedPLEs)
            {
                vlocity_cmt__PriceListEntry__c qualifiedPLE = (vlocity_cmt__PriceListEntry__c) qualifiedPLEObj;
                mapPLEIdToPLE.put(qualifiedPLE.Id, qualifiedPLE);
            }
            //Compute rule weights from PL and PLEs
            Map<Id, Integer> fullWeightMap = new Map<Id, Integer>();
            for (vlocity_cmt__PriceListEntry__c ple : mapPLEIdToPLE.values())
            {
                Integer wt = 0;
                if (mapPLToWeights.containsKey(ple.vlocity_cmt__PriceListId__c))
                {
                    wt += Integer.valueOf(mapPLToWeights.get(ple.vlocity_cmt__PriceListId__c));
                }
                if (mapPLEToWeights.containsKey(ple.Id) && mapPLEToWeights.get(ple.Id) != null)
                {
                    wt += Integer.valueOf(mapPLEToWeights.get(ple.Id));
                }
                fullWeightMap.put(ple.Id, wt);
            }
            //Map Product ID to PLEs
            Map<Id, List<vlocity_cmt__PriceListEntry__c>> mapProdIdToPLEs = new Map<Id, List<vlocity_cmt__PriceListEntry__c>>();
            for (SObject qualifiedPLEObj : qualifiedPLEs)
            {
                vlocity_cmt__PriceListEntry__c qualifiedPLE = (vlocity_cmt__PriceListEntry__c) qualifiedPLEObj;
                if (mapProdIdToPLEs.containsKey(qualifiedPLE.vlocity_cmt__ProductId__c))
                {
                    List<vlocity_cmt__PriceListEntry__c> prodPLEList = (List<vlocity_cmt__PriceListEntry__c>)mapProdIdToPLEs.get(
                                qualifiedPLE.vlocity_cmt__ProductId__c);
                    prodPLEList.add(qualifiedPLE);
                    mapProdIdToPLEs.put(qualifiedPLE.vlocity_cmt__ProductId__c, prodPLEList);
                }
                else
                {
                    mapProdIdToPLEs.put(qualifiedPLE.vlocity_cmt__ProductId__c, new List<vlocity_cmt__PriceListEntry__c> { qualifiedPLE });
                }
            }
            //For each ProductId, go through PLE list and get best match
            Map<Id, Map<Id, List<vlocity_cmt__PriceListEntry__c>>> mapProdPvBestPle = new Map<Id, Map<Id, List<vlocity_cmt__PriceListEntry__c>>>();
            // SPE-391 collect virtualPLEProductIds
            Set<Id> virtualPLEProductIds = new Set<Id>();

            for (Id prodId : mapProdIdToPLEs.keySet())
            {
                List<vlocity_cmt__PriceListEntry__c> prodPLEs = (List<vlocity_cmt__PriceListEntry__c>)mapProdIdToPLEs.get(prodId);
                if (prodPLEs != null)
                {

                    //For each PLE for this product, Map PricingVariable to PLEs (This groups together One-Time, Recurring, etc)
                    Map<Id, List<vlocity_cmt__PriceListEntry__c> > mapPricingVariableToBestPLE = new Map<Id, List<vlocity_cmt__PriceListEntry__c> >();
                    for (vlocity_cmt__PriceListEntry__c prodPLE : prodPLEs)
                    {
                        if (!prodPLE.vlocity_cmt__IsVirtualPrice__c && prodPLE.vlocity_cmt__PricingElementId__c != null)
                        {
                            //HYB-1950, if a product has an active promotion and if this is not applied through a promo, that PLE was chosen,
                            //adding a check for the PLE to verfiy if it was added via a promotion or not
                            Boolean isPLEApplicable = true;
                            if (prodIdToAppliedPromotions != null)
                            {
                                isPLEApplicable = isPLEApplicable(prodId, prodPLE, prodIdToAppliedPromotions);
                            }
                            if (!isPLEApplicable)
                            {
                                continue;
                            }
                            Id pricingVarId = prodPLE.vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableId__c;
                            if (mapPricingVariableToBestPLE.containsKey(pricingVarId))
                            {
                                List<vlocity_cmt__PriceListEntry__c> curBestPLEList = mapPricingVariableToBestPLE.get(pricingVarId);
                                vlocity_cmt__PriceListEntry__c curBestPLE = curBestPLEList[0];

                                //If curBestPLE weight is less than prodPLE, set tighest match to prodPLE
                                if (fullWeightMap.get(curBestPLE.Id) < fullWeightMap.get(prodPLE.Id))
                                {
                                    mapPricingVariableToBestPLE.put(pricingVarId, new List<vlocity_cmt__PriceListEntry__c> {prodPLE});
                                }
                                //keeping all the pricelist entries with equal weight
                                else if (fullWeightMap.get(curBestPLE.Id) == fullWeightMap.get(prodPLE.Id))
                                {
                                    curBestPLEList.add(prodPLE);
                                }


                            }
                            else
                            {
                                mapPricingVariableToBestPLE.put(pricingVarId, new List<vlocity_cmt__PriceListEntry__c> {prodPLE});
                            }
                        }
                        // SPE-391 collect virtual prices
                        if (prodPLE.vlocity_cmt__IsVirtualPrice__c)
                        {
                            virtualPLEProductIds.add(prodPLE.vlocity_cmt__ProductId__c);
                        }
                    }

                    //mapProdPvPle.put(prodId, mapPricingVariableToPLEs);
                    mapProdPvBestPle.put(prodId, mapPricingVariableToBestPLE);
                }
            }
            // Get simple list of best matched PLEs by flattening map
            List<vlocity_cmt__PriceListEntry__c> bestMatchPLEs = new List<vlocity_cmt__PriceListEntry__c>();
            for (Id key : mapProdPvBestPle.keySet())
            {
                Map<Id, List<vlocity_cmt__PriceListEntry__c> > pvBestPle = mapProdPvBestPle.get(key);
                for (Id key2 : pvBestPle.keySet())
                {
                    bestMatchPLEs.addAll(pvBestPle.get(key2));
                }
            }
            CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' ---- END');
            output.put('bestMatchPLEs', bestMatchPLEs);
            output.put('virtualPLEProductIds', virtualPLEProductIds); // SPE-391 return virtualPLEProductIds
            return;
        }
        catch (Exception ex)
        {
            throw new ASKYTightestMatchServiceImplException(ex + ' ' + ex.getStackTraceString());
        }
    }
    public Boolean isPLEApplicable(Id prodId, vlocity_cmt__PriceListEntry__c prodPLE, Map<Id, Set<Id>> prodIdToAppliedPromotions)
    {
        String currentMethodName = 'isPLEApplicable';
        CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' ---- START');
        Id currentPromoId = prodPLE.vlocity_cmt__PromotionId__c;
        Set<Id> allAppliedPromotions;
        if (prodIdToAppliedPromotions != null)
        {
            allAppliedPromotions = prodIdToAppliedPromotions.get(prodId);
        }

        if (prodPLE.vlocity_cmt__PromotionId__c != null)
        {
            //if this PLE has a promotion and the cart does not have any applied promo, or if this applied promo's don't have this promotion
            if (allAppliedPromotions == null || !allAppliedPromotions.contains(prodPLE.vlocity_cmt__PromotionId__c))
            {
                CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' ---- END');
                return false;
            }
        }
        CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' ---- END');
        return true;
    }

    private Map<Id, SObject> getPriceListEntries(Map<String, Object> inputMap, Map<String, Object> options)
    {
        String currentMethodName = 'getPriceListEntries';
        CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' ---- START');
        try
        {
            if (CPQ_Utility.IS_LOGGING_ENABLED)
            {
                CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' ---getPriceListEntries inputMap: ' + JSON.serialize(inputMap));
            }
            Map<Id, SObject> result;
            List<Id> priceListIds = (List<Id>)inputMap.get(CPQ_Utility.STRING_PRICELISTIDS);
            List<Id> productIds = (List<Id>)inputMap.get(CPQ_Utility.STRING_PRODUCTIDS);
            List<Id> promotionIds = (List<Id>)inputMap.get(CPQ_Utility.STRING_PROMOTIONIDS);
            List<Id> promotionItemIds = (List<Id>)inputMap.get(CPQ_Utility.STRING_PROMOTIONITEMIDS);
            List<Id> offerIds = (List<Id>)inputMap.get(CPQ_Utility.STRING_OFFERIDS);
            Set<Id> pleByAssetIds = inputMap.containsKey('pleByAssetIds') ? (Set<Id>)inputMap.get('pleByAssetIds') : null; // SC VLOCITY 15062020
            Boolean isAsset = inputMap.containsKey('isAsset') ? (Boolean)inputMap.get('isAsset') : false; // SC VLOCITY 15062020
            String whereClause = (String)inputMap.get(CPQ_Utility.STRING_WHERECLAUSE);
            String sortBy = (String)inputMap.get(CPQ_Utility.STRING_SORTBY);
            Boolean filterByPromoIdsOnly = (Boolean)inputMap.get('filterByPromoIdsOnly');
            Boolean ignoreIsActive = false, ignoreEffectivity = false;
            if (options != null)
            {
                system.debug( 'options =! null' );
                if (options.containsKey(CPQ_Utility.STRING_IGNOREISACTIVE))
                {
                    ignoreIsActive = (Boolean)options.get(CPQ_Utility.STRING_IGNOREISACTIVE);
                }
                // ************ Inactive PLE fix *********
                else if (vlocity_cmt.FlowStaticMap.flowMap.containsKey(CPQ_Utility.STRING_IGNOREISACTIVE))
                {
                    ignoreIsActive = (Boolean)vlocity_cmt.FlowStaticMap.flowMap.get(CPQ_Utility.STRING_IGNOREISACTIVE);
                }
                if (options.containsKey(CPQ_Utility.STRING_IGNOREEFFECTIVEDATES))
                {
                    ignoreEffectivity = (Boolean)options.get(CPQ_Utility.STRING_IGNOREEFFECTIVEDATES);
                }
            }
            else
            {
                // ************ Inactive PLE fix *********
                system.debug( 'Inactive PLE fix: ' );
                if (vlocity_cmt.FlowStaticMap.flowMap.containsKey(CPQ_Utility.STRING_IGNOREISACTIVE))
                {
                    ignoreIsActive = (Boolean)vlocity_cmt.FlowStaticMap.flowMap.get(CPQ_Utility.STRING_IGNOREISACTIVE);
                }
            }
            Datetime effectiveFromDate = Datetime.now();
            if (inputMap.containsKey(CPQ_Utility.STRING_EFFECTIVEFROMDATE))
            {
                Object temp = inputMap.get(CPQ_Utility.STRING_EFFECTIVEFROMDATE);
                if (temp instanceof String) effectiveFromDate = Datetime.valueOf((String)temp);
                else effectiveFromDate = (Datetime)temp;
            }
            Datetime effectiveUntilDate = null;
            if (inputMap.containsKey(CPQ_Utility.STRING_EFFECTIVEUNTILDATE))
            {
                Object temp = inputMap.get(CPQ_Utility.STRING_EFFECTIVEUNTILDATE);
                if (temp instanceof String) effectiveUntilDate = Datetime.valueOf((String)temp);
                else effectiveUntilDate = (Datetime)temp;
            }
            String fields = (String)inputMap.get(CPQ_Utility.STRING_FIELDSTOQUERY);
            String pQuery = createPriceListEntryQuery(fields);
            String andString = '';
            String whereString = ' WHERE ';
            system.debug( 'ignoreIsActive: ' + ignoreIsActive );
            // SC VLOCITY 15062020 START 
            if (ignoreIsActive == false && !isAsset)   // null or true // SC VLOCITY 03072020
            {   
                pQuery += whereString + '( ' + CPQ_Utility.NAMESPACE_PREFIX + 'IsActive__c = true OR usedForPricing__c = true)';
                andString = ' and ';
            }
            // SC VLOCITY 15062020 END
            if (!ignoreEffectivity && effectiveFromDate != null)   // null or true
            {
                if (andString == '') { pQuery += whereString; }
                if (effectiveUntilDate == null)
                {
                    pQuery += andString + ' ((' + CPQ_Utility.NAMESPACE_PREFIX + 'EffectiveFromDate__c = null or ' + CPQ_Utility.NAMESPACE_PREFIX +
                              'EffectiveFromDate__c <= :effectiveFromDate) and ('
                              + CPQ_Utility.NAMESPACE_PREFIX + 'EffectiveUntilDate__c = null or ' + CPQ_Utility.NAMESPACE_PREFIX
                              + 'EffectiveUntilDate__c > :effectiveFromDate))';
                }
                else
                {
                    pQuery += ' and ((' + CPQ_Utility.NAMESPACE_PREFIX + 'EffectiveFromDate__c = null or ' + CPQ_Utility.NAMESPACE_PREFIX +
                              ' EffectiveFromDate__c <= :effectiveFromDate) and (' +
                              + CPQ_Utility.NAMESPACE_PREFIX + 'EffectiveFromDate__c = null or ' + CPQ_Utility.NAMESPACE_PREFIX +
                              'EffectiveUntilDate__c <= :effectiveUntilDate))';
                }
                andString = ' and ';
            }
            if (priceListIds != null && !priceListIds.isEmpty())
            {
                system.debug('priceListIds: ' + priceListIds);
                if (andString == '') { pQuery += whereString; }
                pQuery += andString + CPQ_Utility.NAMESPACE_PREFIX + 'PriceListId__c in :priceListIds';
                andString = ' and ';
            }
            if (productIds != null && !productIds.isEmpty())
            {
                system.debug('productIds: ' + productIds);
                if (andString == '') { pQuery += whereString; }
                pQuery += andString + CPQ_Utility.NAMESPACE_PREFIX + 'ProductId__c in :productIds';
                andString = ' and ';
            }
            if (promotionIds != null && !promotionIds.isEmpty())
            {
                system.debug('promotionIds: ' + promotionIds);
                if (andString == '') { pQuery += whereString; }
                //[CV 20181008 SPE-387 - fix for Summer18] - Start
                //Commented to use the filterByPromoIdsOnly flag instead of the actionType, SPE-391 should still work
                /*if(vlocity_cmt.FlowStaticMap.flowMap.get('ActionType') != null && vlocity_cmt.FlowStaticMap.flowMap.get('ActionType') == 'AddPromo')
                {
                    pQuery += andString + '(' + CPQ_Utility.NAMESPACE_PREFIX + 'PromotionId__c in :promotionIds)';
                    // SPE-391: Clear the flag after reading it so that the next pricing call will return more PLEs
                    vlocity_cmt.FlowStaticMap.flowMap.remove('ActionType');
                }
                else
                {
                pQuery += andString + '(' + CPQ_Utility.NAMESPACE_PREFIX + 'PromotionId__c = NULL OR ' + CPQ_Utility.NAMESPACE_PREFIX + 'PromotionId__c in :promotionIds)';
                }*/
                if (filterByPromoIdsOnly)
                {
                    pQuery += andString + '(' + CPQ_Utility.NAMESPACE_PREFIX + 'PromotionId__c in :promotionIds)';
                }
                else
                {
                    pQuery += andString + '(' + CPQ_Utility.NAMESPACE_PREFIX + 'PromotionId__c = NULL OR ' + CPQ_Utility.NAMESPACE_PREFIX +
                              'PromotionId__c in :promotionIds)';
                }
                //[CV 20181008 SPE-387 - fix for Summer18] - End
                andString = ' and ';
            }
            else
            {
                if (andString == '') { pQuery += whereString; }
                pQuery += andString + CPQ_Utility.NAMESPACE_PREFIX + 'PromotionId__c = NULL';
                andString = ' and ';
            }
            if (promotionItemIds != null && !promotionItemIds.isEmpty())
            {
                if (andString == '') { pQuery += whereString; }
                pQuery += andString + CPQ_Utility.NAMESPACE_PREFIX + 'PromotionItemId__c in :promotionItemIds';
                andString = ' and ';
            }
            // SC VLOCITY 15062020 START [VDD VLOCITY ATT-531541] START
            if(isAsset){
                String chargeTypeAdj = CPQ_Utility.CHARGE_TYPE_ADJUSTMENT;
                if(pleByAssetIds != null && !pleByAssetIds.isEmpty()){ 
                    pQuery += ' AND ((vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableId__r.vlocity_cmt__ChargeType__c != :chargeTypeAdj AND vlocity_cmt__IsActive__c = true AND vlocity_cmt__PromotionId__c = null)';
                    pQuery += ' OR (vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableId__r.vlocity_cmt__ChargeType__c = :chargeTypeAdj AND Id IN :pleByAssetIds ))';
                }else{
                    pQuery += ' AND (vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableId__r.vlocity_cmt__ChargeType__c != :chargeTypeAdj AND vlocity_cmt__IsActive__c = true AND vlocity_cmt__PromotionId__c = null)';
                }
            }
            // SC VLOCITY 15062020 END [VDD VLOCITY ATT-531541] END
            CPQ_Utility.log('Prit: OfferIds :::' + offerIds);

            if (offerIds != null && !offerIds.isEmpty())
            {
                CPQ_Utility.log('Prit: OfferIds :::' + offerIds);
                if (andString == '') { pQuery += whereString; }
                pQuery += andString + CPQ_Utility.NAMESPACE_PREFIX + 'OfferId__c in :offerIds';
                andString = ' and ';
            }
            if (String.isNotBlank(whereClause))
            {
                if (andString == '') { pQuery += whereString; }
                pQuery += andString + whereClause;
                andString = ' and ';
            }
            if (String.isNotBlank(sortBy))
            {
                pQuery += ' ORDER BY ' + sortBy;
            }
            pQuery +=  ' LIMIT '+ String.valueOf(CPQ_Utility.PLE_QUERY_LIMIT); //[CV Dynamic Query Limit for PLE - End] Old value 10000'
            system.debug( 'pQuery: ' + pQuery );
            result = new Map<Id, SObject>(Database.query(pQuery));
            CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' ---- END');
            return result;
        }
        catch (Exception e)
        {
            throw new ASKYTightestMatchServiceImplException(e + '|' + e.getStackTraceString());
        }
    }

    private static String createPriceListEntryQuery(String fieldsToQuery)
    {
        String currentMethodName = 'createPriceListEntryQuery';
        CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' ---- START');
        String pQuery = 'Select ' +  String.join(getPriceListEntryFieldsList(), ',') +  ' FROM '
                        + CPQ_Utility.NAMESPACE_PREFIX + 'PriceListEntry__c';
        CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' ---- END');
        return pQuery;
    }

    private static List<String> getPriceListEntryFieldsList()
    {
        String currentMethodName = 'getPriceListEntryFieldsList';
        CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' ---- START');
        CPQ_Utility.log('**** ' + CLASS_NAME + ' - ' + currentMethodName + ' ---- END');
        return new List<String>
        {
            'Id', 'Name',
            CPQ_Utility.NAMESPACE_PREFIX + 'BasePriceListId__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'DisplayText__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'EffectiveFromDate__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'EffectiveUntilDate__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'IsActive__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'IsOverride__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'PriceListId__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'ProductId__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'PromotionId__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'PromotionItemId__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'OfferId__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'IsVirtualPrice__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'TimePlanId__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'TimePolicyId__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'ProductId__r.Name',
            CPQ_Utility.NAMESPACE_PREFIX + 'OfferId__r.Name',
            CPQ_Utility.NAMESPACE_PREFIX + 'PriceListId__r.Name',
            CPQ_Utility.NAMESPACE_PREFIX + 'PricingElementId__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'PricingElementId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'DisplayText__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'PricingElementId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'AdjustmentValue__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'PricingElementId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'Amount__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'PricingElementId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'PricingMatrixId__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'PricingElementId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'CalculationType__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'PricingElementId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'Code__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'PricingElementId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'GlobalKey2__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'PricingElementId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'ObjectTypeId__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'PricingElementId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'CurrencyCode__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'PricingElementId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'LoyaltyCode__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'PricingElementId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'PricingVariableId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'CurrencyType__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'PricingElementId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'LoyaltyAmount__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'PricingElementId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'PricingVariableId__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'PricingElementId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'PricingVariableId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'RecurringFrequency__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'PricingElementId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'PricingVariableId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'AppliesToVariableId__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'PricingElementId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'PricingVariableId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'Type__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'PricingElementId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'PricingVariableId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'SubType__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'PricingElementId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'PricingVariableId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'Code__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'PricingElementId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'PricingVariableId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'ChargeType__c',
            CPQ_Utility.NAMESPACE_PREFIX + 'PricingElementId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'PricingVariableId__r.' + CPQ_Utility.NAMESPACE_PREFIX + 'AdjustmentMethod__c'
        };
    }

    // SPE-392 This method returns PLEs that are referenced in context rules. The rest of the PLEs are assumed to be qualified.
    private static List<SObject> getPriceListEntriesWithRules(Map<Id, SObject> pleToProcessMap, List<SObject> preQualifiedPLEs)
    {
        List<SObject> result = new List<SObject>();
        if (pleToProcessMap != null && !pleToProcessMap.isEmpty())
        {
            Set<Id> plesWithRules = new Set<Id>();
            for (SObject sObj : [SELECT Id, Name, vlocity_cmt__ObjectId__c, vlocity_cmt__RuleId__c, vlocity_cmt__HeaderId__c
                                 FROM vlocity_cmt__RuleAssignment__c WHERE vlocity_cmt__ObjectId__c IN :pleToProcessMap.keySet()
                                 ORDER BY vlocity_cmt__ObjectId__c])
            {

                plesWithRules.add((Id)sObj.get('vlocity_cmt__ObjectId__c'));
            }
            CPQ_Utility.log('**** ' + CLASS_NAME + ' ---- plesWithRules.size() ' + plesWithRules.size());
            for (SObject ple : pleToProcessMap.values())
            {
                if (plesWithRules.contains(ple.Id))
                {
                    result.add(ple);
                }
                else
                {
                    preQualifiedPLEs.add(ple);
                }
            }
            CPQ_Utility.log('**** ' + CLASS_NAME + ' ---- preQualifiedPLEs.size() ' + preQualifiedPLEs.size() + ' --------result ' + result.size());
        }
        return result;
    }

    global class ASKYTightestMatchServiceImplException extends Exception {}
}
