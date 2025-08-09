
/*AOM Automation
Author : Shravani Khaparkar
Description : This is used for comparsion of orders and checking the permission set of user*/
global class AOMDraftOrderHandler {
    public static List<Order> orderToBeRemovedSet = new List<Order>();
    public static List<Order> orderToBeProcessed = new List<Order>();
    public static Set<String> orderNumberSet = new Set<String>();
    public static Set<String> orderSet = new Set<String>();
     
             
    @AuraEnabled
    public static List<string> getFeature(){
        String featurestr = system.label.DraftOrderFeature;
        List<string> strlist = featurestr.split('-');
        return strlist;
    }
    
    @AuraEnabled
    public static Boolean getUserAccess(){
        Id userId = userInfo.getUserId();
        List<PermissionSetAssignment> pSet = [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, 
                                              PermissionSet.Profile.Name, AssigneeId, Assignee.Name 
                                              FROM PermissionSetAssignment 
                                              WHERE Assignee.Id = :userId
                                              AND PermissionSet.Name = 'AOM_DraftOrder_PermissionSet'];

        if(pSet.size()>0){
            return True;
        }else{
            return False;
        }
        
    }
    
    @AuraEnabled
    public static String importCSVFile(String orderIdSet){
        
        //Get the total records for resubmission
        List<Order> totalOrderList = [Select id,OrderNumber,CreatedDate, Contract.ChildContractTV__r.Order_Number__c, status,og_action__C,Type,OG_OrderSubType__c,OG_SellingChannel__c,OG_Origin__c,og_integration_outcome__c, BB_Integration_Outcome__c,hasODL__c
                       from Order
                       where LastModifiedDate >= LAST_N_DAYS:1
                       AND 
                       (OG_Integration_Outcome__c IN ('IO Exception: Read timed out','IO Exception: Unexpected end of file from server','IO Exception: Unable to tunnel through proxy. Proxy returns "HTTP/1.1 503 Service Unavailable') OR OG_Integration_Outcome__c = 'Web service callout failed: Encountered HTML Content when looking for http://schemas.xmlsoap.org/soap/envelope/:Envelope' ) 
                       AND OfferType__c = 'TV'
                       AND Status ='Draft' AND BB_Integration_Outcome__c = ''
                       Order By Contract.ChildContractTV__r.Order_Number__c,CreatedDate DESC];
        
        
        //Verified Order List
        String orderIdSplit = orderIdSet;
        List<String> ids = orderIdSplit.split(',');
        for(String s :ids){
            orderSet.add(s);
        }
        
        //Iterrate to check missing orders
        for(Order ord :totalOrderList){
            if(!orderSet.contains(ord.Id)){
                orderToBeRemovedSet.add(ord);
            }else{
                orderNumberSet.add(ord.Contract.ChildContractTV__r.Order_Number__c);
                orderToBeProcessed.add(ord);
            }
        }
        
        //Integer customLabelBatchSize =integer.valueof(Label.DraftOrderBatchSize);
 
        DraftOrderRetriggerBatch batch = new DraftOrderRetriggerBatch(orderIdSet,orderToBeRemovedSet);
        Database.executeBatch(batch,1);
        
       return 'Success';
    }
}
