/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
 * Class responsible for processing the queue Items
 * @description processor implementation itself marks the Queue Item record in an ERROR status or deletes the record upon success.
 * Processor queries to check if there are Queue Items remaining to process and enqueues again if at least one record is found
 */
public class CPQB2BQueueItemWorker implements Queueable {

    @TestVisible
    private integer rowLimit = 1;
    private static final String sTriggerEvent = 'Queue';

    List<Id> productList;
    List<Id> priceIds;
    List<Id> orderIds;
    List<Id> ccOrderIds; //ccrz__E_Order__c


    /**
     * method to separate the IDs into their own bucket based on sObjectValue
     *
     * @param sObjectValue
     * @param id
     */
    private void addItemToList(String  sObjectValue, Id id) {
        if ( 'Product2' == sObjectValue ) {
            if (productList == null ) productList = new List<Id>();
            productList.add( id );
        }
        // Note, PriceBookEntry sObject would never be available since SF doesn't allow processes on this object
        if ( 'SBQQ__QuoteLine__c' == sObjectValue ) {
            if (priceIds == null ) priceIds = new List<Id>();
            priceIds.add( id );
        }
        if ( 'Order' == sObjectValue ) {
            if ( orderIds == null ) orderIds = new List<Id>();
            orderIds.add( id );
        }
        if ( 'ccrz__E_Order__c' == sObjectValue ) {
            if ( ccOrderIds == null ) ccOrderIds = new List<Id>();
            ccOrderIds.add ( id );
        }
    }

    /**
     * call the connector and pass the object ids from each of the buckets
     * @see addItemToList() method
     */
    private void sync() {
        CPQB2BConnector con = new CPQB2BConnector();
        if ( productList != null && productList.size() > 0 ) {
            con.syncSKU(productList, sTriggerEvent);
        }
        if (priceIds != null && priceIds.size() > 0 ) {
            con.syncPricing(priceIds, sTriggerEvent);
        }
        if (orderIds != null && orderIds.size() > 0 ) {
            con.syncPricing(orderIds, sTriggerEvent);
        }
        if (ccOrderIds != null && ccOrderIds.size() > 0 ) {
            con.syncPricing(ccOrderIds, sTriggerEvent);
        }
    }

    /**
     * @description method that does the actual work on the items in the queue
     *
     * @param context
     */
    public void execute(QueueableContext context) {
        // do some work!
        // query for queueitem__c records, ordered by priority (0 = lowest)
        //

        DateTime processingTimeBoundary = DateTime.now();

        List<CPQB2BQueueItem__c> queueItemsToProcess = [
                SELECT Id,
                        Object__c,
                        RecordId__c
                FROM CPQB2BQueueItem__c
                WHERE Process_After__c <= :processingTimeBoundary
                AND Status__c = 'NEW'
                ORDER BY Priority__c DESC
                LIMIT :rowLimit];

        // TODO review this with the devs
        List<CPQB2BQueueItem__c> toDeleteList = new List<CPQB2BQueueItem__c>();

        for (CPQB2BQueueItem__c item : queueItemsToProcess) {
            // determine the work to be done on this queue item
            // based on the fields that were queried
            //
            System.debug('QueueItemWorked called');
            System.debug('Item:' + item.Object__c + ' - ' + item.RecordId__c);

            this.addItemToList( item.Object__c, item.RecordId__c );
            item.Status__c = 'PROCESSED';
            //
            // this class also is responsible for marking the CPQB2BQueueItem__c record Status as "not new"
            //
            // CPQB2BQueueItem__c records should be short lived and hard deleted (no recycle bin) to prevent data
            // storage problems as items are processed by the queue
            toDeleteList.add( item );
        }

        this.sync();

        delete toDeleteList;

        // determine if there are more items in the queue
        List<CPQB2BQueueItem__c> pendingItems = [SELECT Id
        // , other fields
        FROM CPQB2BQueueItem__c
        WHERE Process_After__c <= :processingTimeBoundary
        AND Status__c = 'NEW'
        ORDER BY Priority__c DESC
        LIMIT 1];

        System.debug('number of pending items:' + pendingItems.size());
        // work to be done, queue the job up again
        if (!pendingItems.isEmpty() && !Test.isRunningTest()) {
            System.debug('queuing the job up again');
            System.enqueueJob(new CPQB2BQueueItemWorker());
        }
    }
}