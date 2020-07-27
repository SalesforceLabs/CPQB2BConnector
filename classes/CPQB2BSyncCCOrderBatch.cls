/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */


global with sharing class CPQB2BSyncCCOrderBatch implements Database.Batchable<SObject> {
    public CPQB2BLogger logger {get;set;}

    global CPQB2BSyncCCOrderBatch() {
        this.logger = new CPQB2BLogger();
    }

     /*******************************************************************************************************
    * @description Start the batch with the QueryLocator that select Order records that should sync
    * @param Database.BatchableContext 
    * @return the QueryLocator for the CC Order Query
    * @see CPQB2BCCOrderSelector#getCCOrdersToSync()
    */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return new CPQB2BCCOrderSelector().getCCOrdersToSync();
    }

    /*******************************************************************************************************
    * @description Execute the syncing of the batch
    * @param Database.BatchableContext
    * @param List<ccrz__E_Order__c> entries
    * @see CPQB2BConnector#syncCCOrderToOrder(List<ccrz__E_Order__c>, String)
    */
    global void execute(Database.BatchableContext bc, List<ccrz__E_Order__c> records) {
         try {
            new CPQB2BConnector().syncCCOrderToOrder(records, 'Batch');
        } catch (Exception e) {
            logger.log(CPQB2BProcessType.OrderToCCOrder.name(),'Batch', e, records);       
        } finally{
            logger.write();
        }
    }

     /*******************************************************************************************************
    * @description End the batch job
    * @param Database.BatchableContext 
    */
    global void finish(Database.BatchableContext bc) {
        System.Debug('Finished Syncing Order records');
    }
}