trigger CPQB2BProduct2Trigger on Product2 (after insert, after update) {
    CPQB2BDomain.triggerHandler(CPQB2BProduct2Domain.class);
}