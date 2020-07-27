/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
 * CPQB2BProductLineItemService
 * @description Service class for generating lists of CPQB2BProductLineItems which contain
 * the information needed for generating quote lines.
 */
public class CPQB2BProductLineItemService {
    public Map<Id,Integer> productToQuantityMap {get;set;}
    public Id accountGroupId {get;set;}
    public List<Id> ccProductIds {get;set;}

    public CPQB2BProductLineItemService(List<Id> ccProductIds, Map<Id,Integer> productToQuantityMap, Id accountGroupId){
        this.ccProductIds = ccProductIds;
        this.productToQuantityMap = productToQuantityMap;
        this.accountGroupId = accountGroupId;
    }

    /**
     * @description Generates a map of product Id to product line, containing products priced 
     * by account groups lowest sequence price list     
     * @return Map<Id,CPQB2BProductLineItem>
     */  
    public Map<Id,CPQB2BProductLineItem> getProductLineItemsByLowestSequence(){
        //Query the associated Account Group Price List to get the related Source Pricebook Id
        CPQB2BCCAccountGrpPriceListSelector acctGrpPLSelector = new CPQB2BCCAccountGrpPriceListSelector();
        ccrz__E_AccountGroupPriceList__c acctGroupPL = acctGrpPLSelector.getLowestSequenceCCAccountGroupPriceList(this.accountGroupId);
        Id priceBookId = acctGroupPL.ccrz__Pricelist__r.Source_Price_Book__c;

        CPQB2BCCProductSelector ccProdSelector = new  CPQB2BCCProductSelector();
        List<ccrz__E_Product__c> ccProdsWithPriceListItem = ccProdSelector.selectByIdAndPriceList(ccProductIds,acctGroupPL.ccrz__Pricelist__r.Id);
        Map<Id,CPQB2BProductLineItem> productLineItemMap = new  Map<Id,CPQB2BProductLineItem>();

        for(ccrz__E_Product__c ccProduct : ccProdsWithPriceListItem){
            Integer productQuantity = this.productToQuantityMap.get(ccProduct.Id);
            for(ccrz__E_PriceListItem__c priceListItem : ccProduct.ccrz__E_PriceListItems__r){
                productLineItemMap.put(ccProduct.Source_Product__c,new CPQB2BProductLineItem(ccProduct.Source_Product__c,
                                                priceListItem.ccrz__Pricelist__r.Source_Price_Book__c,
                                                priceListItem.ccrz__Price__c,
                                                productQuantity));
            }
        }

        return productLineItemMap;
    }
    
    /**  
     * @description Generates a map of product Id to product line, containing the products lowest price
     * @return Map<Id,CPQB2BProductLineItem>
     */    
    public Map<Id,CPQB2BProductLineItem> getProductLineItemsByLowestPrice(){        
        CPQB2BCCProductSelector ccProdSelector = new CPQB2BCCProductSelector();
        List<ccrz__E_Product__c> ccProdsWithPriceListItem = ccProdSelector.selectByIdsWithLowestPriceListItem(ccProductIds);
        
        Map<Id,CPQB2BProductLineItem> productLineItemMap = new  Map<Id,CPQB2BProductLineItem>();
        for(ccrz__E_Product__c ccProduct : ccProdsWithPriceListItem){
            Integer productQuantity = this.productToQuantityMap.get(ccProduct.Id);
            for(ccrz__E_PriceListItem__c priceListItem : ccProduct.ccrz__E_PriceListItems__r){
                productLineItemMap.put(ccProduct.Source_Product__c,new CPQB2BProductLineItem(ccProduct.Source_Product__c,
                                                priceListItem.ccrz__Pricelist__r.Source_Price_Book__c,
                                                priceListItem.ccrz__Price__c,
                                                productQuantity));
            }
        }

        return productLineItemMap;
    }
}