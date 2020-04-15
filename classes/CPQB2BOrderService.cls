/**
* Created by Ashlee Zeigler on 3/3/20.
* @date 3/3/2020
*
* @description Service that will handle more comple data syncing operations for Order to Order Sync
* @see CPQB2BLogger
* @see CPQB2BMappingUtils
*/
public class CPQB2BOrderService {
    public CPQB2BLogger logger {get;set;}
    public String triggerEvent {get;set;}
    public CPQB2BMappingUtils mappingUtils {get;set;}

    public CPQB2BOrderService() {
        this('');
    }

    public CPQB2BOrderService(String triggerEvent) {
        this.triggerEvent = triggerEvent;
        this.logger = new CPQB2BLogger();
        this.mappingUtils = new CPQB2BMappingUtils(triggerEvent);
    }

    /**
     * @description This will get a map of Order It to Currency
     *  
     * @param List<OrderItem> ids
     * @return Map<Id, String> map of OrderId to Currency
     */
    public Map<Id, String> getOrderCurrencyMap(List<OrderItem> orderItems) {
        Map<Id, String> orderCurrencyMap = new Map<Id, String>();
        List<Id> priceBookEntryIds = new List<Id>();
        Map<Id, List<Id>> orderPriceBookEntryMap = new Map<Id, List<Id>>();
        for (OrderItem oi : orderItems) {
            //Create a list of pricebookentry records
            priceBookEntryIds.add(oi.PriceBookEntryId);

            //Create an order to PriceBookEntry ids map
            if (orderPriceBookEntryMap.containsKey(oi.OrderId)) {
                orderPriceBookEntryMap.get(oi.OrderId).add(oi.PriceBookEntryId);
            } else {
                orderPriceBookEntryMap.put(oi.OrderId, new List<Id> { oi.PriceBookEntryId });
            }
        }

        //Map: PriceBookEntryId -> PriceBookEntry
        Map<Id, PriceBookEntry> priceBookEntryMap = new Map<Id, PriceBookEntry>();
        List<PriceBookEntry> priceBookEntries = new CPQB2BPriceBookEntrySelector().getPricebookEntryByIds(priceBookEntryIds);
        priceBookEntryMap.putAll(priceBookEntries);

        List<PriceBookEntry> orderPbes = new List<PriceBookEntry>();

        for (OrderItem oi : orderItems) {
            //Get a list of all the pricebookentry records for an order
            if (orderPriceBookEntryMap.containsKey(oi.OrderId)) {
                List<Id> ids = orderPriceBookEntryMap.get(oi.orderId);
                for (Id id : ids) {
                    orderPbes.add(priceBookEntryMap.get(id));
                }
                //we are assuming all the pricebookentry records are the same, just get the first currency value
                orderCurrencyMap.put(oi.OrderId, mappingUtils.getCurrencyType(orderPbes[0]));
            }
        }
        return orderCurrencyMap;
    }

    /**
     * @description This will get the contact and user mapping from the ShipToContactId
     *  so that it can be easily queried when doing the insert (bulkification)
     * @param List<Order> orders
     * @return Map<Id, User> map of Contact Id to User for Owner Mappings
     */
    public Map<Id, User> getContactUserMapForOrder(List<Order> orders) {
        List<Id> contactIds = new List<Id>();
        for (Order o : orders) {
            //Check to see if the ShipToContact id is populated
            if (o.ShipToContactId != null) {
                contactIds.add(o.ShipToContactId);
            }
        }

        //Pull all of the user records for the associated contacts
        List<User> userForContacts = new CPQB2BUserSelector().getByContactIds(contactIds);
        //Map: Contact Id -> User
        Map<Id, User> contactToUserMap = new Map<Id, User>();
        for(User u : userForContacts) {
            if (u.ContactId != null) {
                contactToUserMap.put(u.ContactId, u);
            }
        }
        return contactToUserMap;
    }

    /**
     * @description Set the Orders for the quotes to the status defined in the custom metadata
     *  and copy BillTo and Ship to Addresses
     * @param List<SBQQ__Quote__c> quotes
     * @param Map<Id, ccrz__E_Order__c> ccOrderMap
     */
    public void updateSyncedCPQOrders(List<SBQQ__Quote__c> quotes, Map<Id, ccrz__E_Order__c> ccOrderMap) {
        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>();
        quoteMap.putAll(quotes);
        List<Id> quoteIds = new List<Id>(quoteMap.keySet());

        String status = CPQB2BMappingSelector.getCustomOrderStatus();
        List<Order> ordersToUpdate = new CPQB2BOrderSelector().getByQuoteIds(quoteIds);

        for(Order order : ordersToUpdate) {
            order.Status = status;
            ccrz__E_Order__c ccOrder = ccOrderMap.get(order.B2B_Source_Order__c);
            if (ccOrder != null) {
                if (ccOrder.ccrz__ShipTo__r != null) {
                    order.ShippingStreet = ccOrder.ccrz__ShipTo__r.ccrz__AddressFirstline__c;
                    order.ShippingCity = ccOrder.ccrz__ShipTo__r.ccrz__City__c;
                    order.ShippingCountry = ccOrder.ccrz__ShipTo__r.ccrz__Country__c;
                    order.ShippingState = ccOrder.ccrz__ShipTo__r.ccrz__StateISOCode__c;
                    order.ShippingPostalCode = ccOrder.ccrz__ShipTo__r.ccrz__PostalCode__c;
                }

                if (ccOrder.ccrz__BillTo__r != null) {
                    order.BillingStreet = ccOrder.ccrz__BillTo__r.ccrz__AddressFirstline__c;
                    order.BillingCity = ccOrder.ccrz__BillTo__r.ccrz__City__c;
                    order.BillingCountry = ccOrder.ccrz__BillTo__r.ccrz__Country__c;
                    order.BillingState = ccOrder.ccrz__BillTo__r.ccrz__StateISOCode__c;
                    order.BillingPostalCode = ccOrder.ccrz__BillTo__r.ccrz__PostalCode__c;
                }
            }
        }

        try {
            update ordersToUpdate;
        } catch (Exception e) {
            logger.log(CPQB2BProcessType.CCOrderToOrder.name(),this.triggerEvent,e, ordersToUpdate);
            throw e;  //throws the caught exception so that the quote btn controller displays error on quote modal          
        } finally{
            logger.write();
        }  
    }
}