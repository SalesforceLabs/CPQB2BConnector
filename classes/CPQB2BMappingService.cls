/**
* Created by javierarroyo on 2/12/20.
* @date 02/12/2020
*
* @see CPQB2BLogger
* @see CPQB2BCCPriceListService
* @see CPQB2BOrderService
* @see CPQB2BMappingUtils
* @description Handles the field mapping logic used to copy field data between
* two objects as well as inserting/updating the records resulting from the sync
*/

public class CPQB2BMappingService {
    public CPQB2BLogger logger {get;set;}
    public String triggerEvent {get;set;}
    public CPQB2BCCPriceListService ccPriceListService {get;set;}
    public CPQB2BOrderService orderService {get;set;}
    public CPQB2BMappingUtils mappingUtils {get;set;}

    public CPQB2BMappingService() {
        this('');
    }

    public CPQB2BMappingService(String triggerEvent) {
        this.triggerEvent = triggerEvent;
        this.logger = new CPQB2BLogger();
        this.ccPriceListService = new CPQB2BCCPriceListService(triggerEvent);
        this.mappingUtils = new CPQB2BMappingUtils(triggerEvent);
        this.orderService = new CPQB2BOrderService(triggerEvent);
    }

    /**
     * mapProducts Maps Product2 records to CCProduct for a defined list of records
     * and inserts the new/updated records resulting from the mapping process
     * @param  products List of product2 records to sync over to CCProduct records
     */
    public void mapProducts(List<Product2> products) {
        Map<Id, Product2> recordsMap = new Map<Id, Product2>();
        recordsMap.putAll(products);
        List<Id> productIds = new List<Id>(recordsMap.keySet());

        //Query for any pre-existing CC Product records that map to any of the
        //product2 records (Where Product_Source__c IN: productIds)
        CPQB2BCCProductSelector ccProductSelector = new CPQB2BCCProductSelector();
        List<ccrz__E_Product__c> ccProductList = ccProductSelector.selectBySourceIds(productIds);

        //Create a map to identify Product2 records for which a CC Product record already exists
        //Key: Product2 Id - Value: CC Product Id
        Map<Id,ccrz__E_Product__c> sourceToCCProductMap = new Map<Id,ccrz__E_Product__c>();
        for(ccrz__E_Product__c ccProduct : ccProductList){
            sourceToCCProductMap.put(ccProduct.Source_Product__c,ccProduct);
        }

        //Retrieve the new and updated CCProduct records and upsert the list
        List<ccrz__E_Product__c> updatedCCProductList = copyProductFields(products,sourceToCCProductMap);
        List<Database.UpsertResult> dsrs;
        try {
            dsrs = Database.Upsert(updatedCCProductList, false);
            logger.log(CPQB2BProcessType.SKU.name(),this.triggerEvent,dsrs,updatedCCProductList);        
        } catch (Exception e) {
            logger.log(CPQB2BProcessType.SKU.name(),this.triggerEvent,e,updatedCCProductList);          
        } finally{
            logger.write();
        }
    }

    /**
     * @description This will take in a list of SObject ids, and decipher what type of SObject it is.
     *  After that it will perform the mapping based on object type
     * @param List<Id> ids
     */
    public void mapPricing(List<Id> ids) {
        List<Id> priceBookEntryIds = new List<Id>();
        List<Id> quoteLineIds = new List<Id>();
        List<Id> contractPriceIds = new List<Id>();

        for (Id id : ids) {
            String objectType = id.getSObjectType().getDescribe().getName();
            if (objectType == 'PriceBookEntry') {
                priceBookEntryIds.add(id);
            } else if (objectType == 'SBQQ__QuoteLine__c') {
                quoteLineIds.add(id);
            } else if(objectType == 'SBQQ__Contractedprice__c') {
                contractPriceIds.add(id);
            }
        }

        if (priceBookEntryIds.size() > 0) {
            List<PriceBookEntry> priceBookEntriesToSync = new CPQB2BPriceBookEntrySelector().getPricebookEntryByIds(priceBookEntryIds);
            mapPricing(priceBookEntriesToSync);
        }

        if (quoteLineIds.size() > 0) {
            List<SBQQ__QuoteLine__c> quoteLinesToSync = new CPQB2BQuoteLineSelector().selectQuoteLinesByIds(quoteLineIds);
            mapPricing(quoteLinesToSync);
        }
    }

