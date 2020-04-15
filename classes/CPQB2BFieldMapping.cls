/**
* @author Amil Abdallah
* @date 02/17/2020
*
* @group BFieldMapping
* @group-content ../../ApexDocContent/CCProducts.htm
*
* @see CPQB2BBaseFieldMapping
* @description Generic wrapper class for handling the storage and retrieval of object field mappings
*/
public class CPQB2BFieldMapping extends CPQB2BBaseFieldMapping {

    /**
     * CPQB2BFieldMapping Constructor taking only a srcField and destField as parameters
     * @param  srcField  Product2 field name that is copied to CCProduct
     * @param  destField CCProduct field name that is copied from Product2
     * @return           CPQB2BFieldMapping instance
     */
    public CPQB2BFieldMapping(String srcField, String destField){
        super(srcField, destField);
    }

    /**
     * CPQB2BFieldMapping Constructor taking CPQ_B2B_Mapping__mdt as paramter to create mapping instance
     * @param  customFieldMap CPQ_B2B_Mapping__mdt record that defines custom field mapping
     * @return                CPQB2BFieldMapping instance
     */
    public CPQB2BFieldMapping(CPQ_B2B_Mapping__mdt customFieldMap){
        super(customFieldMap);
    }

    /**
     * getProductFieldMappings Retrieves a list of required and custom defined field mappings
     * for SKU Product2 to CCProduct syncing
     * @return   List of CPQB2BFieldMapping instances
     */
    public static List<CPQB2BBaseFieldMapping> getProductFieldMappings(){
        List<CPQB2BBaseFieldMapping> productFieldMappings = new List<CPQB2BBaseFieldMapping>();
        //productFieldMappings.addAll(getRequiredProductFieldMappings());

        List<CPQB2BBaseFieldMapping> customFieldMappings = getCustomProductFieldMappings();
        if(customFieldMappings!=null){
            productFieldMappings.addAll(getCustomProductFieldMappings());
        }
        return productFieldMappings;
    }

    /**
     * getRequiredProductFieldMappings Retrieves a list of required field mappings for SKU
     * Product2 to CCProduct syncing. MANUAL FIELD MAPPINGS HAVE BEEN MOVED TO CUSTOM METADATA RECORDS
     * KEEPING LOGIC WITHIN THE CODEBASE IN THE EVENT A FUTURE IMPLEMENTATION REQUIRES MANUAL MAPPING 
     * @return   List of CPQB2BFieldMapping instances
     */
    // public static List<CPQB2BFieldMapping> getRequiredProductFieldMappings(){
    //     List<CPQB2BFieldMapping> productFieldMappings = new List<CPQB2BFieldMapping>();
    //     productFieldMappings.add(new CPQB2BFieldMapping('Id','Source_Product__c')); //(Product2) Id => (CCProduct) Source Product
    //     productFieldMappings.add(new CPQB2BFieldMapping('Name','Name')); //(Product2) Name  => (CCProduct) Name
    //     productFieldMappings.add(new CPQB2BFieldMapping('Description','ccrz__LongDesc__c')); //(Product2) Description => (CCProduct) Long Description
    //     productFieldMappings.add(new CPQB2BFieldMapping('ProductCode','ccrz__SKU__c')); //(Product2) ProductCode => (CCProduct) Sku

    //     return productFieldMappings;
    // }

    /**
     * getProductStorefrontFieldMapping Retrieves field mapping for SKU Storefront fields
     * Product2 to CCProduct syncing MANUAL FIELD MAPPINGS HAVE BEEN MOVED TO CUSTOM METADATA RECORDS
     * KEEPING LOGIC WITHIN THE CODEBASE IN THE EVENT A FUTURE IMPLEMENTATION REQUIRES MANUAL MAPPING 
     * @return   List of CPQB2BFieldMapping instances
     */
    // public static CPQB2BFieldMapping getProductStorefrontFieldMapping(){
    //     return new CPQB2BFieldMapping('B2B_Storefront__c','ccrz__Storefront__c'); //(Product2) Storefront => (CCProduct) Storefront
    // }

    /**
     * getCustomProductFieldMappings Retrieves a list of custom field mappings queried
     * from CPQ_B2B_Mapping__mdt object defined for the SKU Product2 to CCProduct syncing
     * @return   List of CPQB2BFieldMapping instances
     */
    public static List<CPQB2BBaseFieldMapping> getCustomProductFieldMappings(){
        CPQB2BProcessType skuProcess = CPQB2BProcessType.SKU;
        List<CPQB2BBaseFieldMapping> productFieldMappings = CPQB2BMappingSelector.getMappingByProcess(skuProcess);
        return productFieldMappings;
    }

