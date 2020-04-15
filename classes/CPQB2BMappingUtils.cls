/**
* Created by Ashlee Zeigler on 3/3/20.
* @date 3/3/2020
*
* @see CPQB2BLogger
* @description Service that will hold misc Util methods to assist in the mapping process
* 
*/
public class CPQB2BMappingUtils {
    public CPQB2BLogger logger {get;set;}
    public String triggerEvent {get;set;}

    public CPQB2BMappingUtils() {
        this('');
    }

    public CPQB2BMappingUtils(String triggerEvent) {
        logger = new CPQB2BLogger();
        triggerEvent = triggerEvent;
    }

     /**
     * @description Return the currency of the current object
     *
     * @param SOBject object
     * @return String Currency Type
     */
    public String getCurrencyType(SObject record) {
        if (record == null) {
            return null;
        }

        String currencyType;
        Boolean isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
        //Populate the currency of price list from either the quote or by the default currency if a single currency org
        if (isMultiCurrency) {
            currencyType = (String)record.get('CurrencyIsoCode');
        } else {
            currencyType = UserInfo.getDefaultCurrency();
        }
        return currencyType;
    }

    /**
     * @description Perform upsert and any logging into failures
     *
     * @param List<SObject>  object
     */
    public void performUpsert(String processType, List<SObject> sObjects) {
        List<Database.UpsertResult> dsrs;
        try {
            dsrs = Database.Upsert(sObjects, false);
            logger.log(processType, this.triggerEvent, dsrs, sObjects);     
        } catch (Exception e) {
            logger.log(processType, this.triggerEvent, e, sObjects);    
        } finally{
            logger.write();
        }
    }
    
    /**
     * @description Retrieves a list of CC Cart Item Ids that are associated to the given cartId
     *
     * @param Id  cartId - Id of the cart
     * @return List<Id> - List of cart item ids related to the cart
     */
    public List<Id> getCCProductIdsFromCartId(Id cartId) {
        CPQB2BCCCartItemSelector ccCartItemSelector = new CPQB2BCCCartItemSelector();
        List<ccrz__E_CartItem__c> cartItemList = ccCartItemSelector.getCartItemsByCartId(cartId);
        List<Id> ccProductIds = new List<Id>();
        
        Map<Id,Integer> productToQuantityMap = new Map<Id,Integer>();
        
        for(ccrz__E_CartItem__c cartItem : cartItemList){
            ccProductIds.add(cartItem.ccrz__Product__c);
        }

        return ccProductIds;
    }
    /**
     * @description Given cart/account id combo, method gets associated products and then
     * looks to the account record to see if price is determined by best price or sequence order.
     * once price method is determined, CPQB2BProductLineItem records are constructed using the product
     * and pricing details for reference.  CPQB2BProductLineItem are then returned as a map
     * @param Id  cartId - Id of the cart
     * @param Id  accountId - Id of the associated account
     * @return Map<Id,CPQB2BProductLineItem> - Product2 Id to CPQB2BProductLineItem
     */
    public Map<Id,CPQB2BProductLineItem> getProductLineItemMap(Id cartId, Id accountId) {
        CPQB2BCCCartItemSelector ccCartItemSelector = new CPQB2BCCCartItemSelector();
        List<ccrz__E_CartItem__c> cartItemList = ccCartItemSelector.getCartItemsByCartId(cartId);
        List<Id> ccProductIds = new List<Id>();
        
        Map<Id,Integer> productToQuantityMap = new Map<Id,Integer>();
        
        for(ccrz__E_CartItem__c cartItem : cartItemList){
            productToQuantityMap.put(cartItem.ccrz__Product__c,(Integer)cartItem.ccrz__Quantity__c);
            ccProductIds.add(cartItem.ccrz__Product__c);
        }

        //Query the associated Account Group to get the price selection method
        CPQB2BCCAccountGroupSelector acctGrpSelector = new CPQB2BCCAccountGroupSelector();
        ccrz__E_AccountGroup__c acctGroup = acctGrpSelector.getAccountGroupByAccountId(accountId);
        String priceSelectionMethod = acctGroup.ccrz__PriceListSelectionMethod__c;
        Map<Id,CPQB2BProductLineItem> productLineItemMap = new Map<Id,CPQB2BProductLineItem>();
        
        CPQB2BProductLineItemService pliService = new CPQB2BProductLineItemService(ccProductIds,productToQuantityMap,acctGroup.Id);
        
        if(priceSelectionMethod.equalsIgnoreCase('Sequence Order')){
            productLineItemMap = pliService.getProductLineItemsByLowestSequence();
        }
        else if(priceSelectionMethod.equalsIgnoreCase('Best Price')){
            productLineItemMap = pliService.getProductLineItemsByLowestPrice();
        }
        
        return productLineItemMap;
    }

    /**
     * @description Return a map of CC Product Id -> Product2Id
     *
     * @param List<ccrz__E_OrderItem__c> ccOrderItems
     * @return Map<Id, Id> Map CC Product Id => Product2 Id
     */
    public Map<Id, Id> getCCProductToProduct2Map(List<ccrz__E_OrderItem__c> ccOrderItems) {
        List<Id> ccProductIds = new List<Id>();
        for(ccrz__E_OrderItem__c ccOrderItem : ccOrderItems) {
            ccProductIds.add(ccOrderItem.ccrz__Product__c);
        }

        Map<Id, Id> ccProductToProduct2Map = new Map<Id, Id>();
        List<ccrz__E_Product__c> ccProdList = new CPQB2BCCProductSelector().selectByIds(ccProductIds);
        for (ccrz__E_Product__c ccProduct : ccProdList) {
            ccProductToProduct2Map.put(ccProduct.Id, ccProduct.Source_Product__c);
        }
        return ccProductToProduct2Map;
    }

