/**
 * @description Trigger to subscribe to the Connector platform events
 */
trigger CPQB2BConnectorTrigger on CPQ_B2B_Connector__e (after insert) {

    CPQB2BConnectorTriggerHandler th = new CPQB2BConnectorTriggerHandler(Trigger.newMap);
    th.run();

}