    /**
     * @description This maps PricebookEntry records to ccrz__E_PriceListItem__c records
     *   
     * @param List<PriceBookEntry> priceBookEntriesToSync
     */
    public void mapPricing(List<PriceBookEntry> priceBookEntriesToSync) {
        List<Id> priceBookIds = new List<Id>();
        List<Id> productIds = new List<Id>();
        Map<Id, PriceBookEntry> inactivePriceBookMap = new Map<Id, PriceBookEntry>();

        //Map of PriceBookEntry by PriceBookEntry Id
        Map<Id, PriceBookEntry> priceBookEntryMap = new Map<Id, PriceBookEntry>();    
        for (PriceBookEntry pbe : priceBookEntriesToSync) {
            //Gather all of the PriceBook ids from the PriceBookEntry records
            priceBookIds.add(pbe.PriceBook2Id);
            //Create a map of PriceBookEntry records by Id to easily query
            priceBookEntryMap.put(pbe.Id, pbe);
            //Create a list of product ids to easily query
            productIds.add(pbe.Product2Id);
            //Inactive price book entry records should not be synced, so if there are any records existing
            //we need to put together a map of all the inactive price book entry records so that we know
            //which cc price list item records to delete
            if (ccPriceListService.isCCPriceListItemExpired(pbe)) {
                inactivePriceBookMap.put(pbe.Id, pbe);
            }
        }

        // Select all existing CCPriceList records linked to PriceBook2 records
        List<ccrz__E_PriceList__c> ccPriceLists = new CPQB2BCCPriceListSelector().getCCPriceListsByPriceBookIds(priceBookIds);
        // Loop through Existing CCPriceLists for the PriceBook records and Map the records
        Map<Id, List<ccrz__E_PriceList__c>> priceBookToCCPriceListsMap = new Map<Id, List<ccrz__E_PriceList__c>>();
        for (ccrz__E_PriceList__c ccPriceList : ccPriceLists) {
            //Map: PriceBook2Id -> CCPriceList
            if (priceBookToCCPriceListsMap.containsKey(ccPriceList.Source_Price_Book__c)) {
                priceBookToCCPriceListsMap.get(ccPriceList.Source_Price_Book__c).add(ccPriceList);
            } else {
                priceBookToCCPriceListsMap.put(ccPriceList.Source_Price_Book__c, new List<ccrz__E_PriceList__c> {ccPriceList});
            }
        }

        // Select all of the existing CCProducts from the PriceBookEntry record
        List<ccrz__E_Product__c> ccProducts = new CPQB2BCCProductSelector().selectBySourceIds(productIds);
        // Map all of the Product2 ids to CCProducts
        Map<Id, ccrz__E_Product__c> product2ToCCProductMap = new Map<Id, ccrz__E_Product__c>();
        for (ccrz__E_Product__c ccProduct : ccProducts) {
            //Map: Product2Id -> CCProduct
           product2ToCCProductMap.put(ccProduct.Source_Product__c, ccProduct);
        }

        // Create a list to hold all of the cc price list item records to delete
        List<ccrz__E_PriceListItem__c> ccPriceListItemsToDelete = new List<ccrz__E_PriceListItem__c>();
        // Select all of the existing CCPriceListItems that are associated to the PriceBookEntry records
        List<ccrz__E_PriceListItem__c> existingCCPriceListItems = new CPQB2BCCPriceListItemSelector().getCCPriceListItemsByPriceBookEntryIds(priceBookEntryMap.keySet());
        // Map of all the PriceBookEntry ids to CCPriceListItems
        Map<Id, List<ccrz__E_PriceListItem__c>> priceBookEntryToCCPriceListItemMap = new Map<Id, List<ccrz__E_PriceListItem__c>>();
        for (ccrz__E_PriceListItem__c ccPriceListItem : existingCCPriceListItems) {
            //If the cc price list item is associated with a price book entry that is inactive, it needs to be removed. 
            if (inactivePriceBookMap.containsKey(ccPriceListItem.Source_PriceBookEntry_Id__c)) {
                ccPriceListItemsToDelete.add(ccPriceListItem);
            }
            else if (priceBookEntryToCCPriceListItemMap.containsKey(ccPriceListItem.Source_PriceBookEntry_Id__c)) {
                priceBookEntryToCCPriceListItemMap.get(ccPriceListItem.Source_PriceBookEntry_Id__c).add(ccPriceListItem);
            } else {
                priceBookEntryToCCPriceListItemMap.put(ccPriceListItem.Source_PriceBookEntry_Id__c, new List<ccrz__E_PriceListItem__c> { ccPriceListItem });
            }
        }
        
        //Map PriceBook2Entry records to CCPriceListItem records
        List<ccrz__E_PriceListItem__c> ccPriceListItems = copyPriceBookEntryRecords(
            priceBookEntriesToSync, 
            priceBookToCCPriceListsMap,
            product2ToCCProductMap,
            priceBookEntryToCCPriceListItemMap);

        //upsert the CC Price List Item records
        mappingUtils.performUpsert(CPQB2BProcessType.Pricing.name(), ccPriceListItems);

        //delete inactive cc price list item records
        ccPriceListService.deletePriceListItems(ccPriceListItemsToDelete);
    }

