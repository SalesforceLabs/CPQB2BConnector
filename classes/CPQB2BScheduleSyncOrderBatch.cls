/**
* @author Ashlee Zeigler
* @date 2-27-2020
*
* @see CPQB2BSyncOrderBatch
* @description This is the Schedulable class that will schedule the Sync Order batch to run at a certain time
*/
global with sharing class CPQB2BScheduleSyncOrderBatch implements Schedulable {
    /*******************************************************************************************************
    * @description Execute the scheduling of the batch
    * @param Database.SchedulableContext
    */  
   global void execute(SchedulableContext sc) {
        CPQB2BSyncOrderBatch batch = new CPQB2BSyncOrderBatch();
        Database.executeBatch(batch, 200);
    }
}