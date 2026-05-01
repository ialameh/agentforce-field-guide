/**
 * @description Custom invocable for an Agentforce agent action.
 * @see <link to your agent design doc>
 */
public with sharing class <ClassName> {

    /**
     * @description Input wrapper class for the invocable.
     */
    @JsonAccess(serializable='always' deserializable='always')
    public class ActionInput {
        @InvocableVariable(
            label='<Input Label>'
            description='<Describe what this input means>'
            required=true
        )
        public String <input1>;
    }

    /**
     * @description Output wrapper class for the invocable.
     */
    @JsonAccess(serializable='always' deserializable='always')
    public class ActionOutput {

        public ActionOutput(String <output1>) {
            this.<output1> = <output1>;
        }

        @InvocableVariable(
            label='<Output Label>'
            description='<Describe what this output means>'
        )
        public String <output1>;
    }

    /**
     * @description The agent-callable method.
     * @param inputs List of action inputs (the runner passes a list even for single calls).
     * @return List of action outputs.
     */
    @InvocableMethod(
        label='<Action Display Name>'
        description='<One sentence describing the action behaviour>'
        category='<Category>'
        callout=false
    )
    public static List<ActionOutput> execute(List<ActionInput> inputs) {
        // Validate. The schema is enforced at runtime, but defence in depth matters.
        if (inputs == null || inputs.isEmpty()) {
            throw new ActionException('No inputs provided.');
        }

        List<ActionOutput> outputs = new List<ActionOutput>();
        for (ActionInput input : inputs) {
            if (String.isBlank(input.<input1>)) {
                throw new ActionException('<input1> is required.');
            }

            // Authorise. Confirm the agent user is allowed to act on this input.
            // ...

            // Do the work. Keep it focused, deterministic, and testable.
            String result = '<some computed output>';

            outputs.add(new ActionOutput(result));
        }
        return outputs;
    }

    /**
     * @description Custom exception type so callers can distinguish action errors.
     */
    public class ActionException extends Exception {}
}