     /**
     * getPriceBookEntryFieldMappings Retrieves a list of required and custom defined field mappings
     * for PriceBookEntry to CCPriceListItems syncing
     * @return   List of CPQB2BFieldMapping instances
     */
    public static List<CPQB2BFieldMapping> getPriceBookEntryFieldMappings(){
        List<CPQB2BFieldMapping> fieldMappings = new List<CPQB2BFieldMapping>();
        fieldMappings.addAll(getRequiredPriceBookEntryFieldMappings());

        return fieldMappings;
    }

    /**
     * getRequiredPriceBookEntryFieldMappings Retrieves a list of required field mappings for PriceBookEntry
     * PriceBook2 to CCPriceList syncing
     * @return   List of CPQB2BFieldMapping instances
     */
    public static List<CPQB2BFieldMapping> getRequiredPriceBookEntryFieldMappings() {
        List<CPQB2BFieldMapping> fieldMappings = new List<CPQB2BFieldMapping>();
        fieldMappings.add(new CPQB2BFieldMapping('UnitPrice','ccrz__Price__c')); //(PriceBookEntry) UnitPrice => ( ccrz__E_PriceListItem__c) ccrz__Price__c
        fieldMappings.add(new CPQB2BFieldMapping('Id','Source_PriceBookEntry_Id__c')); //(PriceBookEntry) Id  => (ccrz__E_PriceListItem__c) Source_PriceBookEntry_Id__c
        return fieldMappings;
    }

     /**
     * getQuoteLineFieldMappings Retrieves a list of required and custom defined field mappings
     * for QuoteLine to CCPriceListItems syncing
     * @return   List of CPQB2BFieldMapping instances
     */
    public static List<CPQB2BBaseFieldMapping> getQuoteLineFieldMappings(){
        List<CPQB2BBaseFieldMapping> fieldMappings = new List<CPQB2BBaseFieldMapping>();
        fieldMappings.addAll(getRequiredQuoteLineFieldMappings());

        List<CPQB2BBaseFieldMapping> customFieldMappings = CPQB2BMappingSelector.getMappingByProcess(CPQB2BProcessType.Pricing);
        if(customFieldMappings!=null) {
            fieldMappings.addAll(getCustomQuoteLineFieldMappings());
        }
        return fieldMappings;
    }

    /**
     * getRequiredQuoteLineFieldMappings Retrieves a list of required field mappings for PriceBookEntry
     * QuoteLine to CCPriceList syncing
     * @return   List of CPQB2BFieldMapping instances
     */
    public static List<CPQB2BFieldMapping> getRequiredQuoteLineFieldMappings() {
        List<CPQB2BFieldMapping> fieldMappings = new List<CPQB2BFieldMapping>();
        //UnitPrice to Price mapping is commented out as it was moved to a field mapping metadata record
        //fieldMappings.add(new CPQB2BFieldMapping('SBQQ__NetPrice__c','ccrz__Price__c')); //(SBQQ__QuoteLine__c) SBQQ__NetPrice__c => ( ccrz__E_PriceListItem__c) ccrz__Price__c
        
        /*
            @Amil Abdallah: Attempted to utilize a custom metadata mapping for the Id to Quote_Line__c mapping but getting the following error when attempting to deploy:
            
            Error Message: UNKNOWN_EXCEPTION: An unexpected error occurred. Please include this ErrorId if you contact support: 1848849269-184014 (-1442405920)
            Deploy was NOT Successful

            I was eventually able to deploy record, but had to do so in 3 separate deployments (see below)
            Deployment 1: Deploy as an empty record (all fields null), except the required process field
            Deployment 2: Populate values for Source Object and Source Field
            Deployment 3: Populate Destination Object and Destination Field 

            Only by deploying the record in these 3 steps was I able to get a pass. It was decided to manually map this record due to deployment issue.
            
            Note: Metadata record can be manually created through Salesforce UI, without an error.
        */
        fieldMappings.add(new CPQB2BFieldMapping('Id','Quote_Line__c')); //(SBQQ__QuoteLine__c) Id  => (ccrz__E_PriceListItem__c) Quote_Line__c

        return fieldMappings;
    }

