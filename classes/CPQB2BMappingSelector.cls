/**
 * Created by javierarroyo on 2/12/20.
 * @description This class encapsulates the logic for obtaining the custom mapping fields used in the CPQ-B2B Connector
 *
 */
public class CPQB2BMappingSelector {

    /**
     * @description find the mappings for the process. Note: this class returns a convenience list of attributes that
     * map directly to the CPQ_B2B_Mapping__mdt meta data.
     * @param p - the Enumeration that identifies the process to query
     *
     * @return an instance of CPQB2BMappingSelector
     */
    public static List<CPQB2BBaseFieldMapping> getMappingByProcess(CPQB2BProcessType p) {
        List<CPQ_B2B_Mapping__mdt> mappings = [
                Select
                Source_Object__r.QualifiedApiName,
                Source_Field__r.QualifiedApiName,
                Destination_Object__r.QualifiedApiName,
                Destination_Field__r.QualifiedApiName,
                Field_Mapping_Service_Class__c,
                Source_Value__c
                From
                    CPQ_B2B_Mapping__mdt
                WHERE
                    Process__c =: p.name()
                ];
        if (mappings == null || mappings.size() < 1) return null;
        
        List<CPQB2BBaseFieldMapping> mapList = new List<CPQB2BBaseFieldMapping>();

        for(CPQ_B2B_Mapping__mdt m: mappings) {
            CPQB2BBaseFieldMapping fieldMap;
            if (m.Field_Mapping_Service_Class__c != null) {
                Type t = Type.forName(m.Field_Mapping_Service_Class__c );
                fieldMap = (CPQB2BBaseFieldMapping)t.newInstance();
                fieldMap.setFieldMapping(m);
            } else {
                fieldMap = new CPQB2BFieldMapping(m);
            }
            mapList.add(fieldMap); 
        }

        return mapList;
    }

    /**
     * @description retrieves the custom defined quote status value
     * when a quote is generated from a cart
     *
     * @return a String value of custom defined quote status
     */
    public static String getCustomQuoteStatus() {
        List<CPQ_B2B_Mapping__mdt> mappings = [
                Select 
                    Source_Value__c
                From
                    CPQ_B2B_Mapping__mdt
                WHERE
                    Process__c = 'CartToQuote'
                AND 
                    QualifiedApiName = 'QuoteStatusFieldUpdate'
                LIMIT 1];
        if (mappings == null || mappings.size() < 1) return null;

        return mappings[0].Source_Value__c;
    }

    /**
     * @description retrieves the custom defined cart status value
     * when a quote is generated from a cart
     *
     * @return a String value of custom defined cart status
     */
    public static String getCustomCartStatus() {
        List<CPQ_B2B_Mapping__mdt> mappings = [
                Select 
                    Source_Value__c
                From
                    CPQ_B2B_Mapping__mdt
                WHERE
                    Process__c = 'CartToQuote'
                AND 
                    QualifiedApiName = 'CartStatusFieldUpdate'
                LIMIT 1];
        if (mappings == null || mappings.size() < 1) return null;

        return mappings[0].Source_Value__c;
    }

    /**
     * @description retrieves the custom defined order status value
     * when a quote is generated from a cc order
     *
     * @return a String value of custom defined order status
     */
    public static String getCustomOrderStatus() {
        List<CPQ_B2B_Mapping__mdt> mappings = [
                Select 
                    Source_Value__c
                From
                    CPQ_B2B_Mapping__mdt
                WHERE
                    Process__c = 'CCOrderToOrder'
                    AND 
                    QualifiedApiName = 'OrderStatusFieldUpdate'
                LIMIT 1];

        if (mappings == null || mappings.size() < 1) return null;

        return mappings[0].Source_Value__c;
    }

    /**
     * @description retrieves the custom defined opportunity stage value
     * when a oportunity is generated from a cc order
     *
     * @return a String value of custom defined opportunity stage
     */
    public static String getCustomOpportunityStage() {
        List<CPQ_B2B_Mapping__mdt> mappings = [
                Select 
                    Source_Value__c
                From
                    CPQ_B2B_Mapping__mdt
                WHERE
                    Process__c = 'CCOrderToOrder'
                    AND 
                    QualifiedApiName = 'OpportunityStageFieldUpdate'
                LIMIT 1];

        if (mappings == null || mappings.size() < 1) return null;

        return mappings[0].Source_Value__c;
    }
}