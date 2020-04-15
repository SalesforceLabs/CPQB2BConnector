trigger CPQB2BCCProductTrigger on ccrz__E_Product__c (before insert, before update) {
    CPQB2BDomain.triggerHandler(CPQB2BCCProductDomain.class);
}