    /**
     * getSourceIdFieldByProcessType Retrieves the source Id field associated to the
     * process type to be used for identifying the source record id to apply to the
     * log record that is generated if an error occurs.
     * PriceBook2 to CCPriceList syncing
     * @param  processType  Name of the sync process type
     * @return   field api name of the source id field
     */
    public static String getSourceIdFieldByProcessType(String processType) {
        String sourceIdField;

        if(processType.equalsIgnoreCase(CPQB2BProcessType.SKU.name())){
            sourceIdField = 'Source_Product__c';
        }
        else if(processType.equalsIgnoreCase(CPQB2BProcessType.CartToQuote.name())){
            sourceIdField = 'B2B_Source__c';
        }

        return sourceIdField;
    }

     /**
     * getCustomQuoteLineFieldMappings Retrieves a list of custom field mappings queried
     * from CPQ_B2B_Mapping__mdt object defined for the SKU Product2 to CCProduct syncing
     * @return   List of CPQB2BFieldMapping instances
     */
    public static List<CPQB2BBaseFieldMapping> getCustomQuoteLineFieldMappings() {
        CPQB2BProcessType process = CPQB2BProcessType.Pricing;
        List<CPQB2BBaseFieldMapping> fieldMappings = CPQB2BMappingSelector.getMappingByProcess(process);

        List<CPQB2BBaseFieldMapping> quoteLineFieldMappings = new List<CPQB2BBaseFieldMapping>();

        if(fieldMappings!=null){
            for(CPQB2BBaseFieldMapping fieldMap : fieldMappings){
                if (fieldMap.sourceObject == 'SBQQ__QuoteLine__c') {
                    quoteLineFieldMappings.add(fieldMap);
                }
            }
        }

        return quoteLineFieldMappings;
    }

    /**
     * getOrderToCCOrderMappings Retrieves a list of required and custom defined field mappings
     * from Order to CC Order
     * @return   List of CPQB2BFieldMapping instances
     */
    public static List<CPQB2BBaseFieldMapping> getOrderToCCOrderMappings(){
        List<CPQB2BBaseFieldMapping> fieldMappings = new List<CPQB2BBaseFieldMapping>();
        //fieldMappings.addAll(getRequiredOrderToCCOrderMappings());
        fieldMappings.addAll(getCustomOrderToCCOrderMappings());

        return fieldMappings;
    }

     /**
     * getRequiredOrderToCCOrderMappings Retrieves a list of required field mappings
     * from Order to CC Order. MANUAL FIELD MAPPINGS HAVE BEEN MOVED TO CUSTOM METADATA RECORDS
     * KEEPING LOGIC WITHIN THE CODEBASE IN THE EVENT A FUTURE IMPLEMENTATION REQUIRES MANUAL MAPPING 
     * @return   List of CPQB2BFieldMapping instances
     */
    // public static List<CPQB2BFieldMapping> getRequiredOrderToCCOrderMappings() {
    //     List<CPQB2BFieldMapping> fieldMappings = new List<CPQB2BFieldMapping>();
    //     fieldMappings.add(new CPQB2BFieldMapping('Id','Source_Order__c')); //(Order) Id => (CCOrder) Source Order
    //     fieldMappings.add(new CPQB2BFieldMapping('AccountId','ccrz__Account__c')); //(Order) Account Id  => (CCOrder) Account Id
    //     fieldMappings.add(new CPQB2BFieldMapping('ShipToContactId','ccrz__Contact__c')); //(Order) ShipToContactId => (CCOrder) Contact
    //     fieldMappings.add(new CPQB2BFieldMapping('Name','ccrz__Name__c')); //(Order) Name => (CCOrder) Name

    //     return fieldMappings;
    // }

    /**
     * getCustomOrderToCCOrderMappings Retrieves a list of custom field mappings queried
     * from Order to CC Order
     * @return   List of CPQB2BFieldMapping instances
     */
    public static List<CPQB2BBaseFieldMapping> getCustomOrderToCCOrderMappings(){
        List<CPQB2BBaseFieldMapping> fieldMappings = CPQB2BMappingSelector.getMappingByProcess(CPQB2BProcessType.OrderToCCOrder);
        if (fieldMappings == null) {
            return new List<CPQB2BBaseFieldMapping>();
        }

        List<CPQB2BBaseFieldMapping> relevantMappings = new List<CPQB2BBaseFieldMapping>();
        for (CPQB2BBaseFieldMapping fieldMap : fieldMappings) {
            if (fieldMap.sourceObject == 'Order' || (fieldMap.destObject == 'ccrz__E_Order__c' && fieldMap.sourceValue != null)) {
                relevantMappings.add(fieldMap);
            }
        }
        return relevantMappings;
    }