    /**
     * @description This maps SBQQ__QuoteLine__c records to ccrz__E_PriceListItem__c records
     *   
     * @params List<SBQQ__QuoteLine__c> quoteLinesToSync
     */
    public void mapPricing(List<SBQQ__QuoteLine__c> quoteLinesToSync) {
        List<Id> productIds = new List<Id>();
        List<Id> accountGroupIds = new List<Id>();
        List<Id> quoteIds = new List<Id>();
        List<Id> accountIds = new List<Id>();
        
        Map<Id, SBQQ__QuoteLine__c> quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();    
        for (SBQQ__QuoteLine__c quoteLine : quoteLinesToSync) {
            //Create a list of product ids to easily query
            productIds.add(quoteLine.SBQQ__Product__c);
            //create a list of account ids
            quoteIds.add(quoteLine.SBQQ__Quote__c);
            //Create a map of Quote Line records by Id to easily query
            quoteLineMap.put(quoteLine.Id, quoteLine);
        }

        //Select the quotes for the quote lines
        List<SBQQ__Quote__c> quotes = new CPQB2BQuoteSelector().selectQuotesByIds(quoteIds);

        //Create a map from quote to price list so that the quote line
        //will be able to quickly find what it needs to associate to
        Map<Id, Id> quoteToPriceListMap = ccPriceListService.getQuoteToPriceListMap(quotes);
        
        // Select all of the existing CCProducts from the Quote Line record
        List<ccrz__E_Product__c> ccProducts = new CPQB2BCCProductSelector().selectBySourceIds(productIds);
        // Map all of the Product2 ids to CCProducts
        Map<Id, ccrz__E_Product__c> product2ToCCProductMap = new Map<Id, ccrz__E_Product__c>();
        for (ccrz__E_Product__c ccProduct : ccProducts) {
            //Map: Product2Id -> CCProduct
           product2ToCCProductMap.put(ccProduct.Source_Product__c, ccProduct);
        }

        // Select all of the existing CCPriceListItems that are associated to the Quote Line records
        List<ccrz__E_PriceListItem__c> existingCCPriceListItems = new CPQB2BCCPriceListItemSelector().getCCPriceListItemsByQuoteLineIds(quoteLineMap.keySet());
        // Map of all the Quote Line ids to CCPriceListItems
        Map<Id, ccrz__E_PriceListItem__c> quoteLineToCCPriceListItemMap = new Map<Id, ccrz__E_PriceListItem__c>();
        for (ccrz__E_PriceListItem__c ccPriceListItem : existingCCPriceListItems) {
            //Map: QuoteLine Id -> CCPriceListItem
            quoteLineToCCPriceListItemMap.put(ccPriceListItem.Quote_Line__c, ccPriceListItem);
        }

       // Map QuoteLine records to CCPriceListItem records
        List<ccrz__E_PriceListItem__c> ccPriceListItems = copyQuoteLineRecords(
            quoteLinesToSync, 
            quoteToPriceListMap,
            product2ToCCProductMap,
            quoteLineToCCPriceListItemMap);

        mappingUtils.performUpsert(CPQB2BProcessType.Pricing.name(), ccPriceListItems);
    }

    /**
     * @description Generates and calculates CPQ Quote record for given a given Cart Id
     *   
     * @param String cartId - The cartId is the encrypted Id (ccrz__EncryptedId__c)
     * @param String quoteDetails - Optional detail string for user to describe quote 
     */
    public void mapCartToQuote(String cartId, String quoteDetails){
        CPQB2BCCCartSelector ccCartSelector = new CPQB2BCCCartSelector();
        ccrz__E_Cart__c cartRecord = ccCartSelector.selectByEncryptionId(cartId);
        cartRecord.Quote_Additional_Details__c = quoteDetails;
            
        CPQB2BQuoteService quoteService = new CPQB2BQuoteService();
        SBQQ__Quote__c quote = quoteService.getNewQuoteFromCart(cartRecord);
        
        try {
            quoteService.calculateQuote(quote);
            CPQB2BCCCartService.setCartToQuoteRequested(new List<ccrz__E_Cart__c>{cartRecord});     
        } catch (Exception e) {
            logger.log(CPQB2BProcessType.CartToQuote.name(),this.triggerEvent,e,new List<SObject>{quote});       
        } finally{
            logger.write();
        }     
    }

    /**
     * @description This maps Order records to ccrz__E_Order__c records
     *   
     * @param List<Id> orderIds
     */
    public void mapCPQOrderToCCOrder(List<Id> orderIds) {
        List<Order> ordersToSync = new CPQB2BOrderSelector().getByIds(orderIds);
        mapCPQOrderToCCOrder(ordersToSync);
    }

