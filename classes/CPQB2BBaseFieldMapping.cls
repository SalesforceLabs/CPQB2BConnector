/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
* @author Ashlee Zeigler
* @date 3-3-2020

* @description Base Class for field mapping that can be overridden so that
* custom mapping classes can be defined within the custom metadata
*/
public abstract class CPQB2BBaseFieldMapping {
    public String sourceObject;
    public String destObject;
    public String sourceField;
    public String destField;
    public String serviceClass;
    public String sourceValue;

    /**
     * CPQB2BBaseFieldMapping Default constructor 
     * @param  srcField  
     * @param  destField 
     * @return CPQB2BBaseFieldMapping instance
     */
    public CPQB2BBaseFieldMapping() {}

     /**
     * CPQB2BBaseFieldMapping Constructor taking only a srcField and destField as parameters
     * @param  srcField  
     * @param  destField 
     * @return           CPQB2BBaseFieldMapping instance
     */
    public CPQB2BBaseFieldMapping(String srcField, String destField){
        this.sourceField = srcField;
        this.destField = destField;
    }

    /**
     * CPQB2BBaseFieldMapping Constructor taking CPQ_B2B_Mapping__mdt
     * @param  CPQ_B2B_Mapping__mdt  customFieldMap
     * @return           CPQB2BBaseFieldMapping instance
     */
    public CPQB2BBaseFieldMapping(CPQ_B2B_Mapping__mdt customFieldMap) {
        this.sourceObject = customFieldMap.Source_Object__r.QualifiedApiName;
        this.destObject = customFieldMap.Destination_Object__r.QualifiedApiName;
        this.sourceField = customFieldMap.Source_Field__r.QualifiedApiName;
        this.destField = customFieldMap.Destination_Field__r.QualifiedApiName;
        this.serviceClass = customFieldMap.Field_Mapping_Service_Class__c;
        this.sourceValue = customFieldMap.Source_Value__c;
    }

    /**
     * Set the Field Mapping for instances of the class that are dynamically instantiated
     * @param  CPQ_B2B_Mapping__mdt  customFieldMap
     */
    public void setFieldMapping(CPQ_B2B_Mapping__mdt customFieldMap) {
        this.sourceObject = customFieldMap.Source_Object__r.QualifiedApiName;
        this.destObject = customFieldMap.Destination_Object__r.QualifiedApiName;
        this.sourceField = customFieldMap.Source_Field__r.QualifiedApiName;
        this.destField = customFieldMap.Destination_Field__r.QualifiedApiName;
        this.serviceClass = customFieldMap.Field_Mapping_Service_Class__c;
        this.sourceValue = customFieldMap.Source_Value__c;
    }

    /**
     * copyValue abstract method to override the mapping between object 
     * @param SObject source
     * @param SObject destination
     */
    public abstract void copyValue(SObject source, SObject dest);
}