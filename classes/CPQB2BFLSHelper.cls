/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

public with sharing class CPQB2BFLSHelper {
    public CPQB2BFLSHelper() {

    }

    public static Boolean checkObjectAndFieldsCreateable(List<SObject> sObjects){
        String obj = sObjects[0].getSObjectType().getDescribe().getName();
        if(obj == 'ccrz__E_PriceList__c'){
            return checkObjectAndFieldsCreateable(obj, new CPQB2BCCPriceListSelector().getDefaultFields());
        }
        if(obj == 'ccrz__E_AccountGroupPriceList__c'){
            return checkObjectAndFieldsCreateable(obj, new CPQB2BCCAccountGrpPriceListSelector().getDefaultFields());
        }
        if(obj == 'ccrz__E_AccountGroup__c'){
            return checkObjectAndFieldsCreateable(obj, new CPQB2BCCAccountGroupSelector().getDefaultFields());
        }
        if(obj == 'ccrz__E_PriceListItem__c'){
            return checkObjectAndFieldsCreateable(obj, new CPQB2BCCPriceListItemSelector().getFields());
        }
        if(obj == 'ccrz__E_Order__c'){
            return checkObjectAndFieldsCreateable(obj, new CPQB2BCCOrderSelector().getFields());
        }
        if(obj == 'ccrz__E_OrderItem__c'){
            return checkObjectAndFieldsCreateable(obj, new CPQB2BCCOrderItemSelector().getFields());
        }
        if(obj == 'Address, ccrz__E_ContactAddr__c'){
            return checkObjectAndFieldsCreateable(obj, new CPQB2BCCContactAddressSelector().getDefaultFields());
        }
        if(obj == 'ccrz__E_ContactAddr__c'){
            return checkObjectAndFieldsCreateable(obj, new CPQB2BCCContactAddressSelector().getDefaultFields());
        }
        System.debug('Mapping Utility Called for Unhandled Object: ' + obj);
        return false;
    }

    public static Boolean checkObjectAndFieldsCreateable(String obj, Set<String> fields){
        SObjectType sObjectType = Schema.getGlobalDescribe().get(obj);
        fields = cleanFields(fields);
        for(String s: fields){
            System.debug('Testing FLS On: ' + s);
            if(!sObjectType.getDescribe().fields.getMap().get(s).getDescribe().isCreateable() &&
                !sObjectType.getDescribe().fields.getMap().get(s).getDescribe().isAutoNumber() &&
                !sObjectType.getDescribe().fields.getMap().get(s).getDescribe().isCalculated()){
                System.debug(s + ': Not Createable');
                return false;
            }
        }
        return true;
    }

    public static Boolean checkObjectAndFieldsUpdateable(String obj, Set<String> fields){
        SObjectType sObjectType = Schema.getGlobalDescribe().get(obj);
        if(!sObjectType.getDescribe().isUpdateable()){
            System.debug(obj + ': Not Updateable');
            return false;
        }
        fields = cleanFields(fields);
        for(String s: fields){
            System.debug('Testing FLS On: ' + s);
            if(!sObjectType.getDescribe().fields.getMap().get(s).getDescribe().isCreateable() && 
                !sObjectType.getDescribe().fields.getMap().get(s).getDescribe().isAutoNumber() && 
                !sObjectType.getDescribe().fields.getMap().get(s).getDescribe().isCalculated()){
                System.debug(s + ': Not Updateable');
                return false;
            }
        }
        return true;
    }

    public static Boolean checkingObjectAndFieldsAccessible(String obj, Set<String> fields){
        SObjectType sObjectType = Schema.getGlobalDescribe().get(obj);
        if(!sObjectType.getDescribe().isAccessible()){
            System.debug(obj + ': Not Accessible');
            return false;
        }fields = cleanFields(fields);
        for(String s: fields){
            System.debug('Testing FLS On: ' + s);
            if(!sObjectType.getDescribe().fields.getMap().get(s).getDescribe().isAccessible()){
                System.debug(s + ': Not Accessible');
                return false;
            }
        }
        return true;
    }


    public static Boolean checkObjectAndFieldsCreateable(String obj, List<CPQB2BBaseFieldMapping> mappings){
        Set<String> sFields = new Set<String>();
        for(CPQB2BBaseFieldMapping field: mappings){
            sFields.add(field.destField);
        }
        return checkObjectAndFieldsCreateable(obj, sFields);
    }

    public static Set<String> cleanFields(Set<String> fields){
        fields.remove('Id');
        for(String s: fields){
            if(s.contains('__r.') || s.startsWith('(')){
                fields.remove(s);
            }
            if(s == 'BillingAddress'){
                fields.add('BillingStreet');
                fields.remove('BillingAddress');
            }

            if(s == 'ShippingAddress'){
                fields.add('ShippingStreet');
                fields.remove('ShippingAddress');
            }

            if(s == 'ccrz__ShipTo__c' || s == 'ccrz__BillTo__c'){
                fields.remove(s);
            }
        }
        return fields;
    }
}