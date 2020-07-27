/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */


global with sharing class CPQB2BSyncOrderBatch implements Database.Batchable<SObject> {
    public CPQB2BLogger logger {get;set;}

    global CPQB2BSyncOrderBatch() {
        this.logger = new CPQB2BLogger();
    }

     /*******************************************************************************************************
    * @description Start the batch with the QueryLocator that select Order records that should sync
    * @param Database.BatchableContext 
    * @return the QueryLocator for the Order Query
    * @see CPQB2BOrderSelector#getOrdersToSync()
    */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return new CPQB2BOrderSelector().getOrdersToSync();
    }

    /*******************************************************************************************************
    * @description Execute the syncing of the batch
    * @param Database.BatchableContext
    * @param List<Order> entries
    * @see CPQB2BConnector#syncOrderToCCOrder(List<Order>, String)
    */
    global void execute(Database.BatchableContext bc, List<Order> records) {
        try {
            new CPQB2BConnector().syncOrderToCCOrder(records, 'Batch');
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