/**
* @author Ashlee Zeigler
* @date 2-28-2020
*
* @see CPQB2BSelector
* @description Selector class for OrderItem
*/
public class CPQB2BOrderItemSelector extends CPQB2BSelector {
    /*******************************************************************************************************
    * @description Constructor that sets SObjectType
    */  
    public CPQB2BOrderItemSelector() {
        super(Schema.OrderItem.SObjectType);
    }

    /*******************************************************************************************************
    * @description Returns a Set that has all of the default fields. 
    * @return Set of Strings that contain the default fields for this objec
    */
    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'UnitPrice',
            'Quantity',
            'Product2Id',
            'OrderId',
            'PricebookEntryId'
        };
    }

    /**
     * getMappedFields Returns the mapped fields from custom metadata
     * @return   Set<String> of field names
     */
    public Set<String> getMappedFields() {
        Set<String> customFieldsToQuery = new Set<String>();

        List<CPQB2BBaseFieldMapping> fieldMappings = CPQB2BFieldMapping.getCustomOrderItemToCCOrderItemFieldMappings();
        if(fieldMappings != null){
            for(CPQB2BBaseFieldMapping fieldMap : fieldMappings){
                customFieldsToQuery.add(fieldMap.sourceField);
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
     * @description Returns a list of OrderItem records by ids 
     * @param Id orderItemIds
     * @return  List<OrderItem>
     */
    public List<OrderItem> getByOrderIds(List<Id> orderIds) {
        List<String> queryFields = new List<String>(this.getFields());

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM OrderItem';
        query += ' WHERE OrderId IN :orderIds';
        query += ' AND IsDeleted = false';

        return (List<OrderItem>)Database.query(query);
    }
}