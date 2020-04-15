/**
* @author Ashlee Zeigler
* @date 3/10/2020
*
* @see CPQB2BSelector
* @description Selector for CC Orders
*/
public class CPQB2BCCOrderSelector extends CPQB2BSelector {
      /*******************************************************************************************************
    * @description Constructor that sets SObjectType
    */
    public CPQB2BCCOrderSelector() {
        super(Schema.ccrz__E_Order__c.SObjectType);
    }

    /*******************************************************************************************************
    * @description Returns a Set that has all of the default fields.
    * @return Set of Strings that contain the default fields for this objec
    */
    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'ccrz__Account__c',
            'ccrz__Contact__c',
            'ccrz__CurrencyISOCode__c',
            'ccrz__OrderDate__c',
            'ccrz__Name__c',
            'ccrz__OrderName__c',
            'ccrz__OrderStatus__c',
            'OwnerId',
            'ccrz__Storefront__c',
            'ccrz__User__c',
            'Source_Order__c',
            'Sync_to_CPQ__c',
            'ccrz__OriginatedCart__c',
            '(SELECT B2B_Source_Order__C FROM Orders__r)',
            'ccrz__ShipTo__c',
            'ccrz__ShipTo__r.ccrz__PostalCode__c',
            'ccrz__ShipTo__r.ccrz__StateISOCode__c',
            'ccrz__ShipTo__r.ccrz__AddressFirstline__c',
            'ccrz__ShipTo__r.ccrz__City__c',
            'ccrz__ShipTo__r.ccrz__Country__c',
            'ccrz__ShipTo__r.ccrz__State__c',
            'ccrz__BillTo__c',
            'ccrz__BillTo__r.ccrz__PostalCode__c',
            'ccrz__BillTo__r.ccrz__StateISOCode__c',
            'ccrz__BillTo__r.ccrz__AddressFirstline__c',
            'ccrz__BillTo__r.ccrz__City__c',
            'ccrz__BillTo__r.ccrz__Country__c',
            'ccrz__BillTo__r.ccrz__State__c'
        };
    }

    /**
     * getMappedFields Returns the mapped fields from custom metadata
     * @return   Set<String> of field names
     */
    public Set<String> getMappedFields() {
        Set<String> customFieldsToQuery = new Set<String>();

        List<CPQB2BBaseFieldMapping> fieldMappings = CPQB2BFieldMapping.getCustomOrderToCCOrderMappings();
        if(fieldMappings != null){
            for(CPQB2BBaseFieldMapping fieldMap : fieldMappings){
                if (fieldMap.destField != null) {
                    customFieldsToQuery.add(fieldMap.destField);
                }
            }
        }
        return customFieldsToQuery;
    }

   /**
   * getMappedFields Returns the combined list of default fields and mapped fields to ensure no duplicate columns are queried
   * @return   Set<String> of field names
   */
    public Set<String> getFields() {
        Set<String> fieldsToQuery = new Set<String>();
        fieldsToQuery.addAll(getDefaultFields());
        fieldsToQuery.addAll(getMappedFields());
        return fieldsToQuery;
    }

    /*******************************************************************************************************
     * @description Returns a list of ccrz__E_Order__c by ids
     * @param Id orderIds
     * @return  ccrz__E_Order__c
     */
    public List<ccrz__E_Order__c> getByIds(List<Id> orderIds) {
        List<String> queryFields = new List<String>(getFields());

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM ccrz__E_Order__c';
        query += ' WHERE Id IN :orderIds';
        query += ' AND IsDeleted = false';

        return (List<ccrz__E_Order__c>)Database.query(query);
    }

    /*******************************************************************************************************
     * @description Returns a list of ccrz__E_Order__c by source ids
     * @param Id orderIds
     * @return  ccrz__E_Order__c
     */
    public List<ccrz__E_Order__c> getBySourceOrderIds(List<Id> sourceIds) {
        List<String> queryFields = new List<String>(getFields());

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM ccrz__E_Order__c';
        query += ' WHERE Source_Order__c IN :sourceIds';
        query += ' AND IsDeleted = false';

        return (List<ccrz__E_Order__c>)Database.query(query);
    }

    /*******************************************************************************************************
     * @description Get the Order QueryLocator for records that have not been synced
     *
     * @return  Database.QueryLocator
     */
    public Database.QueryLocator getCCOrdersToSync() {
        List<String> queryFields = new List<String>(getFields());

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM ccrz__E_Order__c';
        query += ' WHERE Sync_to_CPQ__c = true ';
        query += ' AND IsDeleted = false';

        return Database.getQueryLocator(query);
    }
}