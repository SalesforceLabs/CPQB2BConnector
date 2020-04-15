/**
 * Created by javierarroyo on 2/12/20.
 */

@IsTest(seeAllData=true)
private class CPQB2BMappingSelector_Test {

    @IsTest
    static void testBehavior() {
        System.debug('starting test');

        List<CPQB2BBaseFieldMapping> mappingList = CPQB2BMappingSelector.getMappingByProcess( CPQB2BProcessType.Test );

        System.assertEquals(1, mappingList.size());
    }
}