    /**
     * @description This maps Order records to ccrz__E_Order__c records
     *   
     * @param List<Order> order
     */
    public void mapCPQOrderToCCOrder(List<Order> orders) {
        Map<Id, Order> ordersMap = new Map<Id, Order>();
        ordersMap.putAll(orders);
        List<Id> orderIds = new List<Id>(ordersMap.keySet());

        List<Address> addresses = new List<Address>();
        for (Order order : orders) {
            if (order.ShippingAddress != null) {
                addresses.add(order.ShippingAddress);
            }

            if (order.BillingAddress != null) {
                addresses.add(order.BillingAddress);
            }
        }

        //find any existing CC Orders
        List<ccrz__E_Order__c> ccOrders = new CPQB2BCCOrderSelector().getBySourceOrderIds(orderIds);
        
        List<ccrz__E_ContactAddr__c> ccAddresses = new List<ccrz__E_ContactAddr__c>();
        if (!addresses.IsEmpty()) {
            //find any existing ccAddresses
          ccAddresses = new CPQB2BCCContactAddressSelector().selectByFullAddress(addresses);
        }

        //Map: Order Id -> CC Order
        Map<Id, ccrz__E_Order__c> orderToCCOrderMap = new Map<Id, ccrz__E_Order__c>();
        for(ccrz__E_Order__c ccOrder : ccOrders){
            orderToCCOrderMap.put(ccOrder.Source_Order__c, ccOrder);
        }

        //Get all of the existing order items for the order
        List<OrderItem> orderItems = new CPQB2BOrderItemSelector().getByOrderIds(orderIds);

        //Copy Orders to CC Orders
        List<ccrz__E_Order__c> updatedCCOrders = copyOrderRecords(orders, orderItems, orderToCCOrderMap, ccAddresses);
        //Upsert CC Order records
        mappingUtils.performUpsert(CPQB2BProcessType.OrderToCCOrder.name(), updatedCCOrders);

        Map<Id, ccrz__E_Order__c> ccOrderMap = new Map<Id, ccrz__E_Order__c>();
        ccOrderMap.putAll(updatedCCOrders);

        //make sure new orders are added to the map
        for (ccrz__E_Order__c ccOrder : updatedCCOrders) {
            orderToCCOrderMap.put(ccOrder.Source_Order__c, ccOrder);
        }

        mapCPQOrderItemToCCOrderItem(orderItems, new List<Id>(ccOrderMap.keySet()), orderToCCOrderMap);
    }
   
    /**
     * @description This maps Order records to ccrz__E_Order__c records
     *   
     * @param List<OrderItems> order
     * @param List<Id> ccOrderIds
     * @param Map<Id, ccrz__E_Order__c> orderToCCOrderMap
     */
    private void mapCPQOrderItemToCCOrderItem(List<OrderItem> orderItems, List<Id> ccOrderIds, Map<Id, ccrz__E_Order__c> orderToCCOrderMap) {
        //Map: Order Id -> order Items
        Map<Id, List<OrderItem>> orderToOrderItemsMap = new Map<Id, List<OrderItem>>();
         
        //Create a list of product2ids so that we can query them
        List<Id> productIds = new List<Id>();
        for (OrderItem oi : orderItems) {
            productIds.add(oi.Product2Id);
        }

        //find any existing CC Orders
        List<ccrz__E_OrderItem__c> ccOrderItems = new CPQB2BCCOrderItemSelector().getByOrderIds(ccOrderIds);

        //Map: Order Item Id -> CC Order  Item
        Map<Id, ccrz__E_OrderItem__c> orderItemToCCOrderItemMap = new Map<Id, ccrz__E_OrderItem__c>();

        for (ccrz__E_OrderItem__c ccOrderItem : ccOrderItems) {  
            orderItemToCCOrderItemMap.put(ccOrderItem.Source_Order_Item__c, ccOrderItem);
        }
        
        List<ccrz__E_OrderItem__c> updatedCCOrderItems = copyOrderItemRecords(orderItems, orderItemToCCOrderItemMap, productIds, orderToCCOrderMap);

        mappingUtils.performUpsert(CPQB2BProcessType.OrderToCCOrder.name(), updatedCCOrderItems);
    }

    /**
     * @description This performs the syncing From CC Orders to CPQ Orders
     *   
     * @param List<Id> ccOrders
     */
    public void mapCCOrderToCPQOrder(List<Id> ccOrderIds) {
        List<ccrz__E_Order__c> ccOrders = new CPQB2BCCOrderSelector().getByIds(ccOrderIds);
        mapCCOrderToCPQOrder(ccOrders);
    }

