/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
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