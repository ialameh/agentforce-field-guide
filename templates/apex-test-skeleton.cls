/**
 * @description Tests for the <ClassName> invocable.
 */
@IsTest
public with sharing class <ClassName>Test {

    @IsTest
    static void execute_happyPath_returnsExpectedOutput() {
        <ClassName>.ActionInput input = new <ClassName>.ActionInput();
        input.<input1> = '<valid input value>';

        Test.startTest();
        List<<ClassName>.ActionOutput> outputs = <ClassName>.execute(
            new List<<ClassName>.ActionInput>{input}
        );
        Test.stopTest();

        System.assertEquals(1, outputs.size(), 'Expected one output for one input');
        System.assertNotEquals(null, outputs[0].<output1>, 'Output should not be null');
    }

    @IsTest
    static void execute_emptyInputs_throws() {
        Test.startTest();
        try {
            <ClassName>.execute(new List<<ClassName>.ActionInput>());
            System.assert(false, 'Expected ActionException');
        } catch (<ClassName>.ActionException e) {
            System.assert(e.getMessage().contains('No inputs'), 'Expected specific message');
        }
        Test.stopTest();
    }

    @IsTest
    static void execute_blankInput_throws() {
        <ClassName>.ActionInput input = new <ClassName>.ActionInput();
        input.<input1> = '';

        Test.startTest();
        try {
            <ClassName>.execute(new List<<ClassName>.ActionInput>{input});
            System.assert(false, 'Expected ActionException');
        } catch (<ClassName>.ActionException e) {
            System.assert(e.getMessage().contains('required'), 'Expected required message');
        }
        Test.stopTest();
    }
}