    /**
     * @description This performs the syncing From CC Orders to CPQ Orders
     *   
     * @param List<ccrz__E_Order__c> ccOrders
     */
    public void mapCCOrderToCPQOrder(List<ccrz__E_Order__c> ccOrders) {
        Map<Id, ccrz__E_Order__c> ccOrdersMap = new Map<Id, ccrz__E_Order__c>();
        ccOrdersMap.putAll(ccOrders);
        List<Id> ccOrderIds = new List<Id>(ccOrdersMap.keySet());

        CPQB2BQuoteService quoteService = new CPQB2BQuoteService();
        //Retrieve the custom status for the quote
        String customQuoteStatus = CPQB2BMappingSelector.getCustomQuoteStatus();
        //Retreive the custom stage for the Opportunity
        String customOpportunityStage = CPQB2BMappingSelector.getCustomOpportunityStage();

        //Check to see if an order has already been created
        List<Order> existingOrders = new CPQB2BOrderSelector().getBySourceOrderIds(ccOrderIds);
        //Map: CC OrderId -> CPQ Order
        Map<Id, Order> ordersMap = new Map<Id, Order>();
        for (Order o : existingOrders) {
            ordersMap.put(o.B2B_Source_Order__c, o);
        }

        //Get the Standard PriceBook
        //TODO: need to add logic to check for a price book in the custom metadata
        Pricebook2 standardPriceBook = new CPQB2BPriceBookSelector().getStandardPriceBook(); 
        //Map the CC Order Id -> List of Product Line Items so that ew can populate product2Id, price, and quantity on the quote line
        Map<Id,List<CPQB2BProductLineItem>> orderProductLineItemMap = mappingUtils.getProductLineItemMapForOrders(ccOrderIds, standardPriceBook.Id);

        Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity>();
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        //Iterate through the cc orders and create the opportunity and quote records
        for (ccrz__E_Order__c ccOrder : ccOrders) {
            Order order = ordersMap.get(ccOrder.Id);
            if (order == null) {
                Opportunity opp = new Opportunity();
                opp.Name = ccOrder.ccrz__OrderName__c;
                opp.AccountId = ccOrder.ccrz__Account__c;
                opp.StageName = customOpportunityStage; 
                opp.CloseDate = ccOrder.ccrz__OrderDate__c;
                opportunitiesMap.put(ccOrder.Id, opp);

                SBQQ__Quote__c quote = quoteService.getNewQuoteFromOrder(ccOrder, standardPriceBook.Id, customQuoteStatus);
                quotes.add(quote);
            }
        }
        
        if (!opportunitiesMap.IsEmpty()) {
            try {
                insert opportunitiesMap.values();
            } catch (Exception e) {
                logger.log(CPQB2BProcessType.CCOrderToOrder.name(),this.triggerEvent,e, opportunitiesMap.values());          
            } finally{
                logger.write();
            } 
        }

        for (SBQQ__Quote__c quote : quotes) {
            Opportunity opp = opportunitiesMap.get(quote.B2B_Source_Order__c);
            if (opp != null) {
                quote.SBQQ__Opportunity2__c = opp.Id;
            }
        }

         if (!quotes.IsEmpty()) {
             try {
                insert quotes;
                quoteService.calculateQuotesFromOrders(quotes, orderProductLineItemMap);
                orderService.updateSyncedCPQOrders(quotes, ccOrdersMap);
                
            } catch (Exception e) {
                logger.log(CPQB2BProcessType.CCOrderToOrder.name(),this.triggerEvent,e, quotes);          
            } finally{
                logger.write();
            } 
        }
    }

    /**
     * copyProductFields Handles mapping Product2 fields to CCProduct records,
     * generating a list of new/updated/deactivated CCProduct records to be upserted
     * @param  productsToSync       List of Product2 records to copy over to CCProduct records
     * @param  sourceToCCProductMap Map of Product Id to CCProduct(Product_Source__c field) used to
     * track pre-existing CCProduct records so we know to update instead inserting a new record
     * @return                      Returns list of CCProduct records to be upserted
     */
    private List<ccrz__E_Product__c> copyProductFields(List<Product2> productsToSync, Map<Id,ccrz__E_Product__c> sourceToCCProductMap){
        List<CPQB2BBaseFieldMapping> productFieldMappings = CPQB2BFieldMapping.getProductFieldMappings();
        //CPQB2BFieldMapping storeFrontMapping = CPQB2BFieldMapping.getProductStoreFrontFieldMapping();
        List<ccrz__E_Product__c> updatedCCProductList = new List<ccrz__E_Product__c>();

        for(Product2 product : productsToSync){

            //initialize a new CC Product record
            ccrz__E_Product__c ccProduct = new ccrz__E_Product__c();
            Boolean relatedCCProductExists = sourceToCCProductMap.containsKey(product.Id);

            //If map contains product Id, then we set the Id
            //prompting a record update instead of inserting a new one
            if(relatedCCProductExists){
                ccProduct = sourceToCCProductMap.get(product.Id);
            }

            //If product sync is active, we copy the fields over to ccproduct record
            if(product.Sync_Product_To_B2B__c){
                //Iterate through the list of required field mappings and copy the
                //source field values from product2 into the destination field
                //values of the CC Product record
                for(CPQB2BBaseFieldMapping fieldMap : productFieldMappings){
                    
                    if(product.get(fieldMap.sourceField)!=null){
                        ccProduct.put(fieldMap.destField,product.get(fieldMap.sourceField));
                    }      
                }

                //If Product2 Storefront field is not null then we assign
                //the value to the synchornized CCProduct Storefront field
                // if(product.get(storeFrontMapping.sourceField)!=null){
                //     ccProduct.put(storeFrontMapping.destField,product.get(storeFrontMapping.sourceField));
                // }

                //If Product2 record is Active and was synced then we 
                //Iterate through the list of custom CPQB2B field mappings and copy the
                //source field values from product2 into the destination field
                //values of the CC Product record
                for (CPQB2BBaseFieldMapping fieldMap : productFieldMappings) {
                    fieldMap.copyValue(product, ccProduct);
                }
                
                //If Product2 record is Active and was synced then we set associated CCProduct status to Released
                //Else we set the status to Blocked
                if(product.isActive){
                    ccProduct.ccrz__ProductStatus__c = 'Released';
                }
                else{
                    ccProduct.ccrz__ProductStatus__c = 'Blocked';
                }

                updatedCCProductList.add(ccProduct);
            }
        }

        return updatedCCProductList;
    }

