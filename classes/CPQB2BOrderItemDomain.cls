/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
* @author Ashlee Zeigler
* @date 03/2/2020
*
* @see CPQB2BDomain
* @description Trigger Domain on Order that handles ensuring the correct system processes occur
*/
public class CPQB2BOrderItemDomain extends CPQB2BDomain {
    /**
    * Constructor
    * @param  records Trigger.new
    */
   public CPQB2BOrderItemDomain(List<Order> records) {
       super(records);
   }

    /***********************************
       Business logic
   ************************************/

   /**
    * syncOrderItemsToB2B Fires logic to sync Order records to CC Order
    * overloaded method for after update trigger
    * @param  records Trigger.new
    * @param  oldMap  Trigger.oldMap
    */
   public void syncOrderItemsToB2B(List<OrderItem> records, Map<Id, OrderItem> oldMap) {
       List<Id> recordIdsToSync = getOrdersToProcess(records, oldMap);

       if(!recordIdsToSync.isEmpty()){
           new CPQB2BConnector().syncOrderToCCOrder(recordIdsToSync,'Future Call');
       }
   }

   /**
    * syncOrderItemsToB2B Fires logic to sync Order records to CC Order
    * overloaded method for after insert trigger
    * @param  records Trigger.new
    */
   public void syncOrderItemsToB2B(List<OrderItem> records) {
       List<Id> recordIdsToSync = new List<Id>();

       List<Id> orderIds = new List<Id>();
       for (OrderItem orderItem : records) {
           orderIds.add(orderItem.orderId);
       }

       List<Order> orders = new CPQB2BOrderSelector().getByIds(orderIds);

       for(Order order : orders){
           if(order.Sync_to_B2B__c) {
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
   public List<Id> getOrdersToProcess(List<OrderItem> records, Map<Id, OrderItem> oldMap) {
       List<Id> recordIdsToProcess = new List<Id>();

       List<Id> orderIds = new List<Id>();
       for (OrderItem orderItem : records) {
           orderIds.add(orderItem.orderId);
       }

       List<Order> orders = new CPQB2BOrderSelector().getByIds(orderIds);

       for(Order order : orders){
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

//    public override void onBeforeInsert() {
//        System.debug('Before Insert');
//        List<OrderItem> orderItems = (List<OrderItem>)this.records;
//    }

   public override void onAfterInsert() {
       System.debug('After Insert');
       List<OrderItem> orderItems = (List<OrderItem>)this.records;
       this.syncOrderItemsToB2B(orderItems);
   }

//    public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
//        System.debug('Before Update');
//        List<OrderItem> orderItems = (List<OrderItem>)this.records;
//        Map<Id, OrderItem> orderItemsMap = (Map<Id, OrderItem>)oldMap;
//    }

   public override void onAfterUpdate(Map<Id, SObject> oldMap) {
       System.debug('After Update');
       List<OrderItem> orderItems = (List<OrderItem>)this.records;
       Map<Id, OrderItem> orderItemsMap = (Map<Id, OrderItem>)oldMap;
       
       this.syncOrderItemsToB2B(orderItems, orderItemsMap);
   }

}