/**
* @author Ashlee Zeigler
* @date 2-17-2020
*
* @see CPQB2BLogger
* @description This is a batch process to sync PriceBookEntry records to CCPriceListItems
*/
global with sharing class CPQB2BSyncPriceBookEntryBatch implements Database.Batchable<SObject> {
    public CPQB2BLogger logger {get;set;}

    global CPQB2BSyncPriceBookEntryBatch() {
        this.logger = new CPQB2BLogger();
    }

     /*******************************************************************************************************
    * @description Start the batch with the QueryLocator that select PriceBookEntry records that aren't synced
    * @param Database.BatchableContext 
    * @return the QueryLocator for the PriceBookEntry query
    * @see CPQB2BPriceBookEntrySelector#getPriceListEntryItemsToSync()
    */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return new CPQB2BPriceBookEntrySelector().getPriceListEntryItemsToSync();
    }

    /*******************************************************************************************************
    * @description Execute the syncing of the batch
    * @param Database.BatchableContext
    * @param List<PriceBookEntry> entries
    * @see CPQB2BConnector#syncPricing(List<PriceBookEntry>, String)
    */
    global void execute(Database.BatchableContext bc, List<PriceBookEntry> entries) {
        try {
            new CPQB2BConnector().syncPricing(entries, 'Batch');
        } catch (Exception e) {
            logger.log(CPQB2BProcessType.Pricing.name(),'Batch', e, entries);       
        } finally {
            logger.write();
        }
    }

     /*******************************************************************************************************
    * @description End the batch job
    * @param Database.BatchableContext 
    */
    global void finish(Database.BatchableContext bc) {
        System.Debug('Finished Syncing PriceBookEntry records');
    }
}