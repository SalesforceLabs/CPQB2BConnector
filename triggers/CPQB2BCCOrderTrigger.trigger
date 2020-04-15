trigger CPQB2BCCOrderTrigger on ccrz__E_Order__c (after insert, after update) {
    CPQB2BDomain.triggerHandler(CPQB2BCCOrderDomain.class);
}