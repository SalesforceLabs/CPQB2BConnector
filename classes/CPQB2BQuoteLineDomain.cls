/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
* @author Ashlee Zeigler
* @date 02/20/2020
*
* @see CPQB2BDomain
* @description Trigger Domain on QuoteLine that handles ensuring the correct system processes occur
* when QuoteLine records are created/updated/deleted.
*/

public class CPQB2BQuoteLineDomain extends CPQB2BDomain {

    /**
     * Constructor
     * @param  records Trigger.new
     */
    public CPQB2BQuoteLineDomain(List<Product2> records) {
        super(records);
    }

     /***********************************
        Business logic
    ************************************/

    /**
     * syncQuoteLinesToB2B Fires logic to sync SBQQ__QuoteLine__c records to CCPriceListItem
     * overloaded method for after update trigger
     * @param  records Trigger.new
     * @param  oldMap  Trigger.oldMap
     */
    public void syncQuoteLinesToB2B(List<SBQQ__QuoteLine__c> records, Map<Id, SBQQ__QuoteLine__c> oldMap) {
        List<Id> recordIdsToSync = getQuoteLinesToProcess(records, oldMap);

        if(!recordIdsToSync.isEmpty()){
            CPQB2BConnector connector = new CPQB2BConnector();
            connector.syncPricing(recordIdsToSync, 'Future Call');
        }
    }

    /**
     * syncQuoteLinesToB2B Fires logic to sync SBQQ__QuoteLine__c records to CCPriceListItem
     * overloaded method for after insert trigger
     * @param  records Trigger.new
     */
    public void syncQuoteLinesToB2B(List<SBQQ__QuoteLine__c> records) {
        List<Id> recordIdsToSync = new List<Id>();
        List<Id> quoteIds = new List<Id>();
        for (SBQQ__QuoteLine__c quoteLine : records) {
           quoteIds.add(quoteLine.SBQQ__Quote__c);
        }

         List<SBQQ__Quote__c> quotes = new CPQB2BQuoteSelector().selectQuotesByIds(quoteIds);
         Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>();
         for (SBQQ__Quote__c quote : quotes) {
             quoteMap.put(quote.Id, quote);
         }

        for(SBQQ__QuoteLine__c quoteLine : records) {
            SBQQ__Quote__c quote = quoteMap.get(quoteLine.SBQQ__Quote__c);
            if (quote.Sync_Quote_To_B2B__c) {
                recordIdsToSync.add(quoteLine.Id);
            }
        }

        if(!recordIdsToSync.isEmpty()){
            CPQB2BConnector connector = new CPQB2BConnector();
            connector.syncPricing(recordIdsToSync, 'Future Call');
        }
    }

    /**
     * getQuoteLinesToProcess 
     * overloaded method for after insert trigger
     * @param  records Trigger.new
     */
    public List<Id> getQuoteLinesToProcess(List<SBQQ__QuoteLine__c> records, Map<Id, SBQQ__QuoteLine__c> oldMap) {
        List<Id> recordIdsToProcess = new List<Id>();

        List<Id> quoteIds = new List<Id>();
        for (SBQQ__QuoteLine__c quote : records) {
           quoteids.add(quote.SBQQ__Quote__c);
        }

         List<SBQQ__Quote__c> quotes = new CPQB2BQuoteSelector().selectQuotesByIds(quoteIds);
         Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>();
         for (SBQQ__Quote__c quote : quotes) {
             quoteMap.put(quote.Id, quote);
         }

        for(SBQQ__QuoteLine__c quoteLine : records) {
            SBQQ__Quote__c quote = quoteMap.get(quoteLine.SBQQ__Quote__c);

            if (quote.Sync_Quote_To_B2B__c) {
                recordIdsToProcess.add(quoteLine.Id);
            }
        }

        return recordIdsToProcess;
    }

    /*************************************
        Trigger functions
        Remove the ones you don't use
    **************************************/

    // public override void onBeforeInsert() {
    //     List<SBQQ__QuoteLine__c> quoteLines = (List<SBQQ__QuoteLine__c>)this.records;
    // }

    public override void onAfterInsert() {
        List<SBQQ__QuoteLine__c> quoteLines = (List<SBQQ__QuoteLine__c>)this.records;
        this.syncQuoteLinesToB2B(quoteLines);
    }

    // public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    //     List<SBQQ__QuoteLine__c> quoteLines = (List<SBQQ__QuoteLine__c>)this.records;
    //     Map<Id, SBQQ__QuoteLine__c> quoteLineMap = (Map<Id, SBQQ__QuoteLine__c>)oldMap;
    // }

    public override void onAfterUpdate(Map<Id, SObject> oldMap) {
        List<SBQQ__QuoteLine__c> quoteLines = (List<SBQQ__QuoteLine__c>)this.records;
        Map<Id, SBQQ__QuoteLine__c> quoteLineMap = (Map<Id, SBQQ__QuoteLine__c>)oldMap;
        
        this.syncQuoteLinesToB2B(quoteLines,quoteLineMap);
    }
}