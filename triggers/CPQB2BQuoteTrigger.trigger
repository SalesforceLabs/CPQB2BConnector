trigger CPQB2BQuoteTrigger on SBQQ__Quote__c (after insert, after update) {
    CPQB2BDomain.triggerHandler(CPQB2BQuoteDomain.class);
}