/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
 * CPQB2BConnector
 * @see CPQB2BMappingService
 * @description This is the main executor that executes the syncing between CPQ and B2B
 */
 public with sharing class CPQB2BConnector {    
    /**
     * Method used to sync CPQ Product records to B2B CCProduct records
     * @param  skuIdList List<Id>
     */
    public void syncSku(List<Id> skuIdList,String triggerEvent) {
        if (!this.isSyncEnabled(CPQB2BProcessType.SKU)) {
            return;
        }
        else{
            //Query for list of Product2 records for the given set of Ids
            CPQB2BProduct2Selector productSelector = new CPQB2BProduct2Selector();
            List<Product2> productsToSync = productSelector.selectByIds(skuIdList);
            
            CPQB2BMappingService mapService = new CPQB2BMappingService();
            mapService.triggerEvent = triggerEvent;
            mapService.mapProducts(productsToSync);
        }
    }
    
    /**
     * Method used to sync CPQ Product records to B2B CCProduct records
     * @param  skuList List<Product2>
     */
    public void syncSku(List<Product2> skuIdList, String triggerEvent) {
        if (!this.isSyncEnabled(CPQB2BProcessType.SKU)) {
            return;
        }
        else{
            CPQB2BMappingService mapService = new CPQB2BMappingService();
            mapService.triggerEvent = triggerEvent;
            mapService.mapProducts(skuIdList);
        }
    }

    /**
     * @description Sync pricing between CPQ & B2B
     * @param List<Id> ids
     * @see CPQB2BMappingService#mapPricing(List<Id>)
     */
    public void syncPricing(List<Id> ids, String triggerEvent) {
        if (!this.isSyncEnabled(CPQB2BProcessType.Pricing)) {
            return;
        }

        new CPQB2BMappingService(triggerEvent).mapPricing(ids);
    }

    /**
     * @description Sync pricing between CPQ & B2B
     * @param List<PriceBookEntry> PriceBookEntry
     * @see CPQB2BMappingService#mapPricing(List<PriceBookEntry>)
     */
    public void syncPricing(List<PriceBookEntry> priceBookEntries, String triggerEvent) {
        if (!this.isSyncEnabled(CPQB2BProcessType.Pricing)) {
            return;
        }
        new CPQB2BMappingService(triggerEvent).mapPricing(priceBookEntries);
    }

    /**
     * @description Sync pricing between CPQ & B2B
     * @param List<SBQQ__QuoteLine__c> SBQQ__QuoteLine__c
     * @see CPQB2BMappingService#mapPricing(List<SBQQ__QuoteLine__c>)
     */
    public void syncPricing(List<SBQQ__QuoteLine__c> quoteLines, String triggerEvent) {
        if (!this.isSyncEnabled(CPQB2BProcessType.Pricing)) {
            return;
        }
        new CPQB2BMappingService(triggerEvent).mapPricing(quoteLines);
    }

    /**
     * @description Sync CC Cart to Quote between CPQ & B2B
     * @param String cartId (encrypted cart Id)
     */
    public void syncCartToQuote(String cartId, String quoteDetails, String triggerEvent) {
        if (!this.isSyncEnabled(CPQB2BProcessType.CartToQuote)) {
            return;
        }
        else{
            new CPQB2BMappingService(triggerEvent).mapCartToQuote(cartId, quoteDetails);
        }
    }

    /**
     * @description Sync Order to CC Order between CPQ & B2B
     * @param List<Id> orderIdList
     * @see CPQB2BMappingService#mapCPQOrderToCCOrder(List<Id>)
     */
    public void syncOrderToCCOrder(List<Id> orderIdList, String triggerEvent) {
        if (!this.isSyncEnabled(CPQB2BProcessType.OrderToCCOrder)) {
            return;
        }
        new CPQB2BMappingService(triggerEvent).mapCPQOrderToCCOrder(orderIdList);
    }

    /**
     * @description Sync Order to CC Order between CPQ & B2B
     * @param List<Order> orderIdList
     * @param String triggerEvent
     * @see CPQB2BMappingService#mapCPQOrderToCCOrder(List<Order>)
     */
    public void syncOrderToCCOrder(List<Order> orderList, String triggerEvent) {
        if (!this.isSyncEnabled(CPQB2BProcessType.OrderToCCOrder)) {
            return;
        }
        new CPQB2BMappingService(triggerEvent).mapCPQOrderToCCOrder(orderList);
    }

    /**
     * @description Sync CC Order to Order between CPQ & B2B
     * @param List<Id> orderIdList
     * @param String triggerEvent
     * @see CPQB2BMappingService#mapCCOrderToCPQOrder(List<Id>)
     */
    public void syncCCOrderToOrder(List<Id> ccOrderIdList, String triggerEvent) {
        if (!this.isSyncEnabled(CPQB2BProcessType.CCOrderToOrder)) {
            return;
        }
        new CPQB2BMappingService(triggerEvent).mapCCOrderToCPQOrder(ccOrderIdList);
    }

    /**
     * @description Sync CC Order to Order between CPQ & B2B
     * @param List<ccrz__E_Order__c> ccOrders
     * @param String triggerEvent
     * @see CPQB2BMappingService#mapCCOrderToCPQOrder(List<ccrz__E_Order__c>)
     */
    public void syncCCOrderToOrder(List<ccrz__E_Order__c> ccOrders, String triggerEvent) {
        if (!this.isSyncEnabled(CPQB2BProcessType.CCOrderToOrder)) {
            return;
        }
        new CPQB2BMappingService(triggerEvent).mapCCOrderToCPQOrder(ccOrders);
    }

    /**
     * @description return the config value of the specified CPQB2BProcessType
     * only sync processes that are enabled wil actually sync data
     * @param p
     *
     * @return Boolean
     */
    public Boolean isSyncEnabled(CPQB2BProcessType p) {
        List<CPQB2BConnector_Sync_Config__mdt> configList = [
                Select Enabled__c, Process__c
                From CPQB2BConnector_Sync_Config__mdt
                Where Process__c =: p.name() 
        ];
        if (configList != null && configList.size() > 0) {
            return configlist[0].Enabled__c;
        }
        else {
            return false;
        }
    }
}