     /**
     * getOrderItemToCCOrderItemMappings Retrieves a list of required and custom defined field mappings
     * from OrderItem to CC OrderItem
     * @return   List of CPQB2BFieldMapping instances
     */
    public static List<CPQB2BBaseFieldMapping> getOrderItemToCCOrderItemMappings(){
        List<CPQB2BBaseFieldMapping> fieldMappings = new List<CPQB2BFieldMapping>();
       //fieldMappings.addAll(getRequiredOrderItemToCCOrderItemMappings());

        List<CPQB2BBaseFieldMapping> customFieldMappings = CPQB2BMappingSelector.getMappingByProcess(CPQB2BProcessType.OrderToCCOrder);
        if(customFieldMappings!=null) {
            fieldMappings.addAll(getCustomOrderItemToCCOrderItemFieldMappings());
        }
        return fieldMappings;
    }

    /**
     * getRequiredOrderItemToCCOrderItemMappings Retrieves a list of required field mappings
     * from OrderItem to CC OrderItem. MANUAL FIELD MAPPINGS HAVE BEEN MOVED TO CUSTOM METADATA RECORDS
     * KEEPING LOGIC WITHIN THE CODEBASE IN THE EVENT A FUTURE IMPLEMENTATION REQUIRES MANUAL MAPPING 
     * @return   List of CPQB2BFieldMapping instances
     */
    // public static List<CPQB2BFieldMapping> getRequiredOrderItemToCCOrderItemMappings() {
    //     List<CPQB2BFieldMapping> fieldMappings = new List<CPQB2BFieldMapping>();
    //     fieldMappings.add(new CPQB2BFieldMapping('Id','Source_Order_Item__c')); //(Order) Id => (CCOrder) Source Order
    //     fieldMappings.add(new CPQB2BFieldMapping('UnitPrice','ccrz__OriginalItemPrice__c')); //(Order) Id => (CCOrder) Source Order
    //     fieldMappings.add(new CPQB2BFieldMapping('Quantity','ccrz__OriginalQuantity__c')); //(Order) Name  => (CCOrder) Name
    //     fieldMappings.add(new CPQB2BFieldMapping('UnitPrice','ccrz__Price__c')); //(Order) ProductCode => (CCOrder) Sku
    //     fieldMappings.add(new CPQB2BFieldMapping('Quantity','ccrz__Quantity__c')); //(Order) ProductCode => (CCOrder) Sku
    //     // Commenting this out for now, calculation needs to be done UnitPrice * Quantity
    //    // fieldMappings.add(new CPQB2BFieldMapping('UnitPrice','ccrz__SubAmount__c')); //(Order) ProductCode => (CCOrder) Sku

    //     return fieldMappings;
    // }

    /**
     * getCustomOrderItemToCCOrderItemFieldMappings Retrieves a list of custom field mappings queried
     * from CPQ_B2B_Mapping__mdt object defined for the Order Item to CCOrderItem syncing
     * @return   List of CPQB2BFieldMapping instances
     */
    public static List<CPQB2BBaseFieldMapping> getCustomOrderItemToCCOrderItemFieldMappings() {
        List<CPQB2BBaseFieldMapping> fieldMappings = CPQB2BMappingSelector.getMappingByProcess(CPQB2BProcessType.OrderToCCOrder);
        if (fieldMappings == null) {
            return new List<CPQB2BBaseFieldMapping>();
        }

        List<CPQB2BBaseFieldMapping> relevantMappings = new List<CPQB2BBaseFieldMapping>();
        for (CPQB2BBaseFieldMapping fieldMap : fieldMappings) {
            if (fieldMap.sourceObject == 'OrderItem') {
                relevantMappings.add(fieldMap);
            }
        }

        return relevantMappings;
    }

    /**
     * copyValue  Contains logic to copy either a source field to a destination field, 
     * a static text value to a destination field, or do the mapping in a custom class
     * defined in the custom metadata
     * @param SObject source
     * @param SObject destination
     */
    public override void copyValue(SObject source, SObject dest) {
        if (this.sourceValue != null && this.sourceObject == null) {
            dest.put(this.destField, this.sourceValue);
        } else {
            dest.put(this.destField, source.get(this.sourceField));
        }     
    }
}