/**
* @author Amil Abdallah
* @date 02/21/2020
*
* @description Handles logic to generate log records for any records that fail
* during a CPQ/B2B syncing processes.
*/
public class CPQB2BLoggingService{
    /**
     * logErrorsAsync Translates serialized json log records into CPQB2BLog__c records
     * and inserts them into the database with a future context asynchrounously (@future)
     * @param  errorList Serialized json list of wrapper log records
     */
    @future
    public static void logErrorsAsync(List<String> errorList){

        List<CPQB2BLog> logWrapperList = new List<CPQB2BLog>();
        for(String record : errorList){
            CPQB2BLog logWrapper = (CPQB2BLog) JSON.deserialize(record,CPQB2BLog.class);
            logWrapperList.add(logWrapper);
        }

        List<CPQB2BLog__c> logObjList = CPQB2BLoggingService.getLogsFromWrapper(logWrapperList);

        try{
            Database.insert(logObjList);
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        
    }
    /**
     * logErrors Translates serialized json log records into CPQB2BLog__c records
     * and inserts them into the database with a future context
     * @param  errorList Serialized json list of wrapper log records
     */
    public static void logErrors(List<String> errorList){

        List<CPQB2BLog> logWrapperList = new List<CPQB2BLog>();
        for(String record : errorList){
            CPQB2BLog logWrapper = (CPQB2BLog) JSON.deserialize(record,CPQB2BLog.class);
            logWrapperList.add(logWrapper);
        }

        List<CPQB2BLog__c> logObjList = CPQB2BLoggingService.getLogsFromWrapper(logWrapperList);

        try{
            Database.insert(logObjList);
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        
    }
    
    /**
     * logBatchErrors Translates serialized json log records into CPQB2BLog__c records
     * and inserts them into the database without a future context
     * @param  errorList Serialized json list of wrapper log records
     */
    public static void logBatchErrors(List<String> errorList){

        List<CPQB2BLog> logWrapperList = new List<CPQB2BLog>();
        for(String record : errorList){
            CPQB2BLog logWrapper = (CPQB2BLog) JSON.deserialize(record,CPQB2BLog.class);
            logWrapperList.add(logWrapper);
        }

        List<CPQB2BLog__c> logObjList = CPQB2BLoggingService.getLogsFromWrapper(logWrapperList);

        try{
            Database.insert(logObjList);
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        
    } 

    /**
     * getLogsFromWrapper Translates log wrapper records into CPQB2BLog__c records
     * to be inserted into the database
     * @param  logWrapperList List of log wrapper records
     * @return logObjList List of CPQB2BLog__c records to be inserted
     */
    public static List<CPQB2BLog__c> getLogsFromWrapper(List<CPQB2BLog> logWrapperList){

        List<CPQB2BLog__c> logObjList = new List<CPQB2BLog__c>();

        for(CPQB2BLog logWrapper : logWrapperList){
            logObjList.add(new CPQB2BLog__c(
                Process_Type__c = logWrapper.processType,
                Record_Id__c = logWrapper.recordId,    
                Source_Record_Id__c = logWrapper.sourceId,
                Error_Message__c = logWrapper.message,
                Triggering_Event__c = logWrapper.triggerEvent,
                Stack_Trace__c = logWrapper.stackTrace
            ));
        }
        return logObjList;
    }
}