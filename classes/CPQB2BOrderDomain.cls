/**
* @author Ashlee Zeigler
* @date 02/20/2020
*
* @description Trigger Domain on Order that handles ensuring the correct system processes occur
* 
*/
public class CPQB2BOrderDomain extends CPQB2BDomain {
     /**
     * Constructor
     * @param  records Trigger.new
     */
    public CPQB2BOrderDomain(List<Order> records) {
        super(records);
    }

     /***********************************
        Business logic
    ************************************/

    /**
     * syncOrdersToB2B Fires logic to sync Order records to CC Order
     * overloaded method for after update trigger
     * @param  records Trigger.new
     * @param  oldMap  Trigger.oldMap
     */
    public void syncOrdersToB2B(List<Order> records, Map<Id, Order> oldMap) {
        List<Id> recordIdsToSync = getOrdersToProcess(records, oldMap);

        if(!recordIdsToSync.isEmpty()){
            new CPQB2BConnector().syncOrderToCCOrder(recordIdsToSync,'Future Call');
        }
    }

    /**
     * syncOrdersToB2B Fires logic to sync Order records to CC Order
     * overloaded method for after insert trigger
     * @param  records Trigger.new
     */
    public void syncOrdersToB2B(List<Order> records) {
        List<Id> recordIdsToSync = new List<Id>();

        for(Order order : records){
            if(order.Sync_to_B2B__c){
                recordIdsToSync.add(order.Id);
            }
        }

        if(!recordIdsToSync.isEmpty()){
            new CPQB2BConnector().syncOrderToCCOrder(recordIdsToSync,'Future Call');
        }
    }

    /**
     * getOrdersToProcess Gather a list of orders to sync
     * overloaded method for after insert trigger
     * @param  records Trigger.new
     */
    public List<Id> getOrdersToProcess(List<Order> records, Map<Id, Order> oldMap) {
        List<Id> recordIdsToProcess = new List<Id>();

        for(Order order : records){
            if(order.Sync_to_B2B__c){
                recordIdsToProcess.add(order.Id);
            }
        }

        return recordIdsToProcess;
    }

    /*************************************
        Trigger functions
        Remove the ones you don't use
    **************************************/

    // public override void onBeforeInsert() {
    //     System.debug('Before Insert');
    //     List<Order> orders = (List<Order>)this.records;
    // }

    public override void onAfterInsert() {
        System.debug('After Insert');
        List<Order> orders = (List<Order>)this.records;
        this.syncOrdersToB2B(orders);
    }

    // public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    //     System.debug('Before Update');
    //     List<Order> orders = (List<Order>)this.records;
    //     Map<Id, Order> orderMap = (Map<Id, Order>)oldMap;
    // }

    public override void onAfterUpdate(Map<Id, SObject> oldMap) {
        System.debug('After Update');
        List<Order> orders = (List<Order>)this.records;
        Map<Id, Order> orderMap = (Map<Id, Order>)oldMap;
        
        this.syncOrdersToB2B(orders, orderMap);
    }

}