    /**
     * @description Copy PriceBookEntry fields to the CCPriceListItem record
     *
     * @params List<PriceBookEntry> priceBookEntriesToSync
     * @params Map<Id, ccrz__E_PriceList__c> priceBookToCCPriceListMap
     * @params Map<Id, ccrz__E_Product__c>  product2ToCCProductMap
     * @params Map<Id, ccrz__E_PriceListItem__c> priceBookEntryToCCPriceListItemMap
     * @returns List<ccrz__E_PriceListItem__c>
     */
    private List<ccrz__E_PriceListItem__c> copyPriceBookEntryRecords(
        List<PriceBookEntry> priceBookEntriesToSync, 
        Map<Id, List<ccrz__E_PriceList__c>>  priceBookToCCPriceListsMap,
        Map<Id, ccrz__E_Product__c> product2ToCCProductMap,
        Map<Id, List<ccrz__E_PriceListItem__c> > priceBookEntryToCCPriceListItemMap
    ) { 
        List<ccrz__E_PriceListItem__c> ccPriceListItems = new List<ccrz__E_PriceListItem__c>();
        for (PriceBookEntry priceBookEntry : priceBookEntriesToSync) {
            if (ccPriceListService.isCCPriceListItemExpired(priceBookEntry)) {
                continue;
            }

            // Select the CCPriceList by PriceBook2Id
            List<ccrz__E_PriceList__c> ccPriceLists = priceBookToCCPriceListsMap.get(priceBookEntry.PriceBook2Id);
            if (ccPriceLists == null || ccPriceLists.IsEmpty()) {
                logger.log(CPQB2BProcessType.Pricing.name(), priceBookEntry.PriceBook2Id, priceBookEntry.Id, this.triggerEvent, null, Label.CPQB2B_PriceBookEntry_Sync_No_CCPriceList_Exception);
                continue;
            } 

            Map<Id, ccrz__E_PriceListItem__c> existingPriceListItems = new Map<Id, ccrz__E_PriceListItem__c>();

            // Check to see if there is a saved CCPriceListItem and if so retrieve it from the map
            if (priceBookEntryToCCPriceListItemMap.containsKey(priceBookEntry.Id) == true) {
                List<ccrz__E_PriceListItem__c> priceListItems = priceBookEntryToCCPriceListItemMap.get(priceBookEntry.Id);
                //Because a price book entry record could be associated with multiple prie lists, need to create a map.
                for (ccrz__E_PriceListItem__c pli : priceListItems) {
                    existingPriceListItems.put(pli.ccrz__Pricelist__c, pli);
                }
            }

            for (ccrz__E_PriceList__c ccPriceList : ccPriceLists) {
                //get the currency for the price book entry
                String currencyType = mappingUtils.getCurrencyType(priceBookEntry);
                ccrz__E_PriceListItem__c ccPriceListItem;

                //Check to see if a price list item for the price list already exists
                //if not then create a new object
                if (existingPriceListItems.containsKey(ccPriceList.Id)) {
                    ccPriceListItem = existingPriceListItems.get(ccPriceList.Id);
                } else if (currencyType == ccPriceList.ccrz__CurrencyISOCode__c) {
                    ccPriceListItem = new ccrz__E_PriceListItem__c(ccrz__Pricelist__c=ccPriceList.Id);          
                }

                if (ccPriceListItem != null) {
                    Boolean isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
                    if (isMultiCurrency) {
                        ccPriceListItem.put('CurrencyIsoCode', currencyType);
                    }

                    // Select the CCProduct by Product2Id
                    ccrz__E_Product__c ccProduct =  product2ToCCProductMap.get(priceBookEntry.Product2Id);
                    if (ccProduct != null) {
                        ccPriceListItem.ccrz__Product__c = ccProduct.Id;
                    }
        
                    //Map all of the price book entry fields to CC Price List Item fields
                    for (CPQB2BBaseFieldMapping fieldMap : CPQB2BFieldMapping.getPriceBookEntryFieldMappings()) {
                        fieldMap.copyValue(priceBookEntry, ccPriceListItem);
                    }
                    ccPriceListItems.add(ccPriceListItem);
                }
            }
        }
        logger.write();
        return ccPriceListItems;
    }


    /**
     * @description Copy QuoteLine Items fields to the CCPriceListItem record
     *
     * @param List<SBQQ__QuoteLine__c> quoteLinesToSync
     * @param Map<Id, ccrz__E_PriceList__c> quoteToCCPriceListMap
     * @param Map<Id, ccrz__E_Product__c>  product2ToCCProductMap
     * @param Map<Id, ccrz__E_PriceListItem__c> quoteLineToCCPriceListItemMap
     * @return List<ccrz__E_PriceListItem__c>
     */
    private List<ccrz__E_PriceListItem__c> copyQuoteLineRecords(
        List<SBQQ__QuoteLine__c> quoteLinesToSync, 
        Map<Id, Id> quoteToCCPriceListMap,
        Map<Id, ccrz__E_Product__c> product2ToCCProductMap,
        Map<Id, ccrz__E_PriceListItem__c> quoteLineToCCPriceListItemMap
    ) { 
        List<ccrz__E_PriceListItem__c> ccPriceListItems = new List<ccrz__E_PriceListItem__c>();

        for (SBQQ__QuoteLine__c quoteLine : quoteLinesToSync) {
            Id ccPriceListId = quoteToCCPriceListMap.get(quoteLine.SBQQ__Quote__c);

            ccrz__E_PriceListItem__c ccPriceListItem = new ccrz__E_PriceListItem__c(ccrz__Pricelist__c=ccPriceListId);
            ccPriceListItem.Quote_Line__c = quoteLine.Id;
            // Check to see if there is a save CCPriceListItem and if so retrieve it from the map
            if (quoteLineToCCPriceListItemMap.containsKey(quoteLine.Id) == true) {
                ccPriceListItem = quoteLineToCCPriceListItemMap.get(quoteLine.Id);
            }

            //If the quote is expired, make sure the price list item is expired by setting the end date to yesterday
            if (quoteLine.SBQQ__Quote__r.SBQQ__ExpirationDate__c < Date.Today()) {
                ccPriceListItem.ccrz__EndDate__c = Date.Today().addDays(-1);
            }

            // Select the CCProduct by Product2Id
            ccrz__E_Product__c ccProduct =  product2ToCCProductMap.get(quoteLine.SBQQ__Product__c);
            if (ccProduct != null) {
                ccPriceListItem.ccrz__Product__c = ccProduct.Id;
            }

            for (CPQB2BBaseFieldMapping fieldMap : CPQB2BFieldMapping.getQuoteLineFieldMappings()) {
                fieldMap.copyValue(quoteLine, ccPriceListItem);
            }

            String currencyType = mappingUtils.getCurrencyType(quoteLine.SBQQ__Quote__r);
            Boolean isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
            if (isMultiCurrency) {
                ccPriceListItem.put('CurrencyIsoCode', currencyType);
            }

            ccPriceListItems.add(ccPriceListItem);
        }
        return ccPriceListItems;
    }

     /**
     * @description Copy the order record to the cc order record
     *
     * @param List<Order>  Order
     * @param Map<Id, ccrz__E_Order__c>   orderToCCOrderMap
     * @param Map<Id, Id> accountToAccountGroupMap
     * @param Map<Id, List<ccrz__E_PriceList__c>> priceListsMap,
     * @param Map<Id, User> contactToUserMap
     * @return List<ccrz__E_Order__c>
     */
    private List<ccrz__E_Order__c> copyOrderRecords(List<Order> ordersToSync, List<OrderItem> orderItemsToSync, Map<Id, ccrz__E_Order__c> orderToCCOrderMap, List<ccrz__E_ContactAddr__c> ccAddresses) {
        //Map: Order -> Currency taken from the order items
        Map<Id, String> orderCurrencyMap = orderService.getOrderCurrencyMap(orderItemsToSync);

        //Map: Contact Id -> User
        Map<Id, User> contactToUserMap = orderService.getContactUserMapForOrder(ordersToSync);

        List<ccrz__E_Order__c> ccOrders = new List<ccrz__E_Order__c>();
        for (Order o : ordersToSync) {
            ccrz__E_Order__c ccOrder = new ccrz__E_Order__c();
            //Check to see if the cc order already exists
            if (orderToCCOrderMap.containsKey(o.Id)) {
                ccOrder = orderToCCOrderMap.get(o.Id);
            }
            
            List<Address> addresses = new List<Address>();
            if (o.ShippingAddress != null) {
                addresses.add(o.ShippingAddress);
            }

            if (o.BillingAddress != null) {
                addresses.add(o.BillingAddress);
            }

            if (!addresses.isEmpty()) {
                Map<Address, ccrz__E_ContactAddr__c> addressToCCAddressMap = mappingUtils.getMatchingCCAddresses(addresses, ccAddresses);

                ccrz__E_ContactAddr__c shippingAddress = addressToCCAddressMap.get(o.ShippingAddress);
                ccrz__E_ContactAddr__c billingAddress = addressToCCAddressMap.get(o.BillingAddress);

                if (shippingAddress != null) {
                    ccOrder.ccrz__ShipTo__c = shippingAddress.Id;
                }

                if (billingAddress != null) {
                    ccOrder.ccrz__BillTo__c = billingAddress.Id;
                }
            }

            if (orderCurrencyMap.containsKey(o.Id)) {
                ccOrder.ccrz__CurrencyISOCode__c  = orderCurrencyMap.get(o.Id);
            }

            for (CPQB2BBaseFieldMapping fieldMap : CPQB2BFieldMapping.getOrderToCCOrderMappings()) {
                fieldMap.copyValue(o, ccOrder);
            }
       
            //If the contact was populated, we need to query the user to populate the owner and user fields
            if (ccOrder.ccrz__Contact__c != null) {
                User user = contactToUserMap.get(ccOrder.ccrz__Contact__c);
                if (user != null) {
                    ccOrder.OwnerId = user.Id;
                    ccOrder.ccrz__User__c = user.Id;
                }
            }

            //If there isn't a custom metadata mapping then needs to be set to 'Completed'
            if (ccOrder.ccrz__OrderStatus__c == null) {
                ccOrder.ccrz__OrderStatus__c = 'Completed';
            }

            //Assign the origin cart id to the cc order origin cart id field
            if(o.SBQQ__Quote__c != null && o.SBQQ__Quote__r.B2B_Source__c != null){
                ccOrder.ccrz__OriginatedCart__c = o.SBQQ__Quote__r.B2B_Source__c;
            }

            ccOrders.add(ccOrder);
        }    
        return ccOrders;
    }

     /**
     * @description Copy the orderitem record to the cc order record
     *
     * @param List<OrderItem>  Order
     * @param Map<Id, ccrz__E_OrderItem__cs>   orderToCCOrderItemMap
     * @param List<Id> productIds
     * @param Map<Id, ccrz__E_Order__c> orderToCCOrderMap
     */
    private List<ccrz__E_OrderItem__c> copyOrderItemRecords(List<OrderItem> orderItems, Map<Id, ccrz__E_OrderItem__c> orderItemToCCOrderItemMap, List<Id> productIds, Map<Id, ccrz__E_Order__c> orderToCCOrderMap) {
        // Select all of the existing CCProducts from the Quote Line record
        List<ccrz__E_Product__c> ccProducts = new CPQB2BCCProductSelector().selectBySourceIds(productIds);
        // Map all of the Product2 ids to CCProducts
        Map<Id, ccrz__E_Product__c> product2ToCCProductMap = new Map<Id, ccrz__E_Product__c>();
        for (ccrz__E_Product__c ccProduct : ccProducts) {
            //Map: Product2Id -> CCProduct
            product2ToCCProductMap.put(ccProduct.Source_Product__c, ccProduct);
        }

        List<ccrz__E_OrderItem__c> updatedCCOrderItems = new List<ccrz__E_OrderItem__c>();
        for (OrderItem orderItem : orderItems) {
            ccrz__E_OrderItem__c ccOrderItem = new ccrz__E_OrderItem__c();
            //Check to see if we have already saved a CC Order Item
            if (orderItemToCCOrderItemMap.containsKey(orderItem.Id)) {
                ccOrderItem = orderItemToCCOrderItemMap.get(orderItem.Id);
            } else {
                //Set the CC order Id
                ccOrderitem.ccrz__Order__c = orderToCCOrderMap.get(orderItem.OrderId).Id;
            }

            //set the CC product Id
            ccOrderitem.ccrz__Product__c = product2ToCCProductMap.get(orderitem.Product2Id).Id;

            //Enter static order mapping data
            ccOrderItem.ccrz__ItemStatus__c = 'Available';
            ccOrderItem.ccrz__OrderLineType__c = 'Major';
            ccOrderItem.ccrz__ProductType__c = 'Product';
            ccOrderItem.ccrz__UnitOfMeasure__c = 'Each';

            for (CPQB2BBaseFieldMapping fieldMap : CPQB2BFieldMapping.getOrderItemToCCOrderItemMappings()) {
                fieldMap.copyValue(orderItem, ccOrderItem);
            }
            if (ccOrderItem.ccrz__Price__c != null && ccOrderItem.ccrz__Quantity__c != null) {
                ccOrderItem.ccrz__SubAmount__c = ccOrderItem.ccrz__Price__c * ccOrderItem.ccrz__Quantity__c;
            }
  
            updatedCCOrderItems.add(ccOrderItem);
        }
        
        return updatedCCOrderItems;
    }
}