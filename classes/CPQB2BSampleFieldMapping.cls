/**
* @author Ashlee Zeigler
* @date 3-3-2020
*
*
* @description Sample Custom Field Mapping Class that will override the default
* behavior for copying between two objects. In this example it trims the source field value to 10 characters
*/
public class CPQB2BSampleFieldMapping extends CPQB2BBaseFieldMapping {

    /**
     * copyValue method to override the mapping between object by trimming the source field to 10 characters
     * @param SObject source
     * @param SObject destination
     */
    public override void copyValue(SObject source, SObject dest) {
        String value = (String)source.get(this.sourceField);
        if (value != null) {
            value = value.left(10); // Trim to 10 characters
            dest.put(this.destField, value);
        }
    }
}