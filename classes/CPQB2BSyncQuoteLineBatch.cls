/**
* @author Ashlee Zeigler
* @date 2-20-2020
*
* @see CPQB2BLogger
* @description This is a batch process to sync SBQQ__QuoteLine__c records to CCPriceListItems
*/
global with sharing class CPQB2BSyncQuoteLineBatch implements Database.Batchable<SObject> {
    public CPQB2BLogger logger {get;set;}

    global CPQB2BSyncQuoteLineBatch() {
        this.logger = new CPQB2BLogger();
    }

     /*******************************************************************************************************
    * @description Start the batch with the QueryLocator that select SBQQ__QuoteLine__c records that should sync
    * @param Database.BatchableContext 
    * @return the QueryLocator for the Quote Line query
    * @see CPQB2BQuoteLineSelector#selectQuoteLinesToSyncToB2B()
    */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return new CPQB2BQuoteLineSelector().selectQuoteLinesToSyncToB2B();
    }

    /*******************************************************************************************************
    * @description Execute the syncing of the batch
    * @param Database.BatchableContext
    * @param List<SBQQ__QuoteLine__c> entries
    * @see CPQB2BConnector#syncPricing(List<SBQQ__QuoteLine__c>, String)
    */
    global void execute(Database.BatchableContext bc, List<SBQQ__QuoteLine__c> records) {
        try {
            new CPQB2BConnector().syncPricing(records, 'Batch');
        } catch (Exception e) {
            logger.log(CPQB2BProcessType.Pricing.name(),'Batch', e, records);       
        } finally{
            logger.write();
        }
    }

     /*******************************************************************************************************
    * @description End the batch job
    * @param Database.BatchableContext 
    */
    global void finish(Database.BatchableContext bc) {
        System.Debug('Finished Syncing SBQQ__QuoteLine__c records');
    }
}