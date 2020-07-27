/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */


global inherited sharing class CPQB2BSyncProductsBatch implements Database.Batchable<SObject> {
    public CPQB2BLogger logger {get;set;}
   
    /*******************************************************************************************************
   * @description Start the batch with the QueryLocator that select PriceBookEntry records that aren't synced
   * @param Database.BatchableContext 
   * @return the QueryLocator for the Product2 query
   */
   global Database.QueryLocator start(Database.BatchableContext bc) {
       return new CPQB2BProduct2Selector().getProductRecordsToSync();
   }

   /*******************************************************************************************************
   * @description Execute the syncing of the batch
   * @param Database.BatchableContext
   * @param List<PriceBookEntry> entries
   */
   global void execute(Database.BatchableContext bc, List<Product2> products) {

        this.logger = new CPQB2BLogger();
        
        try {
            new CPQB2BConnector().syncSku(products,'Batch');
        } catch (Exception e) {
            logger.log(CPQB2BProcessType.SKU.name(),'Batch',e,products);          
        } finally{
            logger.write();
        }
   }

    /*******************************************************************************************************
   * @description End the batch job
   * @param Database.BatchableContext 
   */
   global void finish(Database.BatchableContext bc) {
       System.Debug('Finished Syncing Product records');
   }
}