/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
* @author Amil Abdallah
* @date 02/17/2020
*
* @description Trigger Domain on Product2 that handles ensuring the correct system processes occur
* when Product2 records are created/updated/deleted.
*/

public class CPQB2BProduct2Domain extends CPQB2BDomain {

    /**
     * Constructor
     * @param  records Trigger.new
     */
    public CPQB2BProduct2Domain(List<Product2> records) {
        super(records);
    }

     /***********************************
        Business logic
    ************************************/

    /**
     * syncProductsToB2B Fires logic to sync Product2 records to CCProduct
     * overloaded method for after insert trigger
     * @param  records Trigger.new
     */
    public void syncProductsToB2B(List<Product2> records) {
        List<Id> recordIdsToSync = new List<Id>();

        recordIdsToSync = getProductsToProcess(records);

        if(!recordIdsToSync.isEmpty()){
            CPQB2BConnector connector = new CPQB2BConnector();
            connector.syncSku(recordIdsToSync,'Future Call');
        }
        else{
            System.debug('No products were identified for syncing.');
        }
    }

    /**
     * syncProductsToB2B Fires logic to sync Product2 records to CCProduct
     * overloaded method for after insert trigger
     * @param  records Trigger.new
     */
    public List<Id> getProductsToProcess(List<Product2> records) {
        List<Id> recordIdsToProcess = new List<Id>();

        for(Product2 product : records){
            Boolean syncToB2B = product.Sync_Product_To_B2B__c;
            //If SyncToB2B we process the record to be synced 
            if(syncToB2B){
                recordIdsToProcess.add(product.Id);
            }
        }

        return recordIdsToProcess;
    }

    /*************************************
        Trigger functions
        Remove the ones you don't use
    **************************************/

    // public override void onBeforeInsert() {
    //     System.debug('Before Insert');
    //     List<Product2> products = (List<Product2>)this.records;
    // }

    public override void onAfterInsert() {
        System.debug('After Insert');
        List<Product2> products = (List<Product2>)this.records;
        this.syncProductsToB2B(products);
    }

    // public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    //     System.debug('Before Update');
    //     List<Product2> products = (List<Product2>)this.records;
    //     Map<Id, Product2> productMap = (Map<Id, Product2>)oldMap;
    // }

    public override void onAfterUpdate(Map<Id, SObject> oldMap) {
        System.debug('After Update');
        List<Product2> products = (List<Product2>)this.records;
        Map<Id, Product2> productMap = (Map<Id, Product2>)oldMap;
        
        this.syncProductsToB2B(products);
    }

    // public override void onBeforeDelete() {
    //     List<Product2> products = (List<Product2>)this.records;
    // }

    // public override void onAfterDelete() {
    //     List<Product2> products = (List<Product2>)this.records;
    // }

    // public override void onAfterUndelete() {
    //     List<Product2> products = (List<Product2>)this.records;
    // }

}