/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
 * Created by javierarroyo on 3/3/20.
 * Handle the platform event and call the connector
 */
public with sharing class CPQB2BConnectorTriggerHandler {

    private Map<Id, CPQ_B2B_Connector__e> connectorEvents;
    private static final String sTriggerEvent = 'Platform Event';

    List<Id> productList;
    List<Id> priceIds;
    List<Id> orderIds;
    List<Id> ccOrderIds; //ccrz__E_Order__c

    /**
     * constructor
     *
     * @param connectorEvents
     */
    public CPQB2BConnectorTriggerHandler(Map<Id, CPQ_B2B_Connector__e> connectorEvents) {
        this.connectorEvents = connectorEvents;
    }

    /**
     * puts the events in a 'bucket' based on object type and calls the connector sync methods
     */
    public void run() {
        for( CPQ_B2B_Connector__e e: connectorEvents.values() ) {
            this.addEventToList(e);
        }
        CPQB2BConnector c = new CPQB2BConnector();
        if ( productList != null ) {
            c.syncSku( productList, sTriggerEvent );
        }
        if ( priceIds != null ) {
            c.syncPricing( priceIds, sTriggerEvent );
        }
        if ( orderIds != null ) {
            c.syncOrderToCCOrder( orderIds, sTriggerEvent );
        }
        if ( ccOrderIds != null ) {
            c.syncCCOrderToOrder( ccOrderIds, sTriggerEvent );
        }
    }

    private void addEventToList(CPQ_B2B_Connector__e e) {
        String objName = this.getType(e.Object_Id__c );
        if ( 'Product2' == objName ) {
            if ( productList == null ) productList = new List<Id>();
            productList.add( e.Object_Id__c );
        }
        // Note, PriceBookEntry sObject wuold never be available since SF doesn't allow processes on this object
        if ( 'SBQQ__QuoteLine__c' == objName )  {
            if ( priceIds == null ) priceIds = new List<Id>();
            priceIds.add( e.Object_Id__c );
        }
        if ( 'Order' == objName ) {
            if ( orderIds == null ) orderIds = new List<Id>();
            orderIds.add( e.Object_Id__c );
        }
        if ( 'ccrz__E_Order__c' == objName ) {
            if ( ccOrderIds == null ) ccOrderIds = new List<Id>();
            ccOrderIds.add( e.Object_Id__c );
        }
    }

    private String getType(Id id) {
        return id.getSobjectType().getDescribe().getName();
    }

}