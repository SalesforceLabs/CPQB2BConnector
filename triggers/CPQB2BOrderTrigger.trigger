/**
 * @description Trigger to handle of syncing Orders to CC Orders
 */
trigger CPQB2BOrderTrigger on Order (after insert, after update) {
    CPQB2BDomain.triggerHandler(CPQB2BOrderDomain.class);
}