trigger CPQB2BCCQuoteLineTrigger on SBQQ__QuoteLine__c (after insert, after update) {
    CPQB2BDomain.triggerHandler(CPQB2BQuoteLineDomain.class);
}