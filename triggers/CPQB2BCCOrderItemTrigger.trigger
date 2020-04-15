trigger CPQB2BCCOrderItemTrigger on ccrz__E_OrderItem__c (after insert, after update) {
    CPQB2BDomain.triggerHandler(CPQB2BCCOrderItemDomain.class);
}