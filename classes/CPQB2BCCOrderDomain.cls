/**
* @author Ashlee Zeigler
* @date 3/5/2020
* @see CPQB2BDomain
* @description Trigger Domain on CC Order that handles ensuring the correct system processes occur
* 
*/
public class CPQB2BCCOrderDomain extends CPQB2BDomain {
    /**
    * Constructor
    * @param  records Trigger.new
    */
   public CPQB2BCCOrderDomain(List<ccrz__E_Order__c> records) {
       super(records);
   }

    /***********************************
       Business logic
   ************************************/

   /**
    * syncCCOrdersToCPQ Fires logic to sync CC Order records to Orders
    * overloaded method for after update trigger
    * @param  records Trigger.new
    * @param  oldMap  Trigger.oldMap
    */
   public void syncCCOrdersToCPQ(List<ccrz__E_Order__c> records, Map<Id, ccrz__E_Order__c> oldMap) {
       List<Id> recordIdsToSync = getCCOrdersToProcess(records, oldMap);

       if(!recordIdsToSync.isEmpty()){
           new CPQB2BConnector().syncCCOrderToOrder(recordIdsToSync,'Future Call');
       }
   }

   /**
    * syncCCOrdersToCPQ Fires logic to sync CC Order records to Order
    * overloaded method for after insert trigger
    * @param  records Trigger.new
    */
   public void syncCCOrdersToCPQ(List<ccrz__E_Order__c> records) {
       List<Id> recordIdsToSync = new List<Id>();

       for(ccrz__E_Order__c ccOrder : records){
           if(ccOrder.Sync_to_CPQ__c && ccOrder.Orders__r.isEmpty()){
            recordIdsToSync.add(ccOrder.Id);
           }
       }

       if(!recordIdsToSync.isEmpty()){
           new CPQB2BConnector().syncCCOrderToOrder(recordIdsToSync,'Future Call');
       }
   }

   /**
    * getOrdersToProcess Gather a list of cc orders to sync
    * overloaded method for after insert trigger
    * @param  records Trigger.new
    */
   public List<Id> getCCOrdersToProcess(List<ccrz__E_Order__c> records, Map<Id, ccrz__E_Order__c> oldMap) {
      List<Id> recordIdsToSync = new List<Id>();

       for(ccrz__E_Order__c ccOrder : records){
           if(ccOrder.Sync_to_CPQ__c && ccOrder.Orders__r.isEmpty()) {
            recordIdsToSync.add(ccOrder.Id);
           }
       }

       return recordIdsToSync;
   }

   /*************************************
       Trigger functions
       Remove the ones you don't use
   **************************************/

//    public override void onBeforeInsert() {
//        System.debug('Before Insert');
//        List<ccrz__E_Order__c> ccOrders = (List<ccrz__E_Order__c>)this.records;
//    }

   public override void onAfterInsert() {
       System.debug('After Insert');
       List<ccrz__E_Order__c> ccOrders = (List<ccrz__E_Order__c>)this.records;
       this.syncCCOrdersToCPQ(ccOrders);
   }

//    public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
//        System.debug('Before Update');
//        List<ccrz__E_Order__c> ccOrders = (List<ccrz__E_Order__c>)this.records;
//        Map<Id, ccrz__E_Order__c> ccOrderMap = (Map<Id, ccrz__E_Order__c>)oldMap;
//    }

   public override void onAfterUpdate(Map<Id, SObject> oldMap) {
       System.debug('After Update');
       List<ccrz__E_Order__c> ccOrders = (List<ccrz__E_Order__c>)this.records;
       Map<Id, ccrz__E_Order__c> ccOrderMap = (Map<Id, ccrz__E_Order__c>)oldMap;
       
       this.syncCCOrdersToCPQ(ccOrders, ccOrderMap);
   }
}