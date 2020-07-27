/**
* @author Ashlee Zeigler
* @date 02/20/2020
*
* @description Trigger Domain on Quote that handles ensuring the correct system processes occur
* when QuoteLine records are created/updated/deleted.
*/

public class CPQB2BQuoteDomain extends CPQB2BDomain {

    /**
     * Constructor
     * @param  records Trigger.new
     */
    public CPQB2BQuoteDomain(List<Product2> records) {
        super(records);
    }

     /***********************************
        Business logic
    ************************************/

    /**
     * syncQuoteToB2B Fires logic to sync SBQQ__Quote__c records to CCPriceListItem
     * overloaded method for after update trigger
     * @param  records Trigger.new
     * @param  oldMap  Trigger.oldMap
     */
    public void syncQuoteToB2B(List<SBQQ__Quote__c> records, Map<Id, SBQQ__Quote__c> oldMap) {
        List<SBQQ__QuoteLine__c> quoteLinesToSync = getQuoteLinesToProcess(records, oldMap);

        if(!quoteLinesToSync.isEmpty()){
            new CPQB2BConnector().syncPricing(quoteLinesToSync, 'Future Call');
        }
    }

    /**
     * syncQuoteToB2B Fires logic to sync SBQQ__QuoteLine__c records to CCPriceListItem
     * overloaded method for after insert trigger
     * @param  records Trigger.new
     */
    public void syncQuoteToB2B(List<SBQQ__Quote__c> records) {
        List<Id> recordIdsToSync = new List<Id>();
        List<Id> quoteIdsToSync = new List<Id>();

        for(SBQQ__Quote__c quote : records) {
            if (quote.Sync_Quote_To_B2B__c) {
                quoteIdsToSync.add(quote.Id);
            }
        }

        List<SBQQ__QuoteLine__c> quoteLinesToSync =  new CPQB2BQuoteLineSelector().selectQuoteLinesByQuoteIds(quoteIdsToSync);

        if(!quoteLinesToSync.isEmpty()){
            new CPQB2BConnector().syncPricing(quoteLinesToSync, 'Future Call');
        }
    }

    /**
     * getQuoteLinesToProcess 
     * overloaded method for after insert trigger
     * @param  records Trigger.new
     */
    public List<SBQQ__QuoteLine__c> getQuoteLinesToProcess(List<SBQQ__Quote__c> records, Map<Id, SBQQ__Quote__c> oldMap) {
        List<SBQQ__QuoteLine__c> recordsToProcess = new List<SBQQ__QuoteLine__c>();

          List<Id> quoteIdsToSync = new List<Id>();

        for(SBQQ__Quote__c quote : records) {
            if (quote.Sync_Quote_To_B2B__c) {
                quoteIdsToSync.add(quote.Id);
            } else {
                //Do we need to do anything with the old map
            }
        }

        return new CPQB2BQuoteLineSelector().selectQuoteLinesByQuoteIds(quoteIdsToSync);
    }

    /*************************************
        Trigger functions
        Remove the ones you don't use
    **************************************/

    // public override void onBeforeInsert() {
    //     List<SBQQ__Quote__c> quotes = (List<SBQQ__Quote__c>)this.records;
    // }

    public override void onAfterInsert() {
        List<SBQQ__Quote__c> quotes = (List<SBQQ__Quote__c>)this.records;
        this.syncQuoteToB2B(quotes);
    }

    // public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    //     List<SBQQ__Quote__c> quote = (List<SBQQ__Quote__c>)this.records;
    //     Map<Id, SBQQ__Quote__c> quoteMap = (Map<Id, SBQQ__Quote__c>)oldMap;
    // }

    public override void onAfterUpdate(Map<Id, SObject> oldMap) {
        List<SBQQ__Quote__c> quotes = (List<SBQQ__Quote__c>)this.records;
        Map<Id, SBQQ__Quote__c> quoteMap = (Map<Id, SBQQ__Quote__c>)oldMap;
        
        this.syncQuoteToB2B(quotes,quoteMap);
    }
}