    /**
     * @description Return a map of CC Order Id -> List of CP2B2bProductLine Items
     * This will be generate quote lines and subsequently orders from a list of CC Orders
     * @param List<Id> ccOrderIds
     * @param Id priceBookId
     * @return Map<Id,List<CPQB2BProductLineItem>>
     */
    public Map<Id,List<CPQB2BProductLineItem>> getProductLineItemMapForOrders(List<Id> ccOrderIds, Id priceBookId) {
        Map<Id,List<CPQB2BProductLineItem>> productLineItemMap = new Map<Id,List<CPQB2BProductLineItem>>();
        List<ccrz__E_OrderItem__c> ccOrderItems = new CPQB2BCCOrderItemSelector().getByOrderIds(ccOrderIds);

        //Create a map of CC Product Id -> Product2Id
        Map<Id, Id> ccProductToProduct2Map =  getCCProductToProduct2Map(ccOrderItems);
        
        for(ccrz__E_OrderItem__c orderItem : ccOrderItems){

            //Generate a new ProductLineItem with the appropriate quantity and price from the order
            CPQB2BProductLineItem productLineItem = new CPQB2BProductLineItem(ccProductToProduct2Map.get(orderItem.ccrz__Product__c), priceBookId, orderItem.ccrz__Price__c, (Integer)orderItem.ccrz__Quantity__c);
            if (productLineItemMap.containsKey(orderItem.ccrz__Order__c)) {
                productLineItemMap.get(orderItem.ccrz__Order__c).add(productLineItem);
            } else {
                productLineItemMap.put(orderItem.ccrz__Order__c, new List<CPQB2BProductLineItem>{ productLineItem });
            }
        }

        return productLineItemMap;
    }

    /**
     * @description This takes in a standard address object and compares its fields to the 
     * fields on the CC Contact Address record to determine if there is a match
     * 
     * @param Address address
     * @param ccrz__E_ContactAddr__c ccAddress
     * @return Boolean to indicate if the provided addresses match
     */
    public Boolean doAddressesMatch(Address address, ccrz__E_ContactAddr__c ccAddress) {

        Boolean isMatch = ccAddress.ccrz__AddressFirstline__c.equalsIgnoreCase(address.street)
        && ccAddress.ccrz__City__c != null && ccAddress.ccrz__City__c.equalsIgnoreCase(address.City)
        && ccAddress.ccrz__Country__c != null && ccAddress.ccrz__Country__c.equalsIgnoreCase(address.Country)
        && ccAddress.ccrz__StateISOCode__c != null && ccAddress.ccrz__StateISOCode__c.equalsIgnoreCase(address.State)
        && ccAddress.ccrz__PostalCode__c != null && ccAddress.ccrz__PostalCode__c.equalsIgnoreCase(address.PostalCode);

        return isMatch;
    }

    /**
     * @description This takes in a standard Address object and a list of CC Addresses and tries to find
     * a matching CC Address record for the standard Address object. If one is not found, it instantiates a new CC Address
     * record and returns that
     * 
     * @param Address address
     * @param List<ccrz__E_ContactAddr__c> ccAddresses
     * @return ccrz__E_ContactAddr__c 
     */
    public ccrz__E_ContactAddr__c getMatchingCCAddress(Address address, List<ccrz__E_ContactAddr__c> ccAddresses) {
        ccrz__E_ContactAddr__c matchingAddress = null;
        for (ccrz__E_ContactAddr__c ccAddress : ccAddresses) {
            //Check to see if the two addresses are the same
            if (doAddressesMatch(address, ccAddress)) {
                matchingAddress = ccAddress;
                return ccAddress;
            }
        }
        
        //There is no corresponding ccrz__E_ContactAddr__c, so we need to create a new one
        if (matchingAddress == null) {
            matchingAddress = new ccrz__E_ContactAddr__c();
            matchingAddress.ccrz__AddressFirstline__c = address.street;
            matchingAddress.ccrz__City__c = address.City;
            matchingAddress.ccrz__StateISOCode__c = address.State;
            matchingAddress.ccrz__PostalCode__c = address.PostalCode;
            matchingAddress.ccrz__Country__c = address.Country;
        }
        return matchingAddress;
    }

    /**
     * @description This gets a map of a Standard Address object to a CC Address object
     * 
     * @param List<Address> addresses
     * @param List<ccrz__E_ContactAddr__c> ccAddresses
     * @return Map<Address, ccrz__E_ContactAddr__c> 
     */
    public Map<Address, ccrz__E_ContactAddr__c> getMatchingCCAddresses(List<Address> addresses, List<ccrz__E_ContactAddr__c> ccAddresses) {
        //Map: Address -> ccrz__E_ContactAddr__c
        Map<Address, ccrz__E_ContactAddr__c> addressToCCAddressMap = new Map<Address, ccrz__E_ContactAddr__c>();
        //For each address, try to find the matching one
        for (Address address : addresses) {
            ccrz__E_ContactAddr__c matchingAddress = getMatchingCCAddress(address, ccAddresses);
            addressToCCAddressMap.put(address, matchingAddress);
        }
        //perform an upsert to make sure any new ccrz__E_ContactAddr__c are persted.
        performUpsert(CPQB2BProcessType.OrderToCCOrder.name(), addressToCCAddressMap.values());
        return  addressToCCAddressMap